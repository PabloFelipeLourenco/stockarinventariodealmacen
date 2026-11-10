import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Esta pantalla NO es una de las 10 pantallas principales del proyecto:
// es una ventana extra a la que se llega desde la ficha de producto.
//
// Mostramos la camara en vivo con el nombre del producto y el stock
// superpuestos, como si fuera una etiqueta flotando sobre la estanteria.
// Lo hacemos con camara + texto superpuesto (y no con ar_flutter_plugin)
// porque no tenemos un dispositivo con ARCore/ARKit para probarlo; esta
// decision esta justificada en la memoria (apartado de RA2.f).
class RealidadAumentadaPantalla extends StatefulWidget {
  final String nombreProducto;
  final int stock;

  const RealidadAumentadaPantalla({
    super.key,
    required this.nombreProducto,
    required this.stock,
  });

  @override
  State<RealidadAumentadaPantalla> createState() => _RealidadAumentadaPantallaState();
}

class _RealidadAumentadaPantallaState extends State<RealidadAumentadaPantalla> {
  CameraController? _controladorCamara;
  String? _error;

  @override
  void initState() {
    super.initState();
    _iniciarCamara();
  }

  Future<void> _iniciarCamara() async {
    final permiso = await Permission.camera.request();
    if (!permiso.isGranted) {
      setState(() => _error = 'Necesitamos el permiso de camara para ver la etiqueta virtual');
      return;
    }

    try {
      final camaras = await availableCameras();
      if (camaras.isEmpty) {
        setState(() => _error = 'No se ha encontrado ninguna camara');
        return;
      }
      _controladorCamara = CameraController(camaras.first, ResolutionPreset.medium);
      await _controladorCamara!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _error = 'No se pudo abrir la camara: $e');
    }
  }

  @override
  void dispose() {
    _controladorCamara?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Etiqueta virtual')),
      body: _error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
          : (_controladorCamara == null || !_controladorCamara!.value.isInitialized)
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Positioned.fill(child: CameraPreview(_controladorCamara!)),
                    Positioned(
                      top: 40,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.nombreProducto}\nStock: ${widget.stock} unidades',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
