import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/time_capsule.dart';
import '../providers/capsule_provider.dart';
import '../widgets/capsule_card.dart';
import 'create_capsule_screen.dart';
import '../utils/theme.dart'; // Import your theme file

class CapsuleVaultScreen extends StatelessWidget {
  const CapsuleVaultScreen({super.key});

  /// Helper to calculate the most relevant time unit for the countdown
  String _getTimeRemainingText(TimeCapsule capsule) {
    final diff = capsule.deliveryDate.difference(DateTime.now());
    if (diff.isNegative || diff.inSeconds <= 0) return "Ready to open!";

    if (diff.inDays > 0) return "Unlocks in ${diff.inDays}d";
    if (diff.inHours > 0) return "Unlocks in ${diff.inHours}h";
    if (diff.inMinutes > 0) return "Unlocks in ${diff.inMinutes}m";
    return "Unlocks in ${diff.inSeconds}s";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.titleLarge?.color;
    final primaryAccent = theme.colorScheme.primary;

    final capsuleProvider = Provider.of<CapsuleProvider>(context);
    final allCapsules = capsuleProvider.capsules;

    final now = DateTime.now();
    final unlocked = allCapsules.where((c) => now.isAfter(c.deliveryDate)).toList();
    final locked = allCapsules.where((c) => now.isBefore(c.deliveryDate)).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
          title: Text(
            "Emotional Vault",
            style: TextStyle(
              color: textColor,
              fontFamily: 'Poppins', 
              fontWeight: FontWeight.bold
            ),
          ),
          bottom: TabBar(
            tabs: const [
              Tab(text: "Unlocked", icon: Icon(Icons.lock_open)),
              Tab(text: "Locked", icon: Icon(Icons.lock_outline)),
            ],
            indicatorColor: primaryAccent,
            labelColor: primaryAccent,
            unselectedLabelColor: textColor?.withOpacity(0.5),
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, unlocked),
            _buildList(context, locked),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryAccent,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateCapsuleScreen()),
          ),
          child: Icon(Icons.add, color: isDark ? AppTheme.darkBackground : Colors.white),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<TimeCapsule> list) {
    final theme = Theme.of(context);
    
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Your vault is currently empty.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5), 
              fontFamily: 'Poppins'
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final capsule = list[index];
        final bool isReadyNow = DateTime.now().isAfter(capsule.deliveryDate);

        return CapsuleCard(
          capsule: capsule,
          onTap: () {
            if (isReadyNow) {
              _showContent(context, capsule);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Patience! ${_getTimeRemainingText(capsule)}"),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _showContent(BuildContext context, TimeCapsule capsule) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface, // Uses Coffee Bean in dark mode
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.orangeAccent, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              "A Message from the Past",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 15),
            Text(
              capsule.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 30),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 10),
            Text(
              "Sealed on ${DateFormat('MMMM dd, yyyy').format(capsule.createdAt)}",
              style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 13),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text("Close",
                    style: TextStyle(
                      color: isDark ? AppTheme.darkBackground : Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}