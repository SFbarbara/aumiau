import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcc/app_store.dart';
import 'package:tcc/input_field.dart';
import 'package:tcc/models/animal_model.dart';

import '../repository/animal_repository.dart';

class CadastroAnimal extends StatefulWidget {
  final AnimalModel? animal;
  const CadastroAnimal({this.animal, Key? key}) : super(key: key);

  @override
  State<CadastroAnimal> createState() => _CadastroAnimalState();
}

class _CadastroAnimalState extends State<CadastroAnimal> {
  late AnimalModel animal;
  var gravando = false;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final appStore = Provider.of<AppStore>(context, listen: false);
    if (widget.animal != null) {
      animal = widget.animal!;
    } else {
      animal = AnimalModel(usuarioId: appStore.autenticado.value.id!, nome: "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro do animal"),
      ),
      body: Form(
        key: _key,
        child: Column(
          children: [
            InputField(
              "Nome",
              Icons.autofps_select_sharp,
              false,
              initialValue: animal.nome,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Campo não pode ficar vazio";
                }
                return null;
              },
              onsaved: (value) {
                animal.nome = value;
              },
            ),
            Row(
              children: [
                gravando
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.red)),
                        ),
                      )
                    : Expanded(
                        child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_key.currentState!.validate()) {
                                _key.currentState!.save();

                                setState(() {
                                  gravando = true;
                                });
                                try {
                                  await _salvarAnimal(animal);
                                  setState(() {
                                    gravando = false;
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        "Cachorro cadastrado com sucesso!"),
                                  ));
                                } catch (e) {
                                  setState(() {
                                    gravando = false;
                                  });
                                }
                                Navigator.pop(context);
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
    );
  }

  Future<void> _salvarAnimal(AnimalModel animal) async {
    await AnimalRepository().salvar(animal);
  }
}
