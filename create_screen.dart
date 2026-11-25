import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final String apiUrl = 'http://10.0.2.2:3000/api';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController favCharController = TextEditingController();
  final TextEditingController nonfavCharController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  String selectedType = '';
  double remark = 5;
  double atmosphere = 5;
  double emotions = 5;
  double idea = 5;
  double realisation = 5;

  List<String> types = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchTypes();
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
      print('Ошибка: $e');
    }
  }

  Future<void> submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите тип')));
      return;
    }

    setState(() => isSubmitting = true);

    final newReview = {
      'name': nameController.text.trim(),
      'type': selectedType,
      'remark': remark.toInt(),
      'atmosphere': atmosphere.toInt(),
      'emotions': emotions.toInt(),
      'idea': idea.toInt(),
      'realisation': realisation.toInt(),
      'fav_char': favCharController.text.trim(),
      'nonfav_char': nonfavCharController.text.trim(),
      'comment': commentController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newReview),
      );

      if (response.statusCode == 201) {
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка при создании')));
      }
    } catch (e) {
      print('Ошибка: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        Row(
          children: [
            const Text('1', style: TextStyle(color: Colors.grey)),
            Expanded(
              child: Slider(
                value: value,
                min: 1,
                max: 10,
                divisions: 9,
                label: value.toInt().toString(),
                activeColor: const Color(0xFF45786b),
                onChanged: onChanged,
              ),
            ),
            const Text('10', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая рецензия', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF45786b),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название'),
                style: const TextStyle(color: Colors.white),
                validator: (v) => v == null || v.trim().isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedType.isEmpty ? null : selectedType,
                decoration: const InputDecoration(labelText: 'Тип'),
                items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => selectedType = val ?? ''),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: favCharController,
                decoration: const InputDecoration(labelText: 'Понравившиеся персонажи'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: nonfavCharController,
                decoration: const InputDecoration(labelText: 'Непонравившиеся персонажи'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Комментарий', alignLabelWithHint: true),
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
              ),
              const Divider(height: 40, color: Colors.grey),

              // Слайдеры
              _buildSlider('Общая оценка:', remark, (v) => setState(() => remark = v)),
              _buildSlider('Атмосфера:', atmosphere, (v) => setState(() => atmosphere = v)),
              _buildSlider('Эмоции:', emotions, (v) => setState(() => emotions = v)),
              _buildSlider('Идея:', idea, (v) => setState(() => idea = v)),
              _buildSlider('Реализация:', realisation, (v) => setState(() => realisation = v)),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF45786b),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Готово', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}