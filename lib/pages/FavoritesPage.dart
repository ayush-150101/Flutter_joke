import 'package:flutter/material.dart';
import 'package:flutter_jokes/ReadWrite/ReadWrite.dart';
import 'package:flutter_jokes/widgets/favorites_jokeTile.dart';
import 'package:flutter_jokes/widgets/jokeTile.dart';
import 'package:google_fonts/google_fonts.dart';

import 'HomePage.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  bool jokeLoaded = false;
  bool favoritesPresent = true;
  var data;
  ReadWrite rw = new ReadWrite();
  List<favorites_jokeTile> tile = [];
  List<String> items = [];
  List<String> favorites = [];
  int _currentIndex = 1;

  Future<void> readData() async{
    var read = await rw.readCounter();
    print(read);
    favorites = read;

    for(int i = 0;i<read.length;i++)
      if(!items.contains('"' + read[i] + '"'))
        items.add('"' + read[i] + '"');

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

  void getTiles() async{
    await readData();
    for(int i = 0;i<favorites.length;i++){
      tile.add(favorites_jokeTile(id: favorites[i]));
    }

    setState(() {
      jokeLoaded = true;
    });

  }

  void initState() {

    super.initState();
    getTiles();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],

      appBar: AppBar(
        backgroundColor: Colors.yellow[400],
        automaticallyImplyLeading: false,
        title: Text("MyCollection",style: GoogleFonts.sairaCondensed(letterSpacing: 2,color: Colors.black,),), centerTitle: true,),

      body: favorites.isEmpty?
      Center(
        child: Text("No Favorites Added!",style: GoogleFonts.sairaCondensed(letterSpacing: 3,color: Colors.black,fontSize: 30),),
      ):
      jokeLoaded?SingleChildScrollView(
        child: Column(
          children: tile,
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
