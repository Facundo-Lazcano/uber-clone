part of 'busqueda_bloc.dart';

@immutable
abstract class BusquedaEvent {}

class OnActivateManualMarker extends BusquedaEvent {}

class OnDesactivateManualMarker extends BusquedaEvent {}

class OnAgregarHistorial extends BusquedaEvent {
  final SearchResult result;

  OnAgregarHistorial(this.result);
}
