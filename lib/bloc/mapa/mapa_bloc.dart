import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapas_app/helpers/helpers.dart';
import 'package:mapas_app/theme/uber_map.dart';
import 'package:meta/meta.dart';

part 'mapa_event.dart';
part 'mapa_state.dart';

class MapaBloc extends Bloc<MapaEvent, MapaState> {
  MapaBloc() : super(MapaState());

  // ignore: unused_field
  // Controlador del mapa
  GoogleMapController _mapController;

  // Polyline
  Polyline _miRuta = new Polyline(
      polylineId: PolylineId('mi_ruta'), width: 4, color: Colors.transparent);

  Polyline _miRutaDestino = new Polyline(
      polylineId: PolylineId('mi_ruta_destino'), width: 4, color: Colors.black);

  void initMapa(GoogleMapController controller) {
    if (!state.mapaListo) {
      this._mapController = controller;
      this._mapController.setMapStyle(jsonEncode(uberMapTheme));

      add(OnMapaListo());
    }
  }

  void moverCamara(LatLng destino) {
    final cameraUpdate = CameraUpdate.newLatLng(destino);
    this._mapController?.animateCamera(cameraUpdate);
  }

  @override
  Stream<MapaState> mapEventToState(
    MapaEvent event,
  ) async* {
    if (event is OnMapaListo) {
      yield state.copyWith(mapaListo: true);
    } else if (event is OnLocationChange) {
      yield* _onLocationChange(event);
    } else if (event is OnPolyline) {
      yield* _onPolyline(event);
    } else if (event is OnSeguirUbicacion) {
      yield* _onSeguirUbicacion(event);
    } else if (event is OnMovioMapa) {
      yield state.copyWith(ubicacionCentral: event.centroMapa);
    } else if (event is OnCrearRutaInicioDestino) {
      yield* _onCrearRutaInicioDestino(event);
    }
  }

  Stream<MapaState> _onLocationChange(OnLocationChange event) async* {
    if (state.seguirUbicacion) {
      moverCamara(event.ubicacion);
    }
    final points = [..._miRuta.points, event.ubicacion];
    this._miRuta = this._miRuta.copyWith(pointsParam: points);

    final currentPolylines = state.polylines;
    currentPolylines['mi_ruta'] = this._miRuta;

    yield state.copyWith(polylines: currentPolylines);
  }

  Stream<MapaState> _onPolyline(OnPolyline event) async* {
    if (!state.dibujarRecorrido) {
      this._miRuta = this._miRuta.copyWith(colorParam: Colors.blue[600]);
    } else {
      this._miRuta = this._miRuta.copyWith(colorParam: Colors.transparent);
    }

    final currentPolylines = state.polylines;
    currentPolylines['mi_ruta'] = this._miRuta;

    yield state.copyWith(
        polylines: currentPolylines, dibujarRecorrido: !state.dibujarRecorrido);
  }

  Stream<MapaState> _onSeguirUbicacion(OnSeguirUbicacion event) async* {
    if (!state.seguirUbicacion) {
      this.moverCamara(this._miRuta.points[this._miRuta.points.length - 1]);
    }
    yield state.copyWith(seguirUbicacion: !state.seguirUbicacion);
  }

  Stream<MapaState> _onCrearRutaInicioDestino(
      OnCrearRutaInicioDestino event) async* {
    _miRutaDestino = _miRutaDestino.copyWith(pointsParam: event.rutaCoord);

    final currentPolylines = state.polylines;
    currentPolylines['mi_ruta_destino'] = this._miRutaDestino;

    // Icono inicio
    // final iconInicio = await getAssetImageMarker();
    final iconInicio = await getMarkerInicioIcon(event.duracion.toInt());
    // final iconDestino = await getNetworkImageMarker();
    final iconDestino =
        await getMarkerDestinoIcon(event.nombreDestino, event.distancia);

    // Markers
    final markerInicio = new Marker(
      markerId: MarkerId('inicio'),
      anchor: Offset(0, 1),
      position: event.rutaCoord[0],
      icon: iconInicio,
      // infoWindow: InfoWindow(
      //     title: 'Ubicacion Actual',
      //     snippet:
      //         'Duración recorrido: ${(event.duracion / 60).floor()} minutos')
    );

    double kilometros = event.distancia / 1000;
    kilometros = (kilometros * 100).floor().toDouble();
    kilometros = kilometros / 100;
    final markerDestino = new Marker(
      markerId: MarkerId('destino'),
      anchor: Offset(0, 1),
      icon: iconDestino,
      // infoWindow:
      //     InfoWindow(title: event.nombreDestino, snippet: '$kilometros km'),
      position: event.rutaCoord[event.rutaCoord.length - 1],
    );

    final newMarkers = {...state.markers};

    newMarkers['inicio'] = markerInicio;
    newMarkers['destino'] = markerDestino;

    Future.delayed(Duration(milliseconds: 300)).then((value) {
      _mapController.showMarkerInfoWindow(
        MarkerId('destino'),
      );
    });

    yield state.copyWith(polylines: currentPolylines, markers: newMarkers);
  }
}
