import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Welcome to Flutter',
        theme: ThemeData(
            // primarySwatch: Colors.brown
            primaryColor: Colors.blueAccent),
        home: RandomWords());
  }
}

class RandomWordsState extends State<RandomWords> {
  // 2 sets of data and make it for repair
  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _saved = new Set<WordPair>();
  final TextStyle _biggerFont = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My First Flutter'),
        actions: <Widget>[
          new IconButton(icon: Icon(Icons.save), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  // return Widget to show to End-user
  Widget _buildSuggestions() {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemBuilder: (BuildContext _context, int i) {
        if (i.isOdd) {
          return Divider();
        }
        final int index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            // Add it to compare after add Set step
            _saved.add(pair);
          }
        });
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      // Take the set of saved word to new page and iteration all data
      final Iterable<ListTile> tiles = _saved.map(
        (WordPair pair) {
          return new ListTile(
            title: new Text(
              pair.asPascalCase,
              style: _biggerFont,
            ),
          );
        },
      );
      final List<Widget> divided = ListTile.divideTiles(
        context: context,
        tiles: tiles,
      ).toList();

      return new Scaffold(
        appBar: AppBar(
          title: Text('Saved word suggestion'),
        ),
        body: ListView(
          children: divided,
        ),
      );
    }));
  }
}

class RandomWords extends StatefulWidget {
  @override
//  State<StatefulWidget> createState() => RandomWordsState();
  RandomWordsState createState() => RandomWordsState();
  // return RandomWordsState()
}
