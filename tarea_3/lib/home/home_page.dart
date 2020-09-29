import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String result;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Material App Bar"),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () async {
              result = await showMenu<String>(context: context, 
              position: RelativeRect.fromLTRB(100, 70, 10, 100), 
              items: [
                PopupMenuItem(child: Text('Par'), value:'Par'),
                PopupMenuItem(child: Text('Impar'), value: 'Impar'),
                PopupMenuItem(child: Text('Todos'), value:'Todos')
              ]
              );
              if (result == 'Todos'){
                BlocProvider.of<HomeBloc>(context).add(GetAllUsersEvent());
              }else{
                BlocProvider.of<HomeBloc>(context).add(FilterUsersEvent(filterEven: result == 'Par'));
              }
              
            },
          )
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            // para mostrar dialogos o snackbars
            if (state is ErrorState) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text("Error: ${state.error}")),
                );
            }
          },
          builder: (context, state) {
            if (state is ShowUsersState) {
              return RefreshIndicator(
                child: ListView.separated(
                  itemCount: state.usersList.length,
                  separatorBuilder: (BuildContext context, int index) => Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.usersList[index].name,  
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(state.usersList[index].username,
                              style: TextStyle(
                                fontStyle: FontStyle.italic
                              ),
                            ),
                            Text("Company: ${state.usersList[index].company.name}"),
                            Text("Phone: ${state.usersList[index].phone}"),
                            Text("Street: ${state.usersList[index].address.street}")
                           ]
                        ),
                      ),
                    );
                  },
                ),
                onRefresh: () async {
                  BlocProvider.of<HomeBloc>(context).add(GetAllUsersEvent());
                },
              );
            } else if (state is LoadingState) {
              return Center(child: CircularProgressIndicator());
            }
            return Center(
              child: MaterialButton(
                onPressed: () {
                  BlocProvider.of<HomeBloc>(context).add(GetAllUsersEvent());
                },
                child: Text("Cargar de nuevo"),
              ),
            );
          },
        ),
      );
    
  }
}
