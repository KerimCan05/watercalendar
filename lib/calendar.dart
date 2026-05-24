import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CalendarEntry {
  final DateTime date;
  final int glass;
  final int ml;

  CalendarEntry({
    required this.date,
    required this.glass,
    required this.ml,
  });
}

class WaterCalendar extends StatelessWidget {
  const WaterCalendar({super.key});

  Future<List<CalendarEntry>> _loadEntries() async {
    final box = Hive.box('calendarBox');
    final entries = <CalendarEntry>[];

    for (final key in box.keys) {
      final dateKey = key as String;
      final data = box.get(key) as Map?;
      if (data == null) continue;

      final date = DateTime.parse(dateKey);
      entries.add(
        CalendarEntry(
          date: date,
          glass: data['glass'] as int? ?? 0,
          ml: data['ml'] as int? ?? 0,
        ),
      );
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Map<String, List<CalendarEntry>> _groupByMonth(List<CalendarEntry> entries) {
    final grouped = <String, List<CalendarEntry>>{};
    for (final entry in entries) {
      final key = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    return grouped;
  }

  String _monthLabel(String monthKey) {
    final parts = monthKey.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);

    const names = [
      'January','Febuary','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${names[month - 1]} $year';
  }

  Widget _buildDayRow(CalendarEntry entry) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${entry.date.day}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.ml} ml',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${entry.glass} glass(es)',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar')),
      body: FutureBuilder<List<CalendarEntry>>(
        future: _loadEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Drink some water'));
          }

          final grouped = _groupByMonth(snapshot.data!);
          final monthKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView(
            padding: EdgeInsets.symmetric(vertical: 12),
            children: [
              for (final monthKey in monthKeys) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    _monthLabel(monthKey),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                for (final entry in grouped[monthKey]!) _buildDayRow(entry),
              ],
            ],
          );
        },
      ),
    );
  }
}