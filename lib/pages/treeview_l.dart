import 'package:flutter/material.dart';
import 'package:tractian/models/location.dart';
import 'package:tractian/pages/treeview_a.dart';

class TreeViewL extends StatefulWidget {
  const TreeViewL({super.key, required this.nodes, this.level = 0});

  final Iterable<Location> nodes;
  final int level;
  @override
  State<TreeViewL> createState() => _TreeViewLState();
}

class _TreeViewLState extends State<TreeViewL> {
  late Iterable<Location> nodes;

  @override
  void initState() {
    super.initState();

    nodes = widget.nodes;
  }

  IconData iconeItem(int ind) {
    return Icons.location_on_outlined;
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
              Expanded(
                child: Text(
                  nodes.elementAt(ind).name,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          // trailing: nodes.elementAt(ind).locations.isEmpty
          //     ? const SizedBox.shrink()
          //     : null,
          showTrailingIcon: nodes.elementAt(ind).locations.isEmpty == false ||
              nodes.elementAt(ind).assets.isEmpty == false,
          children: [
            TreeViewL(
              nodes: nodes.elementAt(ind).locations,
              level: widget.level + 1,
            ),
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
