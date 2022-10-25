class AnimalModel {
  String? id;
  String? nome;
  String? usuarioId;

  AnimalModel({this.id, this.nome, this.usuarioId});

  factory AnimalModel.fromJson(Map map) {
    return AnimalModel(
        id: map["id"], nome: map["nome"], usuarioId: map["usuarioId"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": this.id, "nome": this.nome, "usuarioId": this.usuarioId};
  }
}
