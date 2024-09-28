import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tractian/models/companie.dart';
import 'package:tractian/pages/assets_page.dart';
import 'package:tractian/util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const ROUTE = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var companies = <Companie>[];

  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    carregar();
  }

  carregar() async {
    try {
      var resp =
          await http.get(Uri.parse('https://fake-api.tractian.com/companies'));
      if (resp.statusCode == 200) {
        var respData = jsonDecode(resp.body) as List<dynamic>;
        var listaTmp = <Companie>[];
        respData.forEach((c) => listaTmp.add(Companie.fromJson(c)));
        setState(() {
          companies = listaTmp;
        });
      } else {
        throw Exception(resp.body);
      }
    } catch (e) {
      Util.showDialogMessage('Erro', e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          backgroundColor: Colors.indigo[900],
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          title: const Text('TRACTIAN'),
          centerTitle: true,
        ),
        body: RawScrollbar(
          controller: scrollController,
          trackVisibility: true,
          child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              controller: scrollController,
              itemCount: companies.length,
              itemBuilder: (buildContext, pos) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    onTap: () {
                      Util.companie = companies[pos];
                      Navigator.of(context).pushNamed(AssetsPage.ROUTE);
                    },
                    child: Card(
                      color: Colors.blue,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.boxesStacked,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "${companies[pos].name} unit",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ));
  }
}
