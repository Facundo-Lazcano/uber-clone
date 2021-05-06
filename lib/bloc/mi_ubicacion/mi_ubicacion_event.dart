part of 'mi_ubicacion_bloc.dart';

@immutable
abstract class MiUbicacionEvent {}

class OnUbucacionCambio extends MiUbicacionEvent {
  final LatLng ubicacion;

  OnUbucacionCambio(this.ubicacion);
}
