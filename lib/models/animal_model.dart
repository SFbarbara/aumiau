import 'package:tcc/models/usuario_model.dart';

class AnimalModel {
  String? id;
  String? nome;
  UsuarioModel? usuario;

  AnimalModel({
    this.id,
    this.nome,
    this.usuario,
  });

  factory AnimalModel.fromJson(Map map) {
    return AnimalModel(id: map["id"], nome: map["nome"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "nome": nome, "usuario": usuario!.toJson()};
  }

  @override
  String toString() {
    return "$nome $usuario";
  }
}
