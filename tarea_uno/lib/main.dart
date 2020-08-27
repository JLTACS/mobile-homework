import 'package:flutter/material.dart';
 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _barColor = Color(Colors.white.value);
  var _click = 0;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Click the FAB',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: _barColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.whatshot,
              color: Colors.black,
            ), 
            onPressed: (){
              setState(() {
                if(_barColor.value == Colors.white.value)
                {
                  _barColor = Color(Colors.red.value);
                }
                else
                {
                  _barColor = Color(Colors.white.value);
                }
                
              });
            })
        ],
      ),
      body: Center(
        child: Container(
          child: Text(
            '$_click',
            style: TextStyle(fontSize: 30), 
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _click++;
          if(_click % 2 == 0)
          {
            _scaffoldKey.currentState
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text("Par"),
              )
            );
          }
          else
          {
            _scaffoldKey.currentState
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text("Impar"),
                action: SnackBarAction(
                  label: 'Dialogo', 
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("La fecha es"),
                          content: Text(DateTime.now().toString()),
                          actions: [
                            FlatButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                              child: Text("Salir"),
                              )
                          ],
                        );
                      }
                    );
                  }
                  ),
              )
            );
          }
          
          setState(() {});
        },
        child: Icon(Icons.trip_origin),

        ),
    );
  }
}