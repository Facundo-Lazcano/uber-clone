part of 'mapa_bloc.dart';

@immutable
abstract class MapaEvent {}

class OnMapaListo extends MapaEvent {}

class OnLocationChange extends MapaEvent {
  final LatLng ubicacion;
  OnLocationChange(this.ubicacion);
}

class OnPolyline extends MapaEvent {}

class OnSeguirUbicacion extends MapaEvent {}

class OnMovioMapa extends MapaEvent {
  final LatLng centroMapa;

  OnMovioMapa({this.centroMapa});
}

class OnCrearRutaInicioDestino extends MapaEvent {
  final List<LatLng> rutaCoord;
  final double distancia;
  final double duracion;
  final String nombreDestino;

  OnCrearRutaInicioDestino(
      this.rutaCoord, this.distancia, this.duracion, this.nombreDestino);
}
