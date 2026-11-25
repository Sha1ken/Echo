import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import 'change_screen.dart';

class LookScreen extends StatefulWidget {
  final int reviewId;
  const LookScreen({super.key, required this.reviewId});

  @override
  State<LookScreen> createState() => _LookScreenState();
}

class _LookScreenState extends State<LookScreen> {
  Review? review;
  bool isLoading = true;
  final String apiUrl = 'http://10.0.2.2:3000/api';

  @override
  void initState() {
    super.initState();
    fetchReview();
  }

  Future<void> fetchReview() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/review/${widget.reviewId}'));
      if (response.statusCode == 200) {
        setState(() {
          review = Review.fromJson(jsonDecode(response.body));
        });
      }
    } catch (e) {
      print('Ошибка: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteReview() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление'),
        content: const Text('Вы уверены, что хотите удалить эту рецензию?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await http.delete(Uri.parse('$apiUrl/review/${widget.reviewId}'));
        if (mounted) Navigator.pop(context); // Возврат к списку
      } catch (e) {
        print('Ошибка удаления: $e');
      }
    }
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF212121),
            border: Border.all(color: const Color(0xFF555555)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value, style: const TextStyle(color: Color(0xFFf0f0f0), fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildReadOnlySlider(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        Row(
          children: [
            const Text('1', style: TextStyle(color: Colors.grey)),
            Expanded(
              child: IgnorePointer(
                child: Slider(
                  value: value.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: const Color(0xFF45786b),
                  onChanged: (val) {},
                ),
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
        title: const Text('Ваша рецензия', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF45786b),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              if (review != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeScreen(review: review!)),
                );
                fetchReview();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: deleteReview,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : review == null
          ? const Center(child: Text('Ошибка загрузки'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildReadOnlyField('Название:', review!.name),
            const SizedBox(height: 16),
            _buildReadOnlyField('Тип:', review!.type),
            const SizedBox(height: 16),
            _buildReadOnlyField('Понравившиеся персонажи:', review!.favChar.isEmpty ? '-' : review!.favChar),
            const SizedBox(height: 16),
            _buildReadOnlyField('Непонравившиеся персонажи:', review!.nonfavChar.isEmpty ? '-' : review!.nonfavChar),
            const SizedBox(height: 16),
            _buildReadOnlyField('Комментарий:', review!.comment.isEmpty ? '-' : review!.comment),
            const Divider(height: 40, color: Colors.grey),
            _buildReadOnlySlider('Общая оценка:', review!.remark),
            _buildReadOnlySlider('Атмосфера:', review!.atmosphere),
            _buildReadOnlySlider('Эмоции:', review!.emotions),
            _buildReadOnlySlider('Идея:', review!.idea),
            _buildReadOnlySlider('Реализация:', review!.realisation),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}