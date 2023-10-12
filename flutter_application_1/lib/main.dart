import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> pokemonList = [];
  List<dynamic> filteredList = [];
  int currentPage = 1;
  int itemsPerPage = 20; // Number of Pokémon per page
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData(currentPage);
  }

  Future<void> fetchData(int page) async {
    setState(() {
      isLoading = true;
    });

    final offset = (page - 1) * itemsPerPage;

    final response = await http.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon?limit=$itemsPerPage&offset=$offset'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      final newPokemonList = <dynamic>[];

      for (var i = 0; i < results.length; i++) {
        final pokemonDataResponse =
            await http.get(Uri.parse(results[i]['url']));
        if (pokemonDataResponse.statusCode == 200) {
          final pokemonData = json.decode(pokemonDataResponse.body);
          final imageUrl = pokemonData['sprites']['front_default'];
          final id = pokemonData['id'];

          // Access the types of the Pokémon and combine them into a list
          final typeList = pokemonData['types'] as List<dynamic>;
          final types = typeList.map((type) => type['type']['name']).join(', ');

          // Access the height of the Pokémon
          final height = pokemonData['height'] / 10.0; // Convert to meters

          newPokemonList.add({
            'id': id,
            'name': results[i]['name'],
            'imageUrl': imageUrl,
            'types': types,
            'height': height,
          });
        }
      }

      setState(() {
        pokemonList.addAll(newPokemonList);
        filteredList = List.from(pokemonList);
        isLoading = false;
        currentPage++;
      });

      // Sort the list by ID
      pokemonList.sort((a, b) => a['id'].compareTo(b['id']));
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  void filterPokemon(String query) {
    setState(() {
      filteredList = pokemonList
          .where((pokemon) => pokemon['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('PokeAPI Demo'),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: filterPokemon,
                decoration: InputDecoration(
                  labelText: 'Search Pokemon',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                      ? Center(child: Text('No matching Pokémon found.'))
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: filteredList.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == filteredList.length) {
                              // Show the "Load More" button
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    fetchData(currentPage);
                                  },
                                  child: Text('Load More'),
                                ),
                              );
                            }

                            final pokemon = filteredList[index];
                            return InkWell(
                              onTap: () {
                                // Navigate to the PokemonDetailScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PokemonDetailScreen(pokemon: pokemon),
                                  ),
                                );
                              },
                              child: Card(
                                child: Column(
                                  children: <Widget>[
                                    CachedNetworkImage(
                                      imageUrl: pokemon['imageUrl'],
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                    Text(
                                      "${pokemon['name']}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class PokemonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pokemon;

  PokemonDetailScreen({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemon Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              pokemon['imageUrl'],
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            Text('Name: ${pokemon['name']}'),
            Text('ID: ${pokemon['id']}'),
            Text('Types: ${pokemon['types']}'),
            Text('Height: ${pokemon['height']} m'),
          ],
        ),
      ),
    );
  }
}
