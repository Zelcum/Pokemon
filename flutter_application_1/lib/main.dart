import 'package:flutter/material.dart';
import 'dart:math';
import 'pokemon_service.dart';
import 'models/pokemon.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emparejador Pokémon',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const PokemonMatcherPage(),
    );
  }
}

class PokemonMatcherPage extends StatefulWidget {
  const PokemonMatcherPage({super.key});

  @override
  State<PokemonMatcherPage> createState() => _PokemonMatcherPageState();
}

class _PokemonMatcherPageState extends State<PokemonMatcherPage> {
  final PokemonService _pokemonService = PokemonService();
  final Random _random = Random();
  
  Pokemon? _pokemon1;
  Pokemon? _pokemon2;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _matchPokemon() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pokemon1 = null;
      _pokemon2 = null;
    });

    try {
      // Generate two random Pokemon IDs between 1 and 898
      final id1 = _random.nextInt(898) + 1;
      final id2 = _random.nextInt(898) + 1;

      // Fetch both Pokemon
      final results = await Future.wait([
        _pokemonService.getPokemon(id1),
        _pokemonService.getPokemon(id2),
      ]);

      setState(() {
        _pokemon1 = Pokemon.fromJson(results[0]);
        _pokemon2 = Pokemon.fromJson(results[1]);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar Pokémon';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emparejador Pokémon'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _matchPokemon,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Emparejar Pokémon'),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                )
              else if (_pokemon1 != null && _pokemon2 != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildPokemonCard(_pokemon1!),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPokemonCard(_pokemon2!),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonCard(Pokemon pokemon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              pokemon.imageUrl,
              height: 150,
              width: 150,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: 150,
                  width: 150,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 150,
                  width: 150,
                  child: Icon(Icons.error, size: 50),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              pokemon.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '#${pokemon.id}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
