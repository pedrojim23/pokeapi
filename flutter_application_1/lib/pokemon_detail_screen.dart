/*import 'package:flutter/material.dart';

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
            // Muestra la imagen del Pokémon
            Image.network(
              pokemon['imageUrl'],
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            // Muestra el nombre del Pokémon
            Text('Name: ${pokemon['name']}'),
            // Muestra el ID del Pokémon
            Text('ID: ${pokemon['id']}'),
            // Puedes agregar más detalles del Pokémon aquí
          ],
        ),
      ),
    );
  }
}
*/