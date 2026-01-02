import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; 
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../services/journal_storage.dart';
import 'journal_detail.dart';
import 'journal_screen.dart'; 
import '../utils/theme.dart';

class JournalEntriesPage extends StatefulWidget {
  const JournalEntriesPage({Key? key}) : super(key: key);

  @override
  State<JournalEntriesPage> createState() => _JournalEntriesPageState();
}

class _JournalEntriesPageState extends State<JournalEntriesPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; 
  late Future<List<JournalEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _selectedDay = null; 
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _entriesFuture = JournalStorage.getEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Dynamic Theme Colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final primaryGreen = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;

    final todayStr = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text('Journal Calendar', 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: scaffoldBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        icon: Icon(Icons.edit, color: isDark ? AppTheme.darkBackground : Colors.white),
        label: Text("New Entry", 
          style: TextStyle(color: isDark ? AppTheme.darkBackground : Colors.white)),
        onPressed: () => _navigateToNewEntry(_selectedDay ?? DateTime.now()),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 10),
            alignment: Alignment.center,
            child: Text(
              "Today is $todayStr",
              style: TextStyle(
                fontSize: 16, 
                color: textColor?.withOpacity(0.6), 
                fontWeight: FontWeight.w600
              ),
            ),
          ),

          // 📅 CALENDAR (Themed)
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            currentDay: DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            availableCalendarFormats: const { CalendarFormat.month: 'Month' }, 
            
            headerStyle: HeaderStyle(
              formatButtonVisible: false, 
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
              rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
            ),
            
            calendarStyle: CalendarStyle(
              // Selection & Today
              selectedDecoration: BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: AppTheme.cocoa.withOpacity(0.3), shape: BoxShape.circle),
              
              // Text Colors
              todayTextStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              defaultTextStyle: TextStyle(color: textColor),
              weekendTextStyle: TextStyle(color: isDark ? AppTheme.darkMatcha.withOpacity(0.8) : AppTheme.cocoa),
              outsideTextStyle: TextStyle(color: textColor?.withOpacity(0.3)),
              
              // Row/Cell Styling
              tableBorder: const TableBorder(
                top: BorderSide.none,
                bottom: BorderSide.none,
                left: BorderSide.none,
                right: BorderSide.none,
                horizontalInside: BorderSide.none,
                verticalInside: BorderSide.none,
),

            ),

            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: textColor?.withOpacity(0.7), fontWeight: FontWeight.bold),
              weekendStyle: TextStyle(color: primaryGreen.withOpacity(0.7), fontWeight: FontWeight.bold),
            ),

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          
          const SizedBox(height: 10),
          Divider(color: theme.dividerColor),

          Expanded(
            child: FutureBuilder<List<JournalEntry>>(
              future: _entriesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final allEntries = snapshot.data!;
                List<JournalEntry> displayEntries;
                
                if (_selectedDay == null) {
                  displayEntries = List.from(allEntries);
                  displayEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                } else {
                  displayEntries = allEntries.where((entry) => 
                    isSameDay(entry.timestamp, _selectedDay)
                  ).toList();
                }

                if (displayEntries.isEmpty) {
                  return Center(
                    child: GestureDetector(
                      onTap: () => _navigateToNewEntry(_selectedDay ?? DateTime.now()),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.create, size: 40, color: textColor?.withOpacity(0.3)),
                          const SizedBox(height: 10),
                          Text(
                            _selectedDay == null 
                                ? "No entries yet.\nStart your journey today!" 
                                : "No entries for this day.\nTap here to write!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textColor?.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: displayEntries.length,
                  itemBuilder: (context, index) {
                    final entry = displayEntries[index];
                    final entryDate = DateFormat('MMM d, h:mm a').format(entry.timestamp);

                    return Card(
                      color: surfaceColor, // ☕ Uses darkSurface or latteFoam
                      elevation: isDark ? 2 : 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          entry.title ?? "Untitled", 
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        ),
                        subtitle: Text(
                          "$entryDate\n${entry.content}", 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textColor?.withOpacity(0.7)),
                        ),
                        isThreeLine: true,
                        trailing: entry.getStickers().isNotEmpty 
                           ? Icon(Icons.emoji_emotions, color: primaryGreen)
                           : null,
                        onTap: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => JournalDetailScreen(entry: entry)),
                          ).then((_) => _loadEntries());
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToNewEntry(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalScreen(
          selectedDate: date, 
          emotion: "Neutral", 
        ),
      ),
    ).then((_) => _loadEntries());
  }
}