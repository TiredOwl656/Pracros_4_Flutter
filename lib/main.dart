import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotesProvider(),
      child: const MyApp(),
    ),
  );
}

class Note {
  final String id;
  String title;
  String content;

  Note({required this.id, required this.title, required this.content});
}

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [
    Note(id: '1', title: 'Первая заметка', content: 'Пример содержания'),
    Note(id: '2', title: 'Вторая заметка', content: 'Ещё один пример'),
  ];

  List<Note> get notes => _notes;

  void addNote(String title, String content) {
    _notes.add(Note(
      id: DateTime.now().toString(),
      title: title,
      content: content,
    ));
    notifyListeners();
  }

  void updateNote(String id, String newTitle, String newContent) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index].title = newTitle;
      _notes[index].content = newContent;
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  void reorderNotes(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Note item = _notes.removeAt(oldIndex);
    _notes.insert(newIndex, item);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мои заметки',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/add':
            return MaterialPageRoute(builder: (_) => const AddEditNoteScreen());
          case '/edit':
            final note = settings.arguments as Note;
            return MaterialPageRoute(
              builder: (_) => AddEditNoteScreen(note: note),
            );
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заметки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add'),
          ),
        ],
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.all(8),
        onReorder: (oldIndex, newIndex) {
          notesProvider.reorderNotes(oldIndex, newIndex);
        },
        children: [
          for (final note in notesProvider.notes)
            Card(
              key: ValueKey(note.id),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(note.title),
                subtitle: Text(note.content),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/edit',
                        arguments: note,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => notesProvider.deleteNote(note.id),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать заметку' : 'Новая заметка'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Содержание',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  if (isEditing) {
                    notesProvider.updateNote(
                      widget.note!.id,
                      _titleController.text,
                      _contentController.text,
                    );
                  } else {
                    notesProvider.addNote(
                      _titleController.text,
                      _contentController.text,
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Сохранить' : 'Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}