import 'package:flutter/material.dart';
import 'package:tractian/models/companie.dart';

class Util {
  static Companie? companie = null;

  static Future showDialogMessage(
      String titulo, String conteudo, BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(conteudo),
          actions: <Widget>[
            TextButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
