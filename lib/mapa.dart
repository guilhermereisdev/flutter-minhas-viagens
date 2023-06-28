import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapa extends StatefulWidget {
  Mapa({super.key, this.idViagem});

  final String? idViagem;

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _marcadores = {};
  CameraPosition _posicaoCamera = const CameraPosition(
    target: LatLng(-23.562436, -46.655005),
    zoom: 18,
  );

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _exibirMarcador(LatLng latLng) async {
    List<Placemark> listaEnderecos =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (listaEnderecos.isNotEmpty) {
      Placemark endereco = listaEnderecos[0];
      String rua = endereco.thoroughfare.toString();
      String estado = endereco.administrativeArea.toString();
      String pais = endereco.country.toString();
      String abrevPais = endereco.isoCountryCode.toString();
      String locality = endereco.locality.toString();
      String name = endereco.name.toString();
      String cep = endereco.postalCode.toString();
      String abrevRua = endereco.street.toString();
      String cidade = endereco.subAdministrativeArea.toString();
      String bairro = endereco.subLocality.toString();
      String numero = endereco.subThoroughfare.toString();

      Marker marcador = Marker(
        markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
        position: latLng,
        infoWindow: InfoWindow(
          title: "$rua, $numero",
          snippet: "Bairro $bairro, $cidade, $estado - $abrevPais",
        ),
      );
      setState(() {
        _marcadores.add(marcador);
        print("rua: $rua"
            "\nnumero: $numero"
            "\nbairro: $bairro"
            "\ncidade: $cidade"
            "\nestado: $estado"
            "\npais: $pais"
            "\nabrevPais: $abrevPais"
            "\ncep: $cep"
            "\nlocality: $locality"
            "\nname: $name"
            "\nabrevRua: $abrevRua");
      });
    } else {
      print("lista empty");
    }
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(_posicaoCamera),
    );
  }

  _adicionarListenerLocalizacao() {
    Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best)
        .listen((Position position) {
      setState(() {
        _posicaoCamera = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 18,
        );
        _movimentarCamera();
      });
    });
  }

  _recuperaViagemPeloID(String? idViagem) async {
    if (idViagem != null) {
      DocumentSnapshot documentSnapshot =
          await _db.collection("viagens").doc(idViagem).get();
      var dados = documentSnapshot;
      String rua = dados["rua"];
      String numero = dados["numero"];
      String cidade = dados["cidade"];
      LatLng latLng = LatLng(dados["latitude"], dados["longitude"]);
      setState(() {
        Marker marcador = Marker(
          markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(
            title: "$rua, $numero - $cidade",
          ),
        );
        _marcadores.add(marcador);
        _posicaoCamera = CameraPosition(
          target: latLng,
          zoom: 18,
        );
        _movimentarCamera();
      });
    } else {
      _adicionarListenerLocalizacao();
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperaViagemPeloID(widget.idViagem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa"),
      ),
      body: GoogleMap(
        initialCameraPosition: _posicaoCamera,
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        onLongPress: _exibirMarcador,
        markers: _marcadores,
        myLocationEnabled: true,
      ),
    );
  }
}
