import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MyHomePage(),
      ),
    );
  }
}


class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  //next구현 로직
  void getNext(){
    current = WordPair.random();
    notifyListeners();
  }
  //like 구현 로직
  var fav = <WordPair>[];
  void toggleFav() {
    if(fav.contains(current)){    //즐찾목록에 있으면 current변수삭제
      fav.remove(current);
    } else {
      fav.add(current);           //없으면 추가
    }
    notifyListeners();            //두가지의 경우 모두 알려줌
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = favoritePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(children: [
            SafeArea(child: NavigationRail(
              extended: constraints.maxWidth >= 600,
              destinations: [
              NavigationRailDestination(icon: Icon(Icons.home), label: Text('home'),),
              NavigationRailDestination(icon:  Icon(Icons.favorite),label: Text('favorites'),
              ),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value){
              setState(() {
                selectedIndex = value;
              });
            },
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: page,
          ),
          ),
          ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.fav.contains(pair)){
      icon = Icons.favorite;
    }else{
      icon = Icons.favorite_border;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: (){
                  appState.toggleFav();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: (){
                appState.getNext();
              }, 
              child: Text('Next'),
              ),
            ],
          )
        ],
        ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(  //->! bang 연산자
      color: theme.colorScheme.onPrimary,
    );
    return Card(     
      color: theme.colorScheme.primary,           //wrap with widget <why?>
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, 
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
          ),
      ),
    );
  }
}

class favoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();

    if (appState.fav.isEmpty){
      return Center(
        child: Text('No fav yet'),
      );
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('you have ' '${appState.fav.length} favorites:'),
        ),
        for (var pair in appState.fav)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}