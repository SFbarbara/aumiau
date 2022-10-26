import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc/models/animal_model.dart';
import 'package:tcc/models/usuario_model.dart';
import 'package:tcc/repository/usuario_repository.dart';

class AnimalRepository {
  Future<void> salvar(AnimalModel animal) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var col = firestore.collection("animais");
    if (animal.id == null) {
      DocumentReference<Map<String, dynamic>> doc =
          await col.add(animal.toJson());
      animal.id = doc.id;
      await doc.update({'id': doc.id});
    } else {
      // ignore: unused_local_variable
      var doc = await col.doc(animal.id).get();
      await col.doc(animal.id).update(animal.toJson());
    }
  }

  Future<List<AnimalModel>> listar(UsuarioModel autenticado) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var col = firestore.collection("animais");
    Query<Map<String, dynamic>> ref =
        col.where("usuarioId", isEqualTo: autenticado.id);
    QuerySnapshot<Map<String, dynamic>> snapshot = await ref.get();

    return snapshot.docs.map((e) => AnimalModel.fromJson(e.data())).toList();
  }

  Future<void> excluir(AnimalModel pet) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.doc("animais/${pet.id}").delete();
  }
}
