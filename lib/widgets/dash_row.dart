import 'package:flutter/material.dart';

dashRow(BuildContext context, String text, IconData icon, Stream stream){
  return Expanded(
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.blue[200]
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(icon, color: Colors.blue[50], size: 40),
                StreamBuilder(
                    stream: stream,
                    builder: (context, AsyncSnapshot<dynamic> val) {
                      if (val.data==null)
                        return Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator());
                      else
                        return Text(val.data.toString(), style: TextStyle(color: Colors.blue[50], fontWeight: FontWeight.bold, fontSize: 32));
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}