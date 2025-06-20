import 'package:bluetooth_print_plus/src/blue_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';

class FunctionPage extends StatefulWidget {
  final BluetoothDevice bluetoothDevice;

  const FunctionPage(this.bluetoothDevice, {super.key});

  @override
  State<FunctionPage> createState() => _FunctionPageState();
}

class _FunctionPageState extends State<FunctionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Functions')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _printImage,
              child: const Text('Print Image'),
            ),
            ElevatedButton(
              onPressed: _printText,
              child: const Text('Print Text'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printImage() async {
    try {
      final ByteData bytes = await rootBundle.load("assets/dithered-image.png");
      final Uint8List image = bytes.buffer.asUint8List();

      // TSC Command
      final tscCommand = TscCommand();
      await tscCommand.cleanCommand();
      await tscCommand.size(width: 76, height: 130);
      await tscCommand.cls();
      await tscCommand.image(image: image, x: 50, y: 60);
      await tscCommand.print(1);
      final tscCmd = await tscCommand.getCommand();
      if (tscCmd != null) {
        await BluetoothPrintPlus.write(tscCmd);
      }

      // CPCL Command
      final cpclCommand = CpclCommand();
      await cpclCommand.cleanCommand();
      await cpclCommand.size(width: 76 * 8, height: 76 * 8);
      await cpclCommand.image(image: image, x: 10, y: 10);
      await cpclCommand.print();
      final cpclCmd = await cpclCommand.getCommand();
      if (cpclCmd != null) {
        await BluetoothPrintPlus.write(cpclCmd);
      }

      // ESC Command
      final escCommand = EscCommand();
      await escCommand.cleanCommand();
      await escCommand.print();
      await escCommand.image(image: image);
      await escCommand.print();
      final escCmd = await escCommand.getCommand();
      if (escCmd != null) {
        await BluetoothPrintPlus.write(escCmd);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image printed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error printing: $e')));
    }
  }

  Future<void> _printText() async {
    try {
      // TSC Command
      final tscCommand = TscCommand();
      await tscCommand.cleanCommand();
      await tscCommand.size(width: 76, height: 130);
      await tscCommand.cls();
      await tscCommand.text(content: "Hola Mundo!\nEste es un ejemplo de texto\nimpreso usando TSC Command.");
      await tscCommand.print(1);
      final tscCmd = await tscCommand.getCommand();
      if (tscCmd != null) {
        await BluetoothPrintPlus.write(tscCmd);
      }

      // CPCL Command
      final cpclCommand = CpclCommand();
      await cpclCommand.cleanCommand();
      await cpclCommand.text(content: "Hola Mundo!\nEste es un ejemplo de texto\nimpreso usando CPCL Command.");
      await cpclCommand.print();
      final cpclCmd = await cpclCommand.getCommand();
      if (cpclCmd != null) {
        await BluetoothPrintPlus.write(cpclCmd);
      }

      // ESC Command
      final escCommand = EscCommand();
      await escCommand.cleanCommand();
      await escCommand.text(content: "Hola Mundo!\nEste es un ejemplo de texto\nimpreso usando ESC Command.");
      await escCommand.print();
      final escCmd = await escCommand.getCommand();
      if (escCmd != null) {
        await BluetoothPrintPlus.write(escCmd);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Texto impreso exitosamente!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al imprimir: $e')),
      );
    }
  }
}
