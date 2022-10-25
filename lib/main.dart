import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcc/repository/bluetooth/cliente_ble.dart';
import 'package:tcc/repository/bluetooth/cliente_ble_abstract.dart';

import 'app_store.dart';
import 'firebase_options.dart';
import 'pages/pagina_principal.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    Provider<AppStore>(create: (context) => AppStore()),
    Provider<ClienteBleAbstract>(create: (context) => ClienteBLE()),
  ], child: AuMiau()));
}

class AuMiau extends StatelessWidget {
  const AuMiau({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStore = Provider.of<AppStore>(context);
    appStore.autenticacao();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AuMiau',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.blueGrey[100],
      ),
      home: PaginaPrincipal(),
    );
  }
}
