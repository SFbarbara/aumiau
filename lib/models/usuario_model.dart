class UsuarioModel {
  String? id;
  String? nome;
  String? telefone;
  String? email;
  String? senha;
  String? uid;

  UsuarioModel({this.id, this.nome, this.telefone, this.email});

  factory UsuarioModel.fromJson(Map map) {
    return UsuarioModel(
        id: map["id"],
        nome: map["nome"],
        telefone: map["telefone"],
        email: map["email"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "nome": this.nome,
      "telefone": this.telefone,
      "email": this.email
    };
  }

  String toString() {
    return "$nome $telefone";
  }
}
