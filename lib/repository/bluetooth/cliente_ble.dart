// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/animal_model.dart';
import 'cliente_ble_abstract.dart';
import 'spot_status.dart';

class ClienteBLE implements ClienteBleAbstract {
  final Guid _serviceId = Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  final Guid _rxcharacteristicId = Guid('beb5483e-36e1-4688-b7f5-ea07361b26a8');
  final Guid _txcharacteristicId = Guid('81c190ae-538a-40a2-b861-cf5ed68b1e06');
  bool _connecting = false;
  String buffer = "";
  int _mtu = 20;
  int _datalen = 0;
  int _bytesreceived = 0;

  static late FlutterBlue _flutterBlue;
  late StreamController<String> _estadoStream;
  late StreamController<SpotStatus> _progressoStream;
  StreamSubscription? scanSubs;
  StreamSubscription? listenRxSubs;
  ClienteBLE() {
    _flutterBlue = FlutterBlue.instance;
    _estadoStream = StreamController<String>();
    _progressoStream = StreamController<SpotStatus>();

    Permission.bluetooth.isDenied.then((isdenied) async {
      print(isdenied);
      if (isdenied) {
        await Permission.bluetooth.request();
      }
    }, onError: (e) {
      print(e);
    });
  }

  //Procura o beacon PELOTO, conecta e lê os dados  da característica
  @override
  Future<void> ler(Function(AnimalModel animal) resolv) async {
    await listenRxSubs?.cancel();
    await _flutterBlue.stopScan();
    await disconnectBLE();
    _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsDesconectado, 0));
    buffer = "";
    _datalen = 0;
    _bytesreceived = 0;
    _connecting = false;

    _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsBuscando, 0));
    _flutterBlue.scan().listen(
      (event) {
        if (!_connecting && event.device.name.startsWith("AuMiau")) {
          _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsBuscando, 0));
          _connecting = true;
          lerDoDispositivo(event.device, resolv);
        }
      },
    );
  }

  @override
  Future<void> lerDoDispositivo(
      BluetoothDevice device, Function(AnimalModel animal) resolv) async {
    await _flutterBlue.stopScan();
    print('BLE: ${device.name} found!');
    _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsEncontrado, 0));

    var conectados = await _flutterBlue.connectedDevices;

    if (conectados.isEmpty) {
      try {
        _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsConectando, 0));
        await device.connect();
      } catch (e) {
        _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsFalhou, 0));
        print('BLE: $e');
      }
    }
    _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsConectado, 0));
    print('BLE: ${device.name} conectado!');
    print("BLE: Descobrir services. ");
    try {
      var services = await device.discoverServices();
      print("BLE: services found (${services.length})");
      var service =
          services.firstWhere((element) => element.uuid == _serviceId);
      var rxcharacteristic = service.characteristics
          .firstWhere((element) => element.uuid == _rxcharacteristicId);
      print("BLE: characteristics RX: $_rxcharacteristicId");
      clearBuffer();
      _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsConsultando, 0));
      await ajusteMTU(device);
      var txcharacteristic = service.characteristics
          .firstWhere((element) => element.uuid == _txcharacteristicId);
      print("BLE: characteristics TX: $_txcharacteristicId");

      print("BLE: binding notificação em rx");

      listenRxSubs = rxcharacteristic.value.listen((value) async {
        print("BLE: receiving... $value");
        if (value.isEmpty) {
          print("BLE: EMPTY DATA");
          // sair caso não vier dados
          return;
        } else if (value.first == 10) {
          String dado = "{'get':'get'}";
          Future.delayed(const Duration(milliseconds: 5), () async {
            await txcharacteristic.write(dado.codeUnits, withoutResponse: true);
          });
        } else {
          String dado = String.fromCharCodes(value);
          if (dado.contains('pet')) {
            var obj = jsonDecode(dado);
            AnimalModel animal = AnimalModel.fromJson(obj);
            print(animal);
            resolv(animal);
            await listenRxSubs?.cancel();
            print("BLE: fim gravacao");
            await device.disconnect();
            print("BLE: disconected");
            _estadoStream.sink.add(buffer);
            _progressoStream.sink
                .add(SpotStatus(BleStatusEnum.blsDesconectado, 0));

            return;
          }
        }
      }, onError: (e) {
        listenRxSubs?.cancel();
        print("BLE: erro rx: $e");
      });
      await rxcharacteristic.setNotifyValue(true);
      Future.delayed(const Duration(milliseconds: 100), () async {
        print("BLE: configure server for new _MTU: $_mtu");
        Map<String, String> parametros = {'mtu': "$_mtu"};
        var msg = jsonEncode(parametros).codeUnits;

        print("BLE: _MTU chars $_mtu");
        await txcharacteristic.write(msg, withoutResponse: true);
      });
    } catch (e) {
      print("BLE: erro discovering services: $e");
    }
  }

  void clearBuffer() {
    buffer = "";
    _bytesreceived = 0;
    _datalen = 0;
  }

  var lastStr = "";
  void addToBuffer(List<int> value) {
    String str = utf8.decode(value);
    if (str != lastStr) {
      lastStr = str;
      buffer += str;
      int progresso = (buffer.length / _datalen * 100).floor();
      _progressoStream.sink
          .add(SpotStatus(BleStatusEnum.blsTransmitindo, progresso));

      print("BLE: [${buffer.length}/$_datalen] $str");
    }
  }

  Future<void> ajusteMTU(device) async {
    try {
      int xMtu = await device.mtu.first;
      int tente = 3;
      while (xMtu < 185 && tente > 0) {
        print("BLE: _MTU SIZE: $xMtu requests for 185");
        await Future.delayed(const Duration(milliseconds: 100));
        await device.requestMtu(185);
        await Future.delayed(const Duration(milliseconds: 300));
        xMtu = await device.mtu.first;
        tente--;
        print("BLE: _MTU SIZE NOW: $xMtu.");
      }

      print("BLE: _MTU SIZE: $xMtu OK!");

      _mtu = xMtu;
    } catch (e) {
      print('BLE: $e');
    }
  }

  Future<void> disconnectBLE() async {
    List<BluetoothDevice> devices = await _flutterBlue.connectedDevices;
    for (var i = 0; i < devices.length; i++) {
      BluetoothDevice device = devices[i];

      print("Desconectando ${device.id}");
      await device.disconnect();
      print("Desconectado");
    }
  }

  @override
  Future<void> gravar(AnimalModel cachorro) async {
    scanSubs?.cancel();
    await listenRxSubs?.cancel();
    await _flutterBlue.stopScan();
    await disconnectBLE();
    _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsDesconectado, 0));
    buffer = "";
    _datalen = 0;
    _bytesreceived = 0;
    _connecting = false;

    _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsBuscando, 0));
    scanSubs = _flutterBlue.scan().listen(
      (event) {
        print("Desconectando ${event.device.name}");
        if (!_connecting && event.device.name.startsWith("AuMiau")) {
          scanSubs?.cancel();

          _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsBuscando, 0));
          _connecting = true;
          gravarParaDispositivo(event.device, cachorro);
        }
      },
    );
  }

  @override
  Future<void> gravarParaDispositivo(
      BluetoothDevice device, AnimalModel cachorro) async {
    await _flutterBlue.stopScan();
    print('BLE: ${device.name} found!');
    _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsEncontrado, 0));

    var conectados = await _flutterBlue.connectedDevices;
    if (conectados.isEmpty) {
      try {
        _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsConectando, 0));
        await device.connect();
      } catch (e) {
        _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsFalhou, 0));
        print('BLE: $e');
      }
    }
    _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsConectado, 0));
    print('BLE: ${device.name} conectado!');
    print("BLE: Descobrir services. ");
    try {
      var services = await device.discoverServices();
      print("BLE: services found (${services.length})");
      var service =
          services.firstWhere((element) => element.uuid == _serviceId);
      var rxcharacteristic = service.characteristics
          .firstWhere((element) => element.uuid == _rxcharacteristicId);
      print("BLE: characteristics RX: $_rxcharacteristicId");
      clearBuffer();
      _progressoStream.sink.add(SpotStatus(BleStatusEnum.blsConsultando, 0));
      await ajusteMTU(device);
      var txcharacteristic = service.characteristics
          .firstWhere((element) => element.uuid == _txcharacteristicId);
      print("BLE: characteristics TX: $_txcharacteristicId");

      print("BLE: binding notificação em rx");

      listenRxSubs = rxcharacteristic.value.listen((value) async {
        print("BLE: receiving... $value");
        if (value.isEmpty) {
          print("BLE: EMPTY DATA");
          // sair caso não vier dados
          return;
        } else if (value.first == 10) {
          String dado = json.encode(cachorro.toJson());
          print(dado);
//          await txcharacteristic.setNotifyValue(true);
          Future.delayed(
            const Duration(milliseconds: 5),
            () async {
              await txcharacteristic.write(dado.codeUnits,
                  withoutResponse: true);
              print("BLE: fim gravacao");
              await listenRxSubs?.cancel();
              await device.disconnect();
              print("BLE: disconected");
              _estadoStream.sink.add(buffer);
              _progressoStream.sink
                  .add(SpotStatus(BleStatusEnum.blsDesconectado, 0));
              return;
            },
          );
        }
      }, onError: (e) {
        listenRxSubs?.cancel();
        print("BLE: erro rx: $e");
      });
      await rxcharacteristic.setNotifyValue(true);
      Future.delayed(const Duration(milliseconds: 100), () async {
        print("BLE: configure server for new _MTU: $_mtu");
        Map<String, String> parametros = {'mtu': "$_mtu"};
        var msg = jsonEncode(parametros).codeUnits;

        print("BLE: _MTU chars $_mtu");
        await txcharacteristic.write(msg, withoutResponse: true);
      });
    } catch (e) {
      print("BLE: erro discovering services: $e");
    }
  }

  @override
  Stream<String> get estado => _estadoStream.stream;

  @override
  Stream<SpotStatus> get progresso => _progressoStream.stream;
}
