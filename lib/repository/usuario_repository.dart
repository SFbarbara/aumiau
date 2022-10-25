import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tcc/models/usuario_model.dart';

class UsuarioRepository {
  Future<void> salvar(UsuarioModel usuario) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var col = firestore.collection("usuarios");
    var doc = await col.doc(usuario.id).get();
    if (doc.exists) {
      await col.doc(usuario.id).update(usuario.toJson());
    } else {
      await col.doc(usuario.id).set(usuario.toJson());
    }
  }

  logout() async {
    await FirebaseAuth.instance.signOut();
  }

  recuperar(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> login(UsuarioModel usuario) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: usuario.email!.trim(), password: usuario.senha!);
  }
}
