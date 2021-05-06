import 'dart:async';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapas_app/helpers/debouncer.dart';
import 'package:mapas_app/models/driving_response.dart';
import 'package:mapas_app/models/places_response.dart';
import 'package:mapas_app/models/search_response.dart';

class TrafficService {
  TrafficService._privateContructor();

  static final TrafficService _instance = TrafficService._privateContructor();
  factory TrafficService() {
    return _instance;
  }

  final _dio = new Dio();
  final debouncer = Debouncer<String>(duration: Duration(milliseconds: 300));

  final StreamController<SearchResponse> _sugerenciasStreamController =
      StreamController<SearchResponse>.broadcast();

  Stream<SearchResponse> get sugerenciasStream =>
      this._sugerenciasStreamController.stream;

  final _baseUrlDir = 'https://api.mapbox.com/directions/v5';
  final _baseUrlGeo = 'https://api.mapbox.com/geocoding/v5';
  final _apiKey =
      'pk.eyJ1Ijoid29tYW8iLCJhIjoiY2ttbWtxZDgwMW01NjJ3czJ1bGtlaHBpNyJ9.QqFauyKZhT_ar0uItvwUnw';

  Future<DrivingResponse> getCoordsInicioYDestino(
      LatLng inicio, LatLng destino) async {
    final coordString =
        '${inicio.longitude},${inicio.latitude};${destino.longitude},${destino.latitude}';
    final url = '$_baseUrlDir/mapbox/driving/$coordString';

    final res = await this._dio.get(url, queryParameters: {
      'alternatives': 'true',
      'geometries': 'polyline6',
      'steps': 'false',
      'access_token': '${this._apiKey}',
      'language': 'es'
    });

    final data = DrivingResponse.fromJson(res.data);

    return data;
  }

  Future<SearchResponse> getResultadosPorQuery(
      String busqueda, LatLng proximidad) async {
    final url = '$_baseUrlGeo/mapbox.places/$busqueda.json';

    try {
      final res = await _dio.get(url, queryParameters: {
        'access_token': this._apiKey,
        'autocomplete': 'true',
        'proximity': '${proximidad.longitude},${proximidad.latitude}',
        'language': 'es'
      });

      final data = searchResponseFromJson(res.data);

      return data;
    } catch (e) {
      print(e);
      return SearchResponse(features: []);
    }
  }

  void getSugerenciasPorQuery(String busqueda, LatLng proximidad) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final resultados = await this.getResultadosPorQuery(value, proximidad);
      this._sugerenciasStreamController.add(resultados);
    };

    final timer = Timer.periodic(Duration(milliseconds: 200), (_) {
      debouncer.value = busqueda;
    });

    Future.delayed(Duration(milliseconds: 201)).then((_) => timer.cancel());
  }

  Future<PlacesResponse> getCoordsInfo(LatLng destinoCoords) async {
    final url =
        '$_baseUrlGeo/mapbox.places/${destinoCoords.longitude},${destinoCoords.latitude}.json';

    final res = await this._dio.get(url,
        queryParameters: {'access_token': '${this._apiKey}', 'language': 'es'});

    final data = placesResponseFromJson(res.data);

    return data;
  }
}
