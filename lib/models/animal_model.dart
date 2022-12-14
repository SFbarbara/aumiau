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

  Map<String, dynamic> toDevice() {
    return {"pet": id, "msg": "$nome-${usuario?.nome}-${usuario?.telefone}"};
  }

  Map<String, dynamic> toFirebase() {
    return {"pet": id, "nome": nome, "usuarioId": usuario?.id};
  }

  @override
  String toString() {
    return "$nome $usuario";
  }
}
