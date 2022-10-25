import '../../models/animal_model.dart';
import 'spot_status.dart';

abstract class ClienteBleAbstract {
  Stream<String> get estado;
  Stream<SpotStatus> get progresso;

  Future<void> ler(Function(AnimalModel animal) resolv);
  Future<void> gravar(AnimalModel cachorro);
}
