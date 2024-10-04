import 'package:get/get.dart';
import 'package:planetcombo/models/planet_transit.dart';

class PlanetTransitController extends GetxController {
  static PlanetTransitController? _instance;

  static PlanetTransitController getInstance() {
    _instance ??= PlanetTransitController();
    return _instance!;
  }

 RxString sentPlanet = 'JU'.obs;

  Rx<PlanetTransitModel> planet = PlanetTransitModel().obs;

}