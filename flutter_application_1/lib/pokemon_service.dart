import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  Future<Map<String, dynamic>> getPokemon(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al cargar Pokémon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar Pokémon: $e');
    }
  }
}
