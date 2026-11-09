import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../controladores/productos_controlador.dart';
import '../controladores/movimientos_controlador.dart';
import '../modelos/movimiento.dart';
import '../modelos/producto.dart';

// Esta pantalla junta dos interfaces naturales a la vez:
// 1) Reconocimiento de voz (RA2.c) para registrar entradas/salidas y
//    para preguntar cuanto stock queda de un producto, con respuesta
//    hablada (flutter_tts).
// 2) Deteccion de cara (RA2.e), solo para saber si alguien esta mirando
//    la pantalla: si nadie mira, pausamos la escucha de voz.
class NuevoMovimientoVozPantalla extends StatefulWidget {
  const NuevoMovimientoVozPantalla({super.key});

  @override
  State<NuevoMovimientoVozPantalla> createState() => _NuevoMovimientoVozPantallaState();
}

class _NuevoMovimientoVozPantallaState extends State<NuevoMovimientoVozPantalla> {
  final SpeechToText _reconocedorVoz = SpeechToText();
  final FlutterTts _vozSintetizada = FlutterTts();
  final FaceDetector _detectorCara = FaceDetector(options: FaceDetectorOptions());

  CameraController? _controladorCamara;
  bool _escuchando = false;
  bool _caraVisible = true;
  bool _procesandoFrame = false;
  String _textoReconocido = '';
  String _ultimaRespuesta = '';

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await Permission.microphone.request();
    await _reconocedorVoz.initialize();
    await _iniciarCamaraParaDeteccionDeCara();
  }

  Future<void> _iniciarCamaraParaDeteccionDeCara() async {
    // Google ML Kit (el paquete que detecta la cara) solo funciona en
    // Android e iOS: en el navegador no hay ninguna implementacion, lo
    // dice la propia documentacion del paquete. Para no intentar algo
    // que sabemos que va a fallar, en web dejamos _caraVisible siempre
    // en true (no bloqueamos la voz) y lo dejamos dicho en pantalla.
    if (kIsWeb) return;

    final permiso = await Permission.camera.request();
    if (!permiso.isGranted) return;

    try {
      final camaras = await availableCameras();
      final camaraFrontal = camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => camaras.first,
      );
      _controladorCamara = CameraController(camaraFrontal, ResolutionPreset.low, enableAudio: false);
      await _controladorCamara!.initialize();
      await _controladorCamara!.startImageStream(_procesarFrame);
      if (mounted) setState(() {});
    } catch (e) {
      // Si no hay camara frontal (por ejemplo en un emulador de escritorio)
      // dejamos la deteccion de cara desactivada, pero la voz funciona igual.
      debugPrint('No se pudo iniciar la deteccion de cara: $e');
    }
  }

  void _procesarFrame(CameraImage imagen) async {
    if (_procesandoFrame) return;
    _procesandoFrame = true;

    try {
      final inputImage = _convertirAInputImage(imagen);
      if (inputImage != null) {
        final caras = await _detectorCara.processImage(inputImage);
        final hayAlguienMirando = caras.isNotEmpty;

        if (hayAlguienMirando != _caraVisible && mounted) {
          setState(() => _caraVisible = hayAlguienMirando);
          // Si deja de haber nadie mirando mientras escuchamos, pausamos.
          if (!hayAlguienMirando && _escuchando) {
            _detenerEscucha();
          }
        }
      }
    } catch (_) {
      // Un fallo al convertir un frame concreto no es grave, lo ignoramos.
    }

    _procesandoFrame = false;
  }

  InputImage? _convertirAInputImage(CameraImage imagen) {
    if (_controladorCamara == null) return null;
    final camara = _controladorCamara!.description;

    final bytesBuilder = BytesBuilder();
    for (final plano in imagen.planes) {
      bytesBuilder.add(plano.bytes);
    }

    final rotacion = InputImageRotationValue.fromRawValue(camara.sensorOrientation) ?? InputImageRotation.rotation0deg;
    final formato = InputImageFormatValue.fromRawValue(imagen.format.raw) ?? InputImageFormat.nv21;

    return InputImage.fromBytes(
      bytes: bytesBuilder.toBytes(),
      metadata: InputImageMetadata(
        size: Size(imagen.width.toDouble(), imagen.height.toDouble()),
        rotation: rotacion,
        format: formato,
        bytesPerRow: imagen.planes.first.bytesPerRow,
      ),
    );
  }

  Future<void> _empezarEscucha() async {
    if (!_caraVisible) {
      _hablar('No te veo mirando a la pantalla, acercate para empezar');
      return;
    }

    final disponible = await _reconocedorVoz.initialize();
    if (!disponible) {
      _hablar('No se puede usar el reconocimiento de voz en este dispositivo');
      return;
    }

    setState(() => _escuchando = true);
    _reconocedorVoz.listen(
      localeId: 'es_ES',
      onResult: (resultado) {
        setState(() => _textoReconocido = resultado.recognizedWords);
        if (resultado.finalResult) {
          _procesarOrden(resultado.recognizedWords);
        }
      },
    );
  }

  void _detenerEscucha() {
    _reconocedorVoz.stop();
    if (mounted) setState(() => _escuchando = false);
  }

  Future<void> _procesarOrden(String texto) async {
    _detenerEscucha();
    if (texto.trim().isEmpty) return;

    final textoMinusculas = texto.toLowerCase();
    final controladorProductos = context.read<ProductosControlador>();
    final controladorMovimientos = context.read<MovimientosControlador>();

    final coincidenciaNumero = RegExp(r'(\d+)').firstMatch(textoMinusculas);

    // Orden 1: preguntar cuanto stock queda de un producto.
    if (textoMinusculas.contains('cuanto') || textoMinusculas.contains('cuánto')) {
      final producto = _buscarProductoEnTexto(textoMinusculas, controladorProductos);
      if (producto == null) {
        _hablar('No he encontrado ese producto');
        return;
      }
      final stock = controladorProductos.stockDe(producto.id!);
      _hablar('Quedan $stock unidades de ${producto.nombre}');
      return;
    }

    // Orden 2: registrar una entrada o una salida, por ejemplo
    // "entrada de veinte unidades de tornillo m6".
    if ((textoMinusculas.contains('entrada') || textoMinusculas.contains('salida')) && coincidenciaNumero != null) {
      final tipo = textoMinusculas.contains('entrada') ? 'entrada' : 'salida';
      final unidades = int.parse(coincidenciaNumero.group(1)!);
      final producto = _buscarProductoEnTexto(textoMinusculas, controladorProductos);

      if (producto == null) {
        _hablar('No he encontrado ese producto');
        return;
      }

      await controladorMovimientos.registrarMovimiento(Movimiento(
        productoId: producto.id!,
        tipo: tipo,
        unidades: unidades,
        fecha: DateTime.now().toIso8601String(),
      ));
      await controladorProductos.cargarTodo();
      _hablar('Registrada $tipo de $unidades unidades de ${producto.nombre}');
    } else {
      _hablar('No he entendido la orden, prueba otra vez');
    }
  }

  Producto? _buscarProductoEnTexto(String texto, ProductosControlador controlador) {
    for (final producto in controlador.productos) {
      if (texto.contains(producto.nombre.toLowerCase())) {
        return producto;
      }
    }
    return null;
  }

  Future<void> _hablar(String texto) async {
    setState(() => _ultimaRespuesta = texto);
    await _vozSintetizada.setLanguage('es-ES');
    await _vozSintetizada.speak(texto);
  }

  @override
  void dispose() {
    _controladorCamara?.stopImageStream();
    _controladorCamara?.dispose();
    if (!kIsWeb) {
      _detectorCara.close();
    }
    _reconocedorVoz.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo movimiento por voz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Feedback visual de si la app esta escuchando (lo pide la NUI).
            Icon(
              _escuchando ? Icons.mic : Icons.mic_none,
              size: 80,
              color: _escuchando ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 8),
            if (kIsWeb)
              const Text(
                'Deteccion de cara no disponible en el navegador (solo Android/iOS)',
                style: TextStyle(color: Colors.orange),
                textAlign: TextAlign.center,
              )
            else
              Text(_caraVisible ? 'Te estamos viendo' : 'No vemos tu cara, acercate'),
            const SizedBox(height: 16),
            Text('Reconocido: $_textoReconocido'),
            const SizedBox(height: 8),
            Text('Respuesta: $_ultimaRespuesta'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.mic),
              label: Text(_escuchando ? 'Escuchando...' : 'Hablar'),
              onPressed: _escuchando ? null : _empezarEscucha,
            ),
            const Divider(height: 48),
            const Text('Alternativa tactil, por si no quieres usar la voz:'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/movimientos'),
              child: const Text('Registrar movimiento manualmente'),
            ),
          ],
        ),
      ),
    );
  }
}
