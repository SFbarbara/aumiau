import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/usuario_model.dart';

class AppStore {
  ValueNotifier<UsuarioModel> autenticado =
      ValueNotifier<UsuarioModel>(UsuarioModel());

  bool estaAutenticado() {
    return autenticado.value.id != null;
  }

  autenticacao() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        // ignore: avoid_print
        print('Usuário fez logout!');
        autenticado.value = UsuarioModel();
      } else {
        // ignore: avoid_print
        print('Usuario fez SigIn!');
        var snapshot =
            FirebaseFirestore.instance.collection('usuarios').doc(user.uid);

        var doc = await snapshot.get();
        if (doc.exists) {
          Map<String, dynamic>? fbUser = doc.data();
          autenticado.value = UsuarioModel(
              id: user.uid, nome: fbUser!['nome'], email: fbUser['email']);
        } else {
          autenticado.value = UsuarioModel(id: user.uid, nome: "");
        }
      }
    });
  }
}
