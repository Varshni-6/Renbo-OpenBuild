import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_storage.dart';
import 'journal_detail.dart';
import 'journal_edit_screen.dart';

class JournalEntriesPage extends StatefulWidget {
  const JournalEntriesPage({Key? key}) : super(key: key);

  @override
  State<JournalEntriesPage> createState() => _JournalEntriesPageState();
}

class _JournalEntriesPageState extends State<JournalEntriesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal Entries')),
      body: StreamBuilder<List<JournalEntry>>(
        // 🔥 Real-time Firestore stream
        stream: JournalStorage.getEntriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No journal entries available.'),
            );
          }

          final entries = snapshot.data!;

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];

              return ListTile(
                key: Key(entry.id),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.content.isEmpty ? "Journal Entry" : entry.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 🎤 Show mic icon if audio exists
                    if (entry.audioPath != null)
                      const Icon(Icons.mic, color: Colors.grey, size: 18),
                  ],
                ),
                subtitle: Text(entry.timestamp.toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JournalDetailScreen(entry: entry),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✏️ EDIT
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JournalEditScreen(entry: entry),
                          ),
                        );
                        // No manual refresh needed — stream updates automatically
                      },
                    ),
                    // 🗑 DELETE
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await JournalStorage.deleteEntry(entry.id);
                        // No reload call needed
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
