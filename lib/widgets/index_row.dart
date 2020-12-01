import 'package:flutter/material.dart';

indexRow(String img, String text){
  return Padding(
    padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
    child: Row(
      children: [
        Image.asset(img, height: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.blue[50]),),
        )
      ],
    ),
  );
}