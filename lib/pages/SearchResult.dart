import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jokes/widgets/jokeTile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class SearchResult extends StatefulWidget {
  String term;
  SearchResult({Key key,@required this.term}) : super(key: key);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  TextEditingController textController = TextEditingController();
  bool searchResultEmpty = false;
  bool dataLoaded = false;
  var data;
  List<jokeTile> tile = [];

  Future<void> getSearchData(String s) async{
    Response response = await get(
      Uri.parse('https://icanhazdadjoke.com/search?term=$s'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
      },
    );
    data = jsonDecode(response.body);
  }

  Future<void> getTiles(String s) async{

    await getSearchData(s);

    if(data["total_jokes"]>0){
      for (int i = 0; i < data["results"].length; i++)
        tile.add(jokeTile(id: data["results"][i]["id"]));

      setState(() {
        dataLoaded = true;
      });
    }
    else
      {
        setState(() {
          dataLoaded = true;
          searchResultEmpty = true;
        });

        print("TRUED");
      }
  }

  void initState(){
    super.initState();
    getTiles(widget.term);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[400],
        leading: InkWell(
          child: Icon(Icons.arrow_back,color: Colors.black,size: 26,),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        title: Text("Search Result",style: GoogleFonts.sairaCondensed(letterSpacing: 2,color: Colors.black,),), centerTitle: true,),

      body:Column(
        children: [
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
                              setState(() {
                                dataLoaded = false;
                                searchResultEmpty = false;
                                getTiles(textController.text);
                              });
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
                     setState(() {
                       dataLoaded = false;
                       searchResultEmpty = false;
                       getTiles(textController.text);
                     });
                    },
                  ),
                ],
              ),
            ),
          ),
          dataLoaded?searchResultEmpty?Center(
            child: Image.asset("assets/no-results.gif",fit: BoxFit.fill),
          ):  Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: tile,
              ),
            ),
          ):Padding(
            padding: const EdgeInsets.fromLTRB(0,60,0,0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      )
    );
  }
}
