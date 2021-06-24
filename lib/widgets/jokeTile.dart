import 'dart:convert';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jokes/ReadWrite/ReadWrite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class jokeTile extends StatefulWidget {
  String id;
  jokeTile({Key key,@required this.id}) : super(key: key);

  @override
  _jokeTileState createState() => _jokeTileState();
}

class _jokeTileState extends State< jokeTile> {

  bool jokeLoaded = false;
  var data;
  ReadWrite rw = new ReadWrite();
  List<String> items = [];
  List<String> favorites = [];

  Future<void> readData() async{
    var read = await rw.readCounter();
    print(read);

    favorites = read;

    for(int i = 0;i<read.length;i++)
      if(!items.contains('"' + read[i] + '"'))
        items.add('"' + read[i] + '"');

  }

  void getJoke() async{
    Response response = await get(
      Uri.parse('https://icanhazdadjoke.com/j/${widget.id}'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    data = jsonDecode(response.body);

    if (!mounted) return;

    setState(() {
      jokeLoaded = true;
    });

    //print("DATA: $data");
  }

  void initState(){
    super.initState();
    getJoke();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8,15,8,0),
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: new BoxDecoration(
          color: Colors.white,
          /*boxShadow: [new BoxShadow(
              color: Colors.black,
              blurRadius: 6.0,
            ),]*/
        ),
        child: jokeLoaded?GestureDetector(
          onDoubleTap: () async{
            await readData();
            print("Favorites = $items");
            String s;
            setState(() {
              s = '"' + data['id'] + '"';
            });
            if(items.contains(s)) {
              items.remove(s);
              final snackBar = SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Removed From Favorites!'),
                duration: Duration(milliseconds: 800)
              );
              Scaffold.of(context).showSnackBar(snackBar);
            } else {
              items.add(s);
              final snackBar = SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Added To Favorites!'),
                duration: Duration(milliseconds: 800)
              );
              Scaffold.of(context).showSnackBar(snackBar);
            }
            rw.writeCounter(items);
          },
          child: ListTile(
            title: Text(data["joke"],style: GoogleFonts.lato(fontSize: 20),),
            trailing: InkWell(
              child: items.contains('"' + data['id'] + '"')?Icon(Icons.favorite,color: Colors.yellow[800],size: 20,):Icon(Icons.favorite_border,color: Colors.yellow[800],size: 20,),
              onTap: () async{
                await readData();
                print("Favorites = $items");
                String s;
                setState(() {
                  s = '"' + data['id'] + '"';
                });
                if(items.contains(s)) {
                  items.remove(s);
                  final snackBar = SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Removed From Favorites!'),
                    duration: Duration(milliseconds: 800)
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                } else {
                  items.add(s);
                  final snackBar = SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Added To Favorites!'),
                    duration: Duration(milliseconds: 800)
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                }
                rw.writeCounter(items);
              },
            ),
            subtitle:  Center(
              child: Column(
                children: [
                  SizedBox(height:20),
                  InkWell(
                    child: Icon(Icons.copy,color: Colors.yellow[800],size: 20,),
                    onTap: () {
                      FlutterClipboard.copy(data["joke"]).then(( value ) => print('copied'));
                      final snackBar = SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Copied To Clipboard!'),
                        duration: Duration(milliseconds: 800)
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    },
                  ),
                ],
              ),
            ),
          ),
        ):Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
