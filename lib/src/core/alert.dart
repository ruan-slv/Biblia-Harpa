/**
 * Modify: 17/04/2026 ;
 * Ruan Gustavo Soares da Silva ;
 * Files utils ;
 */

import 'package:flutter/material.dart';

class Alert {

  Future<void> alert(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "Aviso",
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            "Esta funcionalidade está em desenvolvimento. Aguarde a próxima atualização.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Entendi",
              ),
            ),
          ],
        );
      },
    );
  }
}