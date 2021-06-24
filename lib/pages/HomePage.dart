import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_jokes/pages/FavoritesPage.dart';
import 'package:flutter_jokes/pages/SearchResult.dart';
import 'package:flutter_jokes/widgets/random_jokeTile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController textController = TextEditingController();
  var _controller = ScrollController();
  int _currentIndex = 0;

  List<random_jokeTile> tile = [];
  bool tilesLoaded = true;

  void searchResult(String s) async{

    Response response = await get(
      Uri.parse('https://icanhazdadjoke.com/search?term=$s'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    print("Search Result = ${jsonDecode(response.body)}");

  }

  void _onTap(int index) {
    setState(() {
      switch (index) {
        case 1:
          Navigator.pushReplacement(context, PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                FavoritesPage(),
            transitionDuration: Duration(seconds: 0),
          ));
          break;
        case 0:
          Navigator.pushReplacement(context, PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                HomePage(),
            transitionDuration: Duration(seconds: 0),
          ));
          break;
      }
    });
  }


  void getTiles(){

      for (int i = 0; i < 15; i++) {
        tile.add(random_jokeTile());
      }
      setState(() {
        print("Loaded 20 jokes");
        tilesLoaded = true;
      });

  }

  void initState(){
    super.initState();
    getTiles();

    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels == 0) {
          // You're at the top.
        } else {
          getTiles();
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: tilesLoaded?Builder(
        builder: (context) => Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 35, 0, 0),
            child: Column(
              children: [
                Image.asset(
                  "assets/jokes_background.jpg",
                  height: 150,
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 4, 0),
                              child: TextFormField(
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (term) {
                                    Navigator.push(context, PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) =>
                                          SearchResult(term: textController.text),
                                      transitionDuration: Duration(seconds: 1),
                                    ));
                                  },
                                  controller: textController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    hintText:
                                    'Bored? Search for some fun here!',
                                    hintStyle: GoogleFonts.lato(),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 1,
                                      ),
                                      borderRadius:
                                      const BorderRadius.only(
                                        topLeft: Radius.circular(4.0),
                                        topRight: Radius.circular(4.0),
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 1,
                                      ),
                                      borderRadius:
                                      const BorderRadius.only(
                                        topLeft: Radius.circular(4.0),
                                        topRight: Radius.circular(4.0),
                                      ),
                                    ),
                                  )),
                            )),
                        InkWell(
                          child: Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 28,
                          ),
                          onTap: () {
                            searchResult(textController.text);
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  SearchResult(term: textController.text),
                              transitionDuration: Duration(seconds: 1),
                            ));
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10,),
                
                Expanded(
                  child: SingleChildScrollView(
                    controller: _controller,
                    child: Column(
                      children: tile,
                    ),
                  ),
                )
                
              ],
            ),
          ),
        ),
      ):Center(child: CircularProgressIndicator(),),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex, // this will be set when a new tab is tapped
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home_outlined,color: Colors.yellow[800],),
            label: "",
            activeIcon: Icon(Icons.home,color: Colors.yellow[800],size: 24,),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.favorite_border,color: Colors.yellow[800],),
            label: "",
            activeIcon: Icon(Icons.favorite,color: Colors.yellow[800],size: 24,),
          ),
        ],
      ),
    );
  }
}
