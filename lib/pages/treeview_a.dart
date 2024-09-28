import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tractian/models/asset.dart';

class TreeViewA extends StatefulWidget {
  const TreeViewA({super.key, required this.nodes, this.level = 0});

  final Iterable<Asset> nodes;
  final int level;
  @override
  State<TreeViewA> createState() => _TreeViewAState();
}

class _TreeViewAState extends State<TreeViewA> {
  late Iterable<Asset> nodes;

  @override
  void initState() {
    super.initState();

    nodes = widget.nodes;
  }

  IconData iconeItem(int ind) {
    switch (nodes.elementAt(ind).sensorType ?? '') {
      case 'L':
        return Icons.location_on_outlined;
      case '':
        return FontAwesomeIcons.cube;
      default:
        return FontAwesomeIcons.codepen;
    }
  }

  Widget iconeAlerta(int ind) {
    var item = nodes.elementAt(ind);
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
      } else {
        return const SizedBox();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes != nodes) {
      nodes = widget.nodes;
    }
    return ListView.builder(
      itemCount: nodes.length,
      physics: widget.level != 0 ? const NeverScrollableScrollPhysics() : null,
      shrinkWrap: widget.level != 0,
      itemBuilder: (context, ind) {
        return ExpansionTile(
          shape: const Border(),
          onExpansionChanged: (value) => nodes.elementAt(ind).expanded = value,
          initiallyExpanded: nodes.elementAt(ind).expanded,
          dense: true,
          title: Row(
            children: [
              SizedBox(
                width: widget.level * 20,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  iconeItem(ind),
                  color: Colors.black,
                ),
              ),
              iconeAlerta(ind),
              Expanded(
                child: Text(
                  nodes.elementAt(ind).name,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          // trailing: nodes.elementAt(ind).assets.isEmpty
          //     ? const SizedBox.shrink()
          //     : null,
          showTrailingIcon: nodes.elementAt(ind).assets.isEmpty == false,
          children: [
            TreeViewA(
              nodes: nodes.elementAt(ind).assets,
              level: widget.level + 1,
            ),
          ],
        );
      },
    );
  }
}
