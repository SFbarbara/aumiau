import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcc/app_store.dart';
import 'package:tcc/models/usuario_model.dart';
import 'package:tcc/pages/cadastro_usuario.dart';
import 'package:tcc/repository/usuario_repository.dart';

import '../input_field.dart';

class PaginaLogin extends StatefulWidget {
  const PaginaLogin({Key? key}) : super(key: key);

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  UsuarioModel usuario = UsuarioModel();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: const CircleAvatar(
                      backgroundImage: ExactAssetImage('Imagens/logo.png'),
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: kElevationToShadow[5],
                    ),
                  ),
                  const Text(
                    "AuMiau",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 100,
              ),
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                  width: 400,
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _key,
                    child: Column(
                      children: [
                        InputField(
                          "email",
                          Icons.email_outlined,
                          false,
                          onsaved: (p0) => usuario.email = p0,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        InputField(
                          "senha",
                          Icons.password,
                          true,
                          onsaved: (p0) => usuario.senha = p0,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        botaoEntrar(),
                        botaoEsqueceu(context),
                        botaoCadastrar(context),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  botaoEntrar() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              try {
                _key.currentState!.save();
                await UsuarioRepository().login(usuario);
                Navigator.pop(context);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'usuário não encontrado!') {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Usuário não encontrado!")));
                } else if (e.code == 'Senha Incorreta') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Login e/ou senha não são válidos!")));
                } else if (e.code == 'too-many-requests') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("Usuario bloqueado por muitas tentativas")));
                }
              }
            },
            child: const Text(
              "Entrar",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  botaoEsqueceu(context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Esqueceu a senha?",
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          TextButton(
            onPressed: () async {
              _key.currentState?.save();
              try {
                await UsuarioRepository().recuperar(usuario.email!);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Código de recuperação enviado no email")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Erro: o endereço de e-mail está mal formatado ($e)")));
              }
            },
            child: const Text(
              "Clique aqui",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  botaoCadastrar(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Não tem uma conta.",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CadastroUsuario()),
            );
          },
          child: const Text(
            "Cadastre-se",
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
