import 'package:flutter/material.dart';

class MyStreakCard extends StatelessWidget {
  final int streakWeeks;
  final List<bool> activeDays; // True for active days, false for inactive

  const MyStreakCard({
    super.key,
    required this.streakWeeks,
    required this.activeDays,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.grey[900] : const Color.fromARGB(71, 129, 189, 226),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(width: 1.0),
      ),
      child: Column(
        children: [
          // Streak title with fire icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$streakWeeks-week streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text('🔥', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 8),
          // Motivational message
          const Text(
            'Study next week to keep your streak going!',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Days row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
              final isActive = activeDays[index];
              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.blue : Colors.transparent,
                  border: Border.all(
                    color: isActive ? Colors.blue : Colors.grey[600]!,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
