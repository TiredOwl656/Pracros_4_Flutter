import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'movie.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Box<Movie> _moviesBox;

  @override
  void initState() {
    super.initState();
    _moviesBox = Hive.box<Movie>('movies');
  }

  Future<void> _addMovie() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController yearController = TextEditingController();
    final TextEditingController genreController = TextEditingController();
    String? imagePath;

    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Добавить фильм'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Название'),
              ),
              TextField(
                controller: yearController,
                decoration: InputDecoration(labelText: 'Год выпуска'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: genreController,
                decoration: InputDecoration(labelText: 'Жанр'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    imagePath = pickedFile.path;
                    Navigator.pop(context, 'image_selected');
                  }
                },
                child: Text('Добавить изображение'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  yearController.text.isNotEmpty &&
                  genreController.text.isNotEmpty) {
                Navigator.pop(context, 'add');
              }
            },
            child: Text('Добавить'),
          ),
        ],
      ),
    );

    if (result == 'add' || result == 'image_selected') {
      final newMovie = Movie(
        id: DateTime.now().toString(),
        title: titleController.text,
        year: int.parse(yearController.text),
        genre: genreController.text,
        imagePath: imagePath,
      );
      await _moviesBox.add(newMovie);
      setState(() {});
    }
  }

  Future<void> _deleteMovie(int index) async {
    await _moviesBox.deleteAt(index);
    setState(() {});
  }

  Future<void> _showDeleteDialog(int index) async {
    final movie = _moviesBox.getAt(index);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить фильм?'),
        content: Text('Вы уверены, что хотите удалить "${movie?.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              _deleteMovie(index);
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
        title: Text('Мои любимые фильмы'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Movie>>(
        valueListenable: _moviesBox.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'Нет фильмов. Добавьте первый!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final movie = box.getAt(index)!;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: movie.imagePath != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(File(movie.imagePath!)),
                          radius: 25,
                        )
                      : CircleAvatar(
                          child: Icon(Icons.movie),
                          radius: 25,
                        ),
                  title: Text(movie.title),
                  subtitle: Text('${movie.year} • ${movie.genre}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(index),
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(
                          movie: movie,
                          index: index,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMovie,
        child: Icon(Icons.add),
      ),
    );
  }
}