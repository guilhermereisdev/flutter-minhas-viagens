import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minhas_viagens/mapa.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore _db = FirebaseFirestore.instance;

  _abrirMapa(String idViagem) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Mapa(idViagem: idViagem)),
    );
  }

  _excluirViagem(String idViagem) {
    _db.collection("viagens").doc(idViagem).delete();
  }

  _adicionarLocal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Mapa()),
    );
  }

  _adicionarListenerViagens() async {
    final stream = _db.collection("viagens").snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerViagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Viagens"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0066cc),
        onPressed: () {
          _adicionarLocal();
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot? querySnapshot = snapshot.data;
              List<DocumentSnapshot> viagens = [];
              if (querySnapshot != null) {
                viagens = querySnapshot.docs.toList();
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: viagens.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot item = viagens[index];
                        String nome =
                            "${item["rua"]}, ${item["numero"]} - ${item["cidade"]}";
                        String idViagem = item.id;

                        return GestureDetector(
                          onTap: () {
                            _abrirMapa(idViagem);
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(nome),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _excluirViagem(idViagem);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
