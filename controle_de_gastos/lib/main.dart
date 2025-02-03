import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dados = TextEditingController();
  final dataMap = <String, double>{};
  final nomes = TextEditingController();
  late Map<String, Object> data = {}; // Amazenar os dados

  final gradientList = <List<Color>>[
    [
      Color.fromRGBO(223, 250, 92, 1),
      Color.fromRGBO(90, 240, 70, 1),
    ],
    [
      Color.fromRGBO(129, 182, 205, 1),
      Color.fromRGBO(91, 253, 199, 1),
    ],
    [
      Color.fromRGBO(175, 63, 62, 1.0),
      Color.fromRGBO(254, 154, 92, 1),
    ],
    [
      Color.fromRGBO(250, 6, 2, 1),
      Color.fromRGBO(243, 45, 42, 1),
    ],
    [
      Color.fromRGBO(59, 86, 235, 1),
      Color.fromRGBO(2, 151, 250, 1),
    ]
  ];

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void _addDados() {
    setState(() {
      String dado = dados.text; //Pegar o dados do textField
      String nome = nomes.text;
      double? valor = double.tryParse(dado); //Converter para double
      if (valor != null && nome.isNotEmpty) {
        dataMap[nome] = valor;
        nomes.clear();
        dados.clear();
      } else {
        print("Error");
      }
    });
  }

  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Insira o numero do dado"),
            content: TextField(
              keyboardType: TextInputType.number,
              controller: dados,
              decoration: InputDecoration(hintText: "Digite aqui"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text("Fechar"),
              ),
              TextButton(
                onPressed: () {
                  _addDados();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                ),
                child: Text("Enviar"),
              ),
            ],
          );
        });
  }

  void loadData() async {
    //Função para salvar os dados
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      dados.text = prefs.getString('valor') ?? '';
      nomes.text = prefs.getString('nome') ?? '';

      var dataString = prefs.getString('data');
      data = dataString != null
          ? Map<String, Object>.from(jsonDecode(dataString))
          : {};
    });
  }

  void _resetData() async {
    //Função para remover os dados
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('valor');
    prefs.remove('nome');
    prefs.remove('data');

    setState(() {
      dados.clear();
      nomes.clear();
      data = {};
      dataMap.clear();
    });
  }

  void _showDialog2(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Você Tem certeza?"),
            content: Text(
                "Você tem certeza de que deseja excluir todos os dados? Essa ação não pode ser desfeita."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                ),
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  _resetData();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text("Confirmar"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Grafico"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.name,
                    controller: nomes,
                    decoration: InputDecoration(
                      labelText: "Insira o nome",
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showDialog(context);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(""),
                  iconAlignment: IconAlignment.end,
                )
              ],
            ),
          ),
          Expanded(
            child: dataMap.isEmpty //Verifica se o dados está vazio
                ? Center(child: Text("Nenhum dado adicionado"))
                : PieChart(
                    dataMap: dataMap,
                    animationDuration: Duration(milliseconds: 800),
                    gradientList: gradientList,
                    emptyColorGradient: [
                      Color(0xff6c5ce7),
                      Colors.blue,
                    ],
                  ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _showDialog2(context);
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}
