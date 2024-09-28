import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tractian/models/asset.dart';
import 'package:tractian/models/location.dart';
import 'package:tractian/pages/treeview.dart';
import 'package:tractian/util.dart';

class AssetsPage extends StatefulWidget {
  static const ROUTE = '/assets';
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  var opcoes = {99};

  var listaLocations = <Location>[];

  var listaAssets = <Asset>[];

  var pesquisaController = TextEditingController();

  var carregando = false;

  @override
  void initState() {
    super.initState();

    carrega();
  }

  Future<void> carrega() async {
    var comp = Util.companie!;
    setState(() {
      carregando = true;
    });

    try {
      var resp = await http.get(Uri.parse(
          'https://fake-api.tractian.com/companies/${comp.id}/locations'));
      if (resp.statusCode == 200) {
        var jsonLocations = jsonDecode(resp.body) as List<dynamic>;
        jsonLocations.forEach((e) => listaLocations.add(Location.fromJson(e)));
      } else {
        throw Exception(resp.body);
      }

      resp = await http.get(Uri.parse(
          'https://fake-api.tractian.com/companies/${comp.id}/assets'));
      if (resp.statusCode == 200) {
        var jsonAssets = jsonDecode(resp.body) as List<dynamic>;
        jsonAssets.forEach((e) => listaAssets.add(Asset.fromJson(e)));
      } else {
        throw Exception(resp.body);
      }
    } catch (e) {
      Util.showDialogMessage('Erro', e.toString(), context);
    } finally {
      // setState(() {
      //   carregando = false;
      // });
    }

    locationsFiltered = listaLocations;
    assetsFiltered = listaAssets;

    montaLista(salvaCache: true);
  }

  var listaLocationsCache = <Location>[];
  var listaAssetsCache = <Asset>[];

  var listaLocations2 = <Location>[];
  var listaAssets2 = <Asset>[];

  Future<void> montaLista({bool salvaCache = false}) async {
    await Future.wait([locaisRaiz(), assetsRaiz()]);

    if (salvaCache) {
      listaLocationsCache = listaLocations2.sublist(0);
      listaAssetsCache = listaAssets2.sublist(0);
    }

    setState(() {
      carregando = false;
    });
  }

  Future<void> locaisRaiz() async {
    listaLocations2 =
        locationsFiltered.where((l) => l.parentId == null).toList();
    await Future.forEach(listaLocations2, (l) {
      locaisFilhos(l);
      assetsFilhos(l);
    });
  }

  Future<void> assetsRaiz() async {
    listaAssets2 = assetsFiltered
        .where((a) => a.locationId == null && a.parentId == null)
        .toList();
    await Future.forEach(listaAssets2, (a) {
      assetsFilhosPorAssetPai(a);
    });
  }

  Future<void> locaisFilhos(Location localPai) async {
    var x = locationsFiltered.where((l) => l.parentId == localPai.id);
    localPai.locations = x;
    for (var tmp in x) {
      locaisFilhos(tmp);
      assetsFilhos(tmp);
    }
  }

  Future<void> assetsFilhos(Location localPai) async {
    var x = assetsFiltered.where((a) => a.locationId == localPai.id);
    localPai.assets = x;
    for (var tmp in x) {
      assetsFilhosPorAssetPai(tmp);
    }
  }

  Future<void> assetsFilhosPorAssetPai(Asset assetPai) async {
    var x = assetsFiltered.where((a) => a.parentId == assetPai.id);
    assetPai.assets = x;

    for (var tmp in x) {
      assetsFilhosPorAssetPai(tmp);
    }
  }

  var locationsFiltered = <Location>[];
  var assetsFiltered = <Asset>[];

