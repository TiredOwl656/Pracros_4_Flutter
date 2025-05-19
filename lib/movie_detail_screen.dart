import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'movie.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final int index;

  const MovieDetailScreen({
    required this.movie,
    required this.index,
  });

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _yearController;
  late TextEditingController _genreController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie.title);
    _yearController = TextEditingController(text: widget.movie.year.toString());
    _genreController = TextEditingController(text: widget.movie.genre);
    _imagePath = widget.movie.imagePath;
  }

  Future<void> _updateMovie() async {
    final updatedMovie = Movie(
      id: widget.movie.id,
      title: _titleController.text,
      year: int.parse(_yearController.text),
      genre: _genreController.text,
      imagePath: _imagePath,
    );

    final box = Hive.box<Movie>('movies');
    await box.putAt(widget.index, updatedMovie);
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _deleteMovie() async {
    final box = Hive.box<Movie>('movies');
    await box.deleteAt(widget.index);
    Navigator.pop(context);
  }

  Future<void> _showDeleteDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить фильм?'),
        content: Text('Вы уверены, что хотите удалить "${widget.movie.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              _deleteMovie();
              Navigator.pop(context);
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактировать фильм'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _showDeleteDialog,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateMovie,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                backgroundImage: _imagePath != null
                    ? FileImage(File(_imagePath!))
                    : null,
                radius: 50,
                child: _imagePath == null ? Icon(Icons.add_a_photo, size: 40) : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: _yearController,
              decoration: InputDecoration(labelText: 'Год выпуска'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _genreController,
              decoration: InputDecoration(labelText: 'Жанр'),
            ),
          ],
        ),
      ),
    );
  }
}