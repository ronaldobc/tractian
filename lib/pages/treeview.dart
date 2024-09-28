import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tractian/models/asset.dart';
import 'package:tractian/models/location.dart';
import 'package:tractian/pages/treeview_a.dart';
import 'package:tractian/pages/treeview_l.dart';

class TreeView extends StatefulWidget {
  const TreeView(
      {super.key, required this.nodes, required this.nodesA, this.level = 0});

  final Iterable<Location> nodes;
  final Iterable<Asset> nodesA;
  final int level;
  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  late Iterable<Location> nodes;
  late Iterable<Asset> nodesA;

  @override
  void initState() {
    super.initState();

    nodes = widget.nodes;
    nodesA = widget.nodesA;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes != nodes) {
      nodes = widget.nodes;
    }
    if (widget.nodesA != nodesA) {
      nodesA = widget.nodesA;
    }

    String getElementName(int ind) {
      if (ind >= nodes.length) {
        ind = ind - nodes.length;
        return nodesA.elementAt(ind).name;
      }
      return nodes.elementAt(ind).name;
    }

    bool getExpanded(int ind) {
      if (ind >= nodes.length) {
        ind = ind - nodes.length;
        return nodesA.elementAt(ind).expanded;
      }
      return nodes.elementAt(ind).expanded;
    }

    void setExpanded(int ind, bool value) {
      if (ind >= nodes.length) {
        ind = ind - nodes.length;
        nodesA.elementAt(ind).expanded = value;
      } else {
        nodes.elementAt(ind).expanded = value;
      }
    }

    bool getHasChildrens(int ind) {
      if (ind >= nodes.length) {
        ind = ind - nodes.length;
        return nodesA.elementAt(ind).assets.isEmpty == false;
      }
      return nodes.elementAt(ind).locations.isEmpty == false ||
          nodes.elementAt(ind).assets.isEmpty == false;
    }

    Iterable<Asset> getChildAssets(int ind) {
      if (ind >= nodes.length) {
        ind = ind - nodes.length;
        return nodesA.elementAt(ind).assets;
      }
      return nodes.elementAt(ind).assets;
    }

    IconData iconeItem(int ind) {
      var tipo = 'L';
      if (ind >= nodes.length) {
        ind = ind - nodes.length;
        tipo = nodesA.elementAt(ind).sensorType!;
      }
      switch (tipo) {
        case 'L':
          return Icons.location_on_outlined;
        case '':
          return FontAwesomeIcons.cube;
        default:
          return FontAwesomeIcons.codepen;
      }
    }

    Widget iconeAlerta(int ind) {
      if (ind >= nodes.length) {
        ind = ind - nodes.length;
        var item = nodesA.elementAt(ind);
        if (item.status == 'alert') {
          return const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.circle, color: Colors.red, size: 15),
          );
        } else {
          if (item.sensorType == 'energy') {
            return const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                FontAwesomeIcons.bolt,
                color: Colors.green,
                size: 15,
              ),
            );
          }
        }
      }
      return const SizedBox();
    }

    return ListView.builder(
      itemCount: nodes.length + nodesA.length,
      physics: widget.level != 0 ? const NeverScrollableScrollPhysics() : null,
      shrinkWrap: widget.level != 0,
      itemBuilder: (context, ind) {
        return ExpansionTile(
          onExpansionChanged: (value) => setExpanded(ind, value),
          initiallyExpanded: getExpanded(ind),
          dense: true,
          title: Row(
            children: [
              SizedBox(
                width: widget.level * 20,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(iconeItem(ind)),
              ),
              iconeAlerta(ind),
              Expanded(
                child: Text(
                  getElementName(ind),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          // trailing: nodes.elementAt(ind).locations.isEmpty
          //     ? const SizedBox.shrink()
          //     : null,
          showTrailingIcon: getHasChildrens(ind),
          children: [
            (ind < nodes.length)
                ? TreeViewL(
                    nodes: nodes.elementAt(ind).locations,
                    level: widget.level + 1,
                  )
                : const SizedBox.shrink(),
            TreeViewA(
              nodes: getChildAssets(ind),
              level: widget.level + 1,
            ),
          ],
        );
      },
    );
  }
}
