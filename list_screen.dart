import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import 'look_screen.dart';
import 'create_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Review> reviews = [];
  List<String> types = [];
  String selectedType = '';
  bool isLoading = true;

  final String apiUrl = 'http://10.0.2.2:3000/api';

  @override
  void initState() {
    super.initState();
    fetchTypes();
    fetchReviews();
  }

  Future<void> fetchTypes() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/type'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          types = data.map((e) => e['con_type'].toString()).toList();
        });
      }
    } catch (e) {
      print('Ошибка загрузки типов: $e');
    }
  }

  Future<void> fetchReviews() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$apiUrl/review'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          reviews = data.map((json) => Review.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Ошибка загрузки рецензий: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Review> get filteredReviews {
    if (selectedType.isEmpty) return reviews;
    return reviews.where((r) => r.type == selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваши рецензии', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF45786b),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateScreen()),
              );
              fetchReviews();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтр по типу
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: selectedType.isEmpty ? null : selectedType,
              decoration: const InputDecoration(
                labelText: 'Фильтр по типу',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('Все типы')),
                ...types.map((t) => DropdownMenuItem(value: t, child: Text(t))),
              ],
              onChanged: (val) {
                setState(() => selectedType = val ?? '');
              },
            ),
          ),


          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredReviews.isEmpty
                ? const Center(child: Text('Отзывов такого типа пока нет.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredReviews.length,
              itemBuilder: (context, index) {
                final review = filteredReviews[index];
                return Card(
                  color: const Color(0xFF2C2C2C),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LookScreen(reviewId: review.id!)),
                      );
                      fetchReviews();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '✨' * review.remark,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              review.date != null ? review.date!.substring(0, 10) : '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}