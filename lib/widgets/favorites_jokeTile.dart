import 'dart:convert';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jokes/ReadWrite/ReadWrite.dart';
import 'package:flutter_jokes/pages/FavoritesPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class favorites_jokeTile extends StatefulWidget {
  String id;
  favorites_jokeTile({Key key,@required this.id}) : super(key: key);

  @override
  _favorites_jokeTileState createState() => _favorites_jokeTileState();
}

class _favorites_jokeTileState extends State<favorites_jokeTile> {

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
              Navigator.pushReplacement(context, PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    FavoritesPage(),
                transitionDuration: Duration(seconds: 0),
              ));
            } else
              items.add(s);
            rw.writeCounter(items);
          },
          child: ListTile(
            title: Text(data["joke"],style: GoogleFonts.lato(fontSize: 20),),
            trailing: InkWell(
              child: !favorites.contains(widget.id)?Icon(Icons.favorite,color: Colors.yellow[800],size: 20,):Icon(Icons.favorite_border,color: Colors.yellow[800],size: 20,),
              onTap: () async{
                await readData();
                print("Favorites = $items");
                String s;
                setState(() {
                  s = '"' + data['id'] + '"';
                });

                if(items.contains(s)) {
                  items.remove(s);
                  Navigator.pushReplacement(context, PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        FavoritesPage(),
                    transitionDuration: Duration(seconds: 0),
                  ));
                } else
                  items.add(s);
                rw.writeCounter(items);
              },
            ),
            subtitle:  Center(
              child: Column(
                children: [
                  SizedBox(height:20),
                  InkWell(
                    child: Icon(Icons.copy,color: Colors.yellow,size: 20,),
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
