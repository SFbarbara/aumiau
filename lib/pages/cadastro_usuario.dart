import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_store.dart';
import '../input_field.dart';
import '../models/usuario_model.dart';
import '../repository/usuario_repository.dart';

class CadastroUsuario extends StatefulWidget {
  final UsuarioModel? pusuario;
  const CadastroUsuario({this.pusuario, Key? key}) : super(key: key);

  @override
  State<CadastroUsuario> createState() => _CadastroUsuarioState();
}

class _CadastroUsuarioState extends State<CadastroUsuario> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  UsuarioModel pusuario = UsuarioModel();
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.pusuario != null) {
      pusuario = widget.pusuario!;
    }
  }

  @override
  Widget build(BuildContext context) {
    String senha = "";
    return Scaffold(
      appBar: AppBar(title: Text("Cadastro do usuário")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _key,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  "Nome",
                  Icons.autofps_select_sharp,
                  false,
                  initialValue: pusuario.nome,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Campo não pode ficar vazio";
                    }
                    return null;
                  },
                  onsaved: (value) {
                    pusuario.nome = value;
                  },
                ),
                /*InputField(
                  "Telefone",
                  Icons.phone,
                  false,
                  //inputType: ,
                  initialValue: pusuario.telefone,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Campo não pode ficar vazio";
                    }
                    return null;
                  },
                  onsaved: (value) {
                    pusuario.nome = value;
                  },
                ),*/
                InputField(
                  "Email",
                  Icons.mail,
                  false,
                  initialValue: pusuario.email,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return "Informe um email válido";
                    }
                    return null;
                  },
                  onsaved: (value) {
                    pusuario.email = value;
                  },
                ),
                InputField(
                  "Senha",
                  Icons.password,
                  true,
                  validator: (value) {
                    if ((value!.isEmpty || value.length < 3) &&
                        (pusuario.id == null)) {
                      return "A senha deve ter ao menos 3 caracteres";
                    } else {
                      senha = value;
                    }
                    return null;
                  },
                  onsaved: (value) {
                    pusuario.senha = senha;
                  },
                ),
                InputField(
                  "Confirmação da senha",
                  Icons.add_to_photos_outlined,
                  true,
                  validator: (value) {
                    if (value != senha) {
                      return "Confirmação de senha deve ser igual a senha";
                    }
                    return null;
                  },
                ),
                salvando
                    ? Center(
                        child: Column(
                        children: const [
                          CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.black)),
                          Text("Aguarde! Salvando..."),
                        ],
                      ))
                    : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                                onPressed: () async {
                                  setState(() {
                                    salvando = true;
                                  });
                                  if (_key.currentState!.validate()) {
                                    _key.currentState!.save();

                                    try {
                                      await salvar(pusuario);
                                      setState(() {
                                        salvando = false;
                                      });
                                    } catch (e) {
                                      print(e);
                                      setState(() {
                                        salvando = false;
                                      });
                                    }
                                  }
                                },
                                icon: const Icon(Icons.save),
                                label: const Text("Salvar")),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  salvar(UsuarioModel pusuario) async {
    final appStore = Provider.of<AppStore>(context, listen: false);
    try {
      if (pusuario.id == null) {
        //se for pusuario novo
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: pusuario.email!, password: pusuario.senha!);
        pusuario.id = userCredential.user!.uid;
      } else if (pusuario.senha?.isNotEmpty ?? false) {
        await FirebaseAuth.instance.currentUser!
            .updatePassword(pusuario.senha!);
      }
      await UsuarioRepository().salvar(pusuario);
      appStore.autenticado.value = pusuario;
      Navigator.of(context).pop(pusuario);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A senha informada é muito fácil.')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Email já foi utilizado por outra conta.')));
      } else if (e.code == "requires-recent-login") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Para alterar a senha é necessário sair e se logar novamente.')));
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}
