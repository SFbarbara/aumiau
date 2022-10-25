import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc/models/usuario_model.dart';

class UsuarioHelper {
  salvar(UsuarioModel usuario) async {
    final _prefs = await SharedPreferences.getInstance();
    _prefs.setString("usuario", usuario.toJson().toString());
  }

  recuperar() async {
    final _prefs = await SharedPreferences.getInstance();
    return _prefs.getString("usuario");
  }
}
