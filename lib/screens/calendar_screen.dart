import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; 
import '../models/journal_entry.dart';
import '../services/journal_storage.dart';
import 'journal_screen.dart';
import 'journal_entries.dart'; 
import '../utils/theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  final Map<String, String> _moodEmojis = {
    'Happy': '😄',
    'Sad': '😢',
    'Angry': '😠',
    'Confused': '🤔',
    'Excited': '🥳',
    'Calm': '😌',
    'Neutral': '😐',
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = null; 
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Grab Dynamic Theme Colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final primaryGreen = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;

    final todayStr = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: scaffoldBg, // Fix: Changed from AppTheme.oatMilk
      appBar: AppBar(
        title: Text('Journal Calendar', 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: scaffoldBg, // Fix: Changed from AppTheme.oatMilk
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        icon: Icon(Icons.edit, color: isDark ? AppTheme.darkBackground : Colors.white),
        label: Text("New Entry", 
          style: TextStyle(color: isDark ? AppTheme.darkBackground : Colors.white)),
        onPressed: () {
          _showMoodSelector(context, _selectedDay ?? DateTime.now());
        },
      ),

      body: Column(
        children: [
          // 1. HEADER
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

          // 2. CALENDAR (Themed)
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
              selectedDecoration: BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: AppTheme.cocoa.withOpacity(0.3), shape: BoxShape.circle),
              
              // Text Colors
              todayTextStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              defaultTextStyle: TextStyle(color: textColor),
              weekendTextStyle: TextStyle(color: isDark ? AppTheme.darkMatcha : AppTheme.cocoa),
              outsideTextStyle: TextStyle(color: textColor?.withOpacity(0.3)),
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
              _showMoodSelector(context, selectedDay);
            },
          ),
          
          const SizedBox(height: 30),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 30),

          // 3. THE VIEW ALL BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? surfaceColor : AppTheme.espresso,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 55),
                elevation: isDark ? 2 : 0,
              ),
              icon: const Icon(Icons.history_edu, color: Colors.white),
              label: const Text("View All Journal Entries", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JournalEntriesPage()),
                );
              },
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }
  
  // 🌙 MOOD SELECTOR (Themed Dialog)
  void _showMoodSelector(BuildContext context, DateTime selectedDate) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;
    final surfaceColor = theme.colorScheme.surface;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: surfaceColor, // Fix: Use theme surface
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'How are you feeling?', 
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)
          ),
          content: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.center,
            children: _moodEmojis.entries.map((entry) {
              return InkWell(
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _navigateToNewEntry(selectedDate, entry.key);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkBackground : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : Colors.black12, 
                            blurRadius: 4, 
                            offset: const Offset(0, 2)
                          )
                        ]
                      ),
                      child: Text(entry.value, style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(height: 4),
                    Text(entry.key, 
                      style: TextStyle(fontSize: 12, color: textColor?.withOpacity(0.8))),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _navigateToNewEntry(DateTime date, String emotion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalScreen(selectedDate: date, emotion: emotion),
      ),
    );
  }
}