  bool assetSearchCondition(Asset a) {
    if (opcoes.contains(0) && opcoes.contains(1)) {
      if (pesquisaController.text.isNotEmpty) {
        return (a.sensorType == 'energy' &&
            a.status == 'alert' &&
            a.name
                .toLowerCase()
                .contains(pesquisaController.text.toLowerCase()));
      } else {
        return (a.sensorType == 'energy' && a.status == 'alert');
      }
    } else {
      if (pesquisaController.text.isNotEmpty) {
        if (opcoes.contains(0) || opcoes.contains(1)) {
          return (a.sensorType == 'energy' &&
                  opcoes.contains(0) &&
                  a.name
                      .toLowerCase()
                      .contains(pesquisaController.text.toLowerCase())) ||
              (a.status == 'alert' &&
                  opcoes.contains(1) &&
                  a.name
                      .toLowerCase()
                      .contains(pesquisaController.text.toLowerCase()));
        } else {
          return (a.name
              .toLowerCase()
              .contains(pesquisaController.text.toLowerCase()));
        }
      } else {
        return (a.sensorType == 'energy' && opcoes.contains(0)) ||
            (a.status == 'alert' && opcoes.contains(1));
      }
    }
  }

  Future<void> filtrar() async {
    if (opcoes.contains(0) ||
        opcoes.contains(1) ||
        pesquisaController.text.isNotEmpty) {
      locationsFiltered = [];
      assetsFiltered =
          listaAssets.where((a) => assetSearchCondition(a)).toList();
      for (var a in assetsFiltered.sublist(0)) {
        if (a.locationId != null) {
          addParentLocation(a.locationId);
        } else if (a.parentId != null) {
          addParentAsset(a.parentId);
        }
      }
      locationsFiltered.sort((l1, l2) => l1.name.compareTo(l2.name));
      assetsFiltered.sort((a1, a2) => a1.name.compareTo(a2.name));
      montaLista();
    } else {
      //locationsFiltered = listaLocations;
      //assetsFiltered = listaAssets;
      //montaLista();
      setState(() {
        listaLocations2 = listaLocationsCache.sublist(0);
        listaAssets2 = listaAssetsCache.sublist(0);
      });
    }
  }

  addParentLocation(String? locId) {
    var loc = listaLocations.firstWhere((l) => l.id == locId);
    if (locationsFiltered.contains(loc) == false) {
      locationsFiltered.add(loc);
      if (loc.parentId != null) {
        addParentLocation(loc.parentId);
      }
    }
  }

  addParentAsset(String? assetId) {
    var asset = listaAssets.firstWhere((a) => a.id == assetId);
    if (assetsFiltered.contains(asset) == false) {
      assetsFiltered.add(asset);
      if (asset.locationId != null) {
        addParentLocation(asset.locationId);
      }
      if (asset.parentId != null) {
        addParentAsset(asset.parentId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${Util.companie!.name} assets"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo[900],
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.text,
                        controller: pesquisaController,
                        onChanged: (value) => filtrar(),
                        decoration: const InputDecoration(
                          hintText: "Buscar Ativo",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SegmentedButton(
                            showSelectedIcon: false,
                            multiSelectionEnabled: true,
                            style: ButtonStyle(
                                foregroundColor: WidgetStateColor.resolveWith(
                                    (states) =>
                                        (states.contains(WidgetState.selected))
                                            ? (Colors.white)
                                            : (Colors.black)),
                                backgroundColor: WidgetStateColor.resolveWith(
                                    (states) =>
                                        (states.contains(WidgetState.selected))
                                            ? (Colors.indigo)
                                            : (Colors.transparent))),
                            segments: const [
                              ButtonSegment(
                                value: 0,
                                icon: Icon(FontAwesomeIcons.bolt),
                                label: Text("Sensor Energia"),
                              ),
                              ButtonSegment(
                                value: 1,
                                icon: Icon(Icons.error_outline_rounded),
                                label: Text("Crítico"),
                              ),
                            ],
                            selected: opcoes,
                            onSelectionChanged: (p0) async {
                              setState(() {
                                opcoes = p0;
                              });
                              filtrar();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TreeView(
                    nodes: listaLocations2,
                    nodesA: listaAssets2,
                  ),
                ),
              ],
            ),
    );
  }
}
