import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _results = [];

  void _onSearch(String query) {
    // lightweight placeholder behavior: filter a small built-in list
    final all = [
      'Pizza', 'Pasta', 'Burger', 'Salad', 'Sushi', 'Curry', 'Biryani', 'Taco'
    ];
    setState(() {
      if (query.trim().isEmpty) {
        _results = [];
      } else {
        _results = all.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: const Color(0xFF1A2A66),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Search recipes, ingredients...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              if (_results.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      _controller.text.isEmpty ? 'Start typing to search' : 'No results',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      return ListTile(
                        leading: const Icon(Icons.fastfood),
                        title: Text(_results[i]),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open ${_results[i]}')));
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
