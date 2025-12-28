import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/time_capsule.dart';

class CapsuleCard extends StatelessWidget {
  final TimeCapsule capsule;
  final VoidCallback onTap;

  const CapsuleCard({
    super.key,
    required this.capsule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReady = capsule.isReady;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isReady ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          boxShadow: isReady
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : [],
          border: Border.all(
            color: isReady
                ? const Color(0xFF8E97FD).withOpacity(0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isReady
                    ? const Color(0xFF8E97FD).withOpacity(0.1)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isReady ? Icons.auto_awesome : Icons.lock_person_rounded,
                color: isReady ? const Color(0xFF8E97FD) : Colors.grey[500],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Text Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isReady ? "Ready to Open" : "Sealed Capsule",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isReady ? const Color(0xFF8E97FD) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isReady
                        ? "Arrived on ${DateFormat('MMM d').format(capsule.deliveryDate)}"
                        : "Unlocks on ${DateFormat('MMM d, yyyy').format(capsule.deliveryDate)}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Trailing arrow or countdown
            if (isReady)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
            else
              const Icon(Icons.timer_outlined, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
