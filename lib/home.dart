import 'package:flutter/material.dart';
import 'package:minhas_viagens/mapa.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List _listaViagens = [
    "Cristo Redentor",
    "Grande Muralha da China",
    "Taj Mahal",
    "Machu Picchu",
    "Coliseu",
  ];

  _abrirMapa() {}

  _excluirViagem() {}

  _adicionarLocal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Mapa()),
    );
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _listaViagens.length,
              itemBuilder: (context, index) {
                String titulo = _listaViagens[index];
                return GestureDetector(
                  onTap: () {
                    _abrirMapa();
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(titulo),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _excluirViagem();
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
      ),
    );
  }
}
