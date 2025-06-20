import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/services.dart';
import 'package:printest/FuncionPage.dart';

//proyecto de imprimir con impresora termica ble
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription<BlueState> _blueStateSubscription;
  late StreamSubscription<ConnectState> _connectStateSubscription;
  late StreamSubscription<Uint8List> _receivedDataSubscription;
  late StreamSubscription<List<BluetoothDevice>> _scanResultsSubscription;
  late List<BluetoothDevice> _scanResults;
  BluetoothDevice? _device;

  @override
  void initState() {
    super.initState();
    _scanResults = [];
    initBluetoothPrintPlusListen();
  }

  @override
  void dispose() {
    super.dispose();
    _blueStateSubscription.cancel();
    _connectStateSubscription.cancel();
    _receivedDataSubscription.cancel();
    _scanResultsSubscription.cancel();
    _scanResults.clear();
  }

  Future<void> initBluetoothPrintPlusListen() async {
    /// listen scanResults
    _scanResultsSubscription = BluetoothPrintPlus.scanResults.listen((event) {
      if (mounted) {
        setState(() {
          _scanResults = event;
        });
      }
    });

    /// listen blue state
    _blueStateSubscription = BluetoothPrintPlus.blueState.listen((event) {
      print('********** blueState change: $event **********');
      if (mounted) {
        setState(() {});
      }
    });

    /// listen connect state
    _connectStateSubscription = BluetoothPrintPlus.connectState.listen((event) {
      print('********** connectState change: $event **********');
      switch (event) {
        case ConnectState.connected:
          if (_device != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FunctionPage(_device!)),
            );
          }
          break;
        case ConnectState.disconnected:
          if (_device != null) {
            _device = null;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Desconectado del dispositivo')),
            );
          }
          break;
      }
    });

    /// listen received data
    _receivedDataSubscription = BluetoothPrintPlus.receivedData.listen((data) {
      print('********** received data: $data **********');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BluetoothPrintPlus')),
      body: SafeArea(
        child: BluetoothPrintPlus.isBlueOn
            ? Column(
                children: [
                  // Scanned Devices
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'Dispositivos encontrados:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: _scanResults
                          .map((device) => _buildDeviceItem(context, device))
                          .toList(),
                    ),
                  ),
                ],
              )
            : buildBlueOffWidget(),
      ),
      floatingActionButton: BluetoothPrintPlus.isBlueOn
          ? buildScanButton(context)
          : null,
    );
  }

  Widget buildBlueOffWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bluetooth_disabled, size: 64.0, color: Colors.grey),
          const Text(
            'Bluetooth está desactivado',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildScanButton(BuildContext context) {
    if (BluetoothPrintPlus.isScanningNow) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
        onPressed: onScanPressed,
        backgroundColor: Colors.green,
        child: const Icon(Icons.search),
      );
    }
  }

  Widget _buildDeviceItem(BuildContext context, BluetoothDevice device) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name),
                Text(
                  device.address,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(),
              ],
            ),
          ),
          SizedBox(width: 10),
          OutlinedButton(
            onPressed: () async {
              _device = device;
              await BluetoothPrintPlus.connect(device);
            },
            child: const Text("Conectar"),
          ),
        ],
      ),
    );
  }

  Future onScanPressed() async {
    try {
      await BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      print("onScanPressed error: $e");
    }
  }

  Future onStopPressed() async {
    try {
      await BluetoothPrintPlus.stopScan();
    } catch (e) {
      print("onStopPressed error: $e");
    }
  }
}
