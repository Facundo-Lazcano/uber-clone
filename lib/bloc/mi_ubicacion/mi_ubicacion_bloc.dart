import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

part 'mi_ubicacion_event.dart';
part 'mi_ubicacion_state.dart';

class MiUbicacionBloc extends Bloc<MiUbicacionEvent, MiUbicacionState> {
  MiUbicacionBloc() : super(MiUbicacionState());

  StreamSubscription<Position> _positionSubscription;

  void iniciarSeguimiento() {
    _positionSubscription = GeolocatorPlatform.instance
        .getPositionStream(
            desiredAccuracy: LocationAccuracy.high, distanceFilter: 10)
        .listen((Position position) {
      final nuevaUbicacion = new LatLng(position.latitude, position.longitude);
      add(OnUbucacionCambio(nuevaUbicacion));
    });
  }

  void cancelarSeguimiento() {
    _positionSubscription?.cancel();
  }

  @override
  Stream<MiUbicacionState> mapEventToState(
    MiUbicacionEvent event,
  ) async* {
    if (event is OnUbucacionCambio) {
      yield state.copyWith(existeUbicacion: true, ubicacion: event.ubicacion);
    }
  }
}
