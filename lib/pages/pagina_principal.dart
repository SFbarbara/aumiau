import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcc/models/animal_model.dart';
import 'package:tcc/pages/cadastro_animal.dart';
import 'package:tcc/pages/cadastro_usuario.dart';
import 'package:tcc/pages/pagina_login.dart';
import 'package:tcc/repository/animal_repository.dart';
import 'package:tcc/repository/bluetooth/cliente_ble_abstract.dart';
import 'package:tcc/repository/bluetooth/spot_status.dart';
import '../app_store.dart';
import '../repository/usuario_repository.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({Key? key}) : super(key: key);

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  late ClienteBleAbstract ble;
  ValueNotifier<bool> consultando = ValueNotifier(false);
  ValueNotifier<SpotStatus> progresso =
      ValueNotifier(SpotStatus(BleStatusEnum.blsDesconectado, 0));
  AnimalModel? resultado;

  @override
  initState() {
    super.initState();
    final ble = Provider.of<ClienteBleAbstract>(context, listen: false);
    ble.progresso.listen((value) {
      print("PROGRESSO: $value");
      progresso.value = value;
    });
    ble.estado.listen((buffer) {
      consultando.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appStore = Provider.of<AppStore>(context);

    return ValueListenableBuilder(
        valueListenable: appStore.autenticado,
        builder: (context, value, child) {
          return SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundImage: ExactAssetImage('Imagens/logo.png'),
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: kElevationToShadow[5],
                        ),
                      ),
                      const Text(
                        "AuMiau",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: const Text(
                        "Chegue a no minimo 6 metros do animal e aperte o botão de verificar para saber o telefone do dono do animal.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: progresso,
                      builder: (context, value, child) =>
                          Text("${_statuText(value)}"),
                    ),
                    appStore.autenticado.value.id == null
                        ? Container()
                        : SizedBox(
                            height: 200,
                            child: FutureBuilder<List<AnimalModel>>(
                              future: AnimalRepository()
                                  .listar(appStore.autenticado.value),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List<AnimalModel>? pets = snapshot.data;
                                  return Container(
                                    color: Colors.black26,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: (pets?.length ?? 0) + 1,
                                      itemBuilder: (context, index) {
                                        AnimalModel? pet;
                                        if (index == 0) {
                                          return Container(
                                              color: Colors.grey[100],
                                              width: 100,
                                              child: Row(
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Icon(Icons.pets,
                                                          size: 60),
                                                      Text(
                                                        "Seus\nanimais",
                                                        style: TextStyle(
                                                            fontSize: 24),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ));
                                        }

                                        if (pets != null && pets.length > 0) {
                                          pet = pets[index - 1];
                                        }
                                        return Card(
                                            child: Container(
                                          padding: EdgeInsets.all(8),
                                          height: 134,
                                          width: 200,
                                          child: Column(
                                            children: [
                                              const Icon(Icons.pets, size: 60),
                                              SizedBox(
                                                height: 14,
                                              ),
                                              Text("${pet?.nome}",
                                                  style:
                                                      TextStyle(fontSize: 24)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              FittedBox(
                                                  child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  TextButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              AlertDialog(
                                                            title: Text(
                                                                "Confirma excluir o animal?"),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  AnimalRepository()
                                                                      .excluir(
                                                                          pet!);
                                                                },
                                                                child:
                                                                    Text("Sim"),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    Text("Não"),
                                                              )
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      child: Column(
                                                        children: const [
                                                          Icon(Icons.delete),
                                                          Text("Excluir"),
                                                        ],
                                                      )),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .push(
                                                                MaterialPageRoute(
                                                          builder: (context) =>
                                                              CadastroAnimal(
                                                                  animal: pet),
                                                        ));
                                                      },
                                                      child: Column(
                                                        children: const [
                                                          Icon(Icons
                                                              .edit_outlined),
                                                          Text("Alterar"),
                                                        ],
                                                      )),
                                                  TextButton(
                                                      onPressed: () async {
                                                        var ble = Provider.of<
                                                                ClienteBleAbstract>(
                                                            context);
                                                        try {
                                                          await ble
                                                              .gravar(pet!);
                                                        } catch (e) {
                                                          print(e);
                                                        }
                                                      },
                                                      child: Column(
                                                        children: const [
                                                          Icon(Icons.bluetooth),
                                                          Text("Transmitir"),
                                                        ],
                                                      ))
                                                ],
                                              ))
                                            ],
                                          ),
                                        ));
                                      },
                                    ),
                                  );
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.red),
                                  ));
                                }
                              },
                            ),
                          ),
                    SizedBox(
                      width: 300,
                      height: 150,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blueGrey[300],
                            side:
                                const BorderSide(width: 2, color: Colors.black),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () async {
                            var ble = Provider.of<ClienteBleAbstract>(context,
                                listen: false);
                            try {
                              await ble.ler((animal) {
                                ScaffoldMessenger.of(context)
                                    .showMaterialBanner(MaterialBanner(
                                  backgroundColor: Colors.white,
                                  content: Center(
                                    child: Text(animal.toString()),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Fechar"),
                                      onPressed: () => Navigator.pop(context),
                                    )
                                  ],
                                ));
                              });
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.bluetooth,
                                size: 60,
                              ),
                              Text("Verifique o animal",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  )),
                            ],
                          )),
                    ),
                  ],
                ),
                drawer: !appStore.estaAutenticado()
                    ? null
                    : Drawer(
                        backgroundColor: Colors.blueGrey,
                        elevation: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.account_circle_rounded,
                                      color: Colors.white),
                                  label: const Text(
                                    "Perfil",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  onPressed: (() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CadastroUsuario(
                                              pusuario:
                                                  appStore.autenticado.value)),
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    alignment: Alignment.bottomRight,
                                    child: IconButton(
                                      onPressed: () async {
                                        await UsuarioRepository().logout();
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(Icons.logout,
                                          color: Colors.white),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                floatingActionButton: appStore.estaAutenticado()
                    ? FloatingActionButton(
                        onPressed: (() async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => CadastroAnimal()),
                          );
                          setState(() {});
                        }),
                        child: const Icon(Icons.pets),
                      )
                    : FloatingActionButton(
                        onPressed: (() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PaginaLogin()),
                          );
                        }),
                        child: const Icon(Icons.login_sharp),
                      )),
          );
        });
  }

  _statuText(BleStatusEnum? value) {
    switch (value) {
      case BleStatusEnum.blsBuscando:
        "Buscando coleira";
        break;
      case BleStatusEnum.blsConectado:
        "Coleira conectada";
        break;
      case BleStatusEnum.blsConectando:
        "Conectando a coleira";
        break;
      case BleStatusEnum.blsConsultando:
        "Consultando coleira";
        break;
      case BleStatusEnum.blsDesconectado:
        "Coleira desconectada";
        break;
      case BleStatusEnum.blsDistante:
        "Coleira distante";
        break;
      case BleStatusEnum.blsEncontrado:
        "Encontrado";
        break;
      case BleStatusEnum.blsFalhou:
        "Falhou conexão";
        break;
      case BleStatusEnum.blsNaoEncontrado:
        "Não encontrado";
        break;
      case BleStatusEnum.blsTransmitindo:
        "Trasmitindo informações";
        break;

      default:
    }
  }
}
