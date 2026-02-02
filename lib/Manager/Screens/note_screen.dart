import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatefulWidget {
  final String eventId; // EVT1769008855532

  const NotesScreen({super.key, required this.eventId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<EventDetailsProvider>(context, listen: false)
        .listenNotes(widget.eventId);
  }

  void _showAddNoteDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add New Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  hintText: "Title",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Description",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty &&
                    descCtrl.text.trim().isNotEmpty) {
                  Provider.of<EventDetailsProvider>(context, listen: false)
                      .addNewNote(
                    eventId: widget.eventId,
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventDetailsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Notes"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: const Icon(Icons.add),
      ),

      body: provider.notesList.isEmpty
          ? const Center(child: Text("No notes added"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: provider.notesList.length,
        itemBuilder: (ctx, i) {
          final note = provider.notesList[i];
          return Card(
            child: ListTile(
              title: Text(note.title),
              subtitle: Text(note.description),
              trailing: Text(
                DateTime.fromMillisecondsSinceEpoch(note.createdTime)
                    .toString()
                    .substring(0, 16),
                style: const TextStyle(fontSize: 11),
              ),
            ),
          );
        },
      ),
    );
  }
}
