import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    const String titulo = 'Jogo da Velha';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: titulo,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: titulo),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _tabuleiro = List.filled(9, '');
  String _jogadorAtual = 'X';
  bool _contraComputador = false;
  final Random _randomico = Random();
  bool _pensando = false;
  int _vitoriasX = 0;
  int _vitoriasO = 0;
  int _empates = 0;

  void _iniciarJogo() {
    setState(() {
      _tabuleiro = List.filled(9, '');
      _jogadorAtual = 'X';
    });
  }

  void _trocarJogador() {
    setState(() {
      _jogadorAtual = _jogadorAtual == 'X' ? 'O' : 'X';
    });
  }

  void _mostrarDialogo(String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(mensagem),
          actions: [
            ElevatedButton(
              child: const Text('Reiniciar Jogo'),
              onPressed: () {
                Navigator.of(context).pop();
                _iniciarJogo();
              },
            ),
          ],
        );
      },
    );
  }

  bool _verificarVencedor(String jogador) {
    const linhasVitoriosas = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var linha in linhasVitoriosas) {
      if (_tabuleiro[linha[0]] == jogador &&
          _tabuleiro[linha[1]] == jogador &&
          _tabuleiro[linha[2]] == jogador) {
        if (jogador == 'X') {
          _vitoriasX++;
        } else {
          _vitoriasO++;
        }
        _mostrarDialogo('Vencedor: $jogador');
        return true;
      }
    }

    if (!_tabuleiro.contains('')) {
      _empates++;
      _mostrarDialogo('Empate!');
      return true;
    }

    return false;
  }

  void _jogadaComputador() {
    setState(() => _pensando = true);
    Future.delayed(const Duration(seconds: 1), () {
      int movimento;
      do {
        movimento = _randomico.nextInt(9);
      } while (_tabuleiro[movimento] != '');
      setState(() {
        _tabuleiro[movimento] = 'O';
        if (!_verificarVencedor('O')) {
          _trocarJogador();
        }
        _pensando = false;
      });
    });
  }

  void _realizarJogada(int index) {
    if (_tabuleiro[index] == '' && !_pensando) {
      setState(() {
        _tabuleiro[index] = _jogadorAtual;
        if (!_verificarVencedor(_jogadorAtual)) {
          _trocarJogador();
          if (_contraComputador && _jogadorAtual == 'O') {
            _jogadaComputador();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double tamanhoGrid = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: _contraComputador,
                  onChanged: (bool value) {
                    setState(() {
                      _contraComputador = value;
                      _iniciarJogo();
                    });
                  },
                ),
              ),
              Text(_contraComputador ? 'Contra Computador' : 'Dois Jogadores'),
              if (_pensando)
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
          SizedBox(
            width: tamanhoGrid,
            height: tamanhoGrid,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _realizarJogada(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Center(
                      child: Text(
                        _tabuleiro[index],
                        style: const TextStyle(fontSize: 40.0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Vitórias X: $_vitoriasX | Vitórias O: $_vitoriasO | Empates: $_empates',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _iniciarJogo,
            child: const Text('Reiniciar Jogo'),
          ),
        ],
      ),
    );
  }
}
