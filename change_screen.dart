import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/review.dart';

class ChangeScreen extends StatefulWidget {
  final Review review;
  const ChangeScreen({super.key, required this.review});

  @override
  State<ChangeScreen> createState() => _ChangeScreenState();
}

class _ChangeScreenState extends State<ChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final String apiUrl = 'http://10.0.2.2:3000/api';

  late TextEditingController nameController;
  late TextEditingController favCharController;
  late TextEditingController nonfavCharController;
  late TextEditingController commentController;

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
    nameController = TextEditingController(text: widget.review.name);
    favCharController = TextEditingController(text: widget.review.favChar);
    nonfavCharController = TextEditingController(text: widget.review.nonfavChar);
    commentController = TextEditingController(text: widget.review.comment);

    selectedType = widget.review.type;
    remark = widget.review.remark.toDouble();
    atmosphere = widget.review.atmosphere.toDouble();
    emotions = widget.review.emotions.toDouble();
    idea = widget.review.idea.toDouble();
    realisation = widget.review.realisation.toDouble();

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

  Future<void> updateReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final updatedReview = {
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
      final response = await http.put(
        Uri.parse('$apiUrl/review/${widget.review.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedReview),
      );

      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка при обновлении')));
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
        title: const Text('Редактирование', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onPressed: isSubmitting ? null : updateReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF45786b),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Изменить', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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