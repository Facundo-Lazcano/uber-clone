part of 'widgets.dart';

class MarcadorManual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusquedaBloc, BusquedaState>(
      builder: (context, state) {
        if (state.seleccionManual) {
          return _BuildMarcadorManual();
        } else {
          return Container();
        }
      },
    );
  }
}

class _BuildMarcadorManual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 70,
          left: 20,
          child: FadeInLeft(
            duration: Duration(milliseconds: 200),
            child: CircleAvatar(
              maxRadius: 25,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                ),
                onPressed: () {
                  BlocProvider.of<BusquedaBloc>(context)
                      .add(OnDesactivateManualMarker());
                },
              ),
            ),
          ),
        ),
        Center(
          child: Transform.translate(
              offset: Offset(0, -12),
              child: BounceInDown(
                  from: 200, child: Icon(Icons.location_on, size: 50))),
        ),
        Positioned(
          child: FadeIn(
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width - 120,
              child: Text('Confirmar Destino',
                  style: TextStyle(
                    color: Colors.white,
                  )),
              color: Colors.black,
              shape: StadiumBorder(),
              elevation: 0,
              splashColor: Colors.transparent,
              onPressed: () {
                this.calcularDestino(context);
              },
            ),
          ),
          bottom: 70,
          left: 40,
        )
      ],
    );
  }

  void calcularDestino(BuildContext context) async {
    calculandoAlerta(context);
    final trafficService = new TrafficService();
    final inicio = BlocProvider.of<MiUbicacionBloc>(context).state.ubicacion;
    final destino = BlocProvider.of<MapaBloc>(context).state.ubicacionCentral;

    final placesResponse = await trafficService.getCoordsInfo(destino);

    final trafficResponse =
        await trafficService.getCoordsInicioYDestino(inicio, destino);

    final geometry = trafficResponse.routes[0].geometry;
    final duration = trafficResponse.routes[0].duration;
    final distance = trafficResponse.routes[0].distance;
    final nombreDestino = placesResponse.features[0].textEs;
    final points = Poly.Polyline.Decode(encodedString: geometry, precision: 6)
        .decodedCoords;

    final List<LatLng> rutaCoords =
        points.map((point) => LatLng(point[0], point[1])).toList();
    BlocProvider.of<MapaBloc>(context).add(OnCrearRutaInicioDestino(
        rutaCoords, distance, duration, nombreDestino));

    Navigator.of(context).pop();
    BlocProvider.of<BusquedaBloc>(context).add(OnDesactivateManualMarker());
  }
}
