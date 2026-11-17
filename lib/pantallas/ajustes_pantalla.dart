import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class AjustesPantalla extends StatefulWidget {
  const AjustesPantalla({super.key});

  @override
  State<AjustesPantalla> createState() => _AjustesPantallaState();
}

class _AjustesPantallaState extends State<AjustesPantalla> {
  PermissionStatus? _estadoCamara;
  PermissionStatus? _estadoMicrofono;

  @override
  void initState() {
    super.initState();
    _comprobarPermisos();
  }

  Future<void> _comprobarPermisos() async {
    final camara = await Permission.camera.status;
    final microfono = await Permission.microphone.status;
    setState(() {
      _estadoCamara = camara;
      _estadoMicrofono = microfono;
    });
  }

  @override
  Widget build(BuildContext context) {
    final preferencias = context.watch<PreferenciasApp>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Aviso de privacidad: StockAR usa el microfono para reconocer tus '
            'ordenes de voz y la camara para la etiqueta de realidad aumentada '
            'y para comprobar que miras la pantalla. Nada se graba ni se envia '
            'fuera del dispositivo.',
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Tema oscuro'),
            value: preferencias.modoTema == ThemeMode.dark,
            onChanged: (activo) => preferencias.cambiarModoTema(activo ? ThemeMode.dark : ThemeMode.light),
          ),
          ListTile(
            title: const Text('Idioma'),
            trailing: DropdownButton<Locale>(
              value: preferencias.idioma,
              items: const [
                DropdownMenuItem(value: Locale('es'), child: Text('Espanol')),
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
              ],
              onChanged: (locale) {
                if (locale != null) preferencias.cambiarIdioma(locale);
              },
            ),
          ),
          const Divider(height: 48),
          ListTile(
            title: const Text('Permiso de camara'),
            subtitle: Text('${_estadoCamara ?? '...'}'),
            trailing: ElevatedButton(
              onPressed: () async {
                await Permission.camera.request();
                _comprobarPermisos();
              },
              child: const Text('Pedir'),
            ),
          ),
          ListTile(
            title: const Text('Permiso de microfono'),
            subtitle: Text('${_estadoMicrofono ?? '...'}'),
            trailing: ElevatedButton(
              onPressed: () async {
                await Permission.microphone.request();
                _comprobarPermisos();
              },
              child: const Text('Pedir'),
            ),
          ),
        ],
      ),
    );
  }
}
