import 'package:intl/intl.dart';

class DayEntry {
  int dayNumber;
  String date;
  String income; // Stored as string to match input fields, parsed as double for math
  String notes;
  bool saved;
  String? id;

  DayEntry({
    required this.dayNumber,
    required this.date,
    this.income = '',
    this.notes = '',
    this.saved = false,
    this.id,
  });

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    return DayEntry(
      dayNumber: json['dayNumber'] is int
          ? json['dayNumber']
          : int.tryParse(json['dayNumber']?.toString() ?? '1') ?? 1,
      date: json['date']?.toString() ?? '',
      income: json['income']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      saved: json['saved'] == true,
      id: json['_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'date': date,
      'income': income,
      'notes': notes,
      'saved': saved,
    };
  }

  double get incomeValue {
    if (income.trim().isEmpty) return 0.0;
    return double.tryParse(income.replaceAll(',', '').trim()) ?? 0.0;
  }
}

class KitabStats {
  final double totalIncome;
  final double avgIncome;
  final int daysCompleted;
  final int daysRemaining;
  final double progress;

  KitabStats({
    required this.totalIncome,
    required this.avgIncome,
    required this.daysCompleted,
    required this.daysRemaining,
    required this.progress,
  });
}

class Kitab {
  final String id;
  final String? userId;
  final String? username;
  String title;
  int number;
  String startDate;
  String endDate;
  List<DayEntry> days;
  bool completed;
  String createdAt;
  String? spendMoney;
  String? handOver;
  String? iHave;
  String? moneyLeft;
  String? masara;
  bool moneySaved;

  Kitab({
    required this.id,
    this.userId,
    this.username,
    required this.title,
    required this.number,
    required this.startDate,
    required this.endDate,
    required this.days,
    this.completed = false,
    required this.createdAt,
    this.spendMoney,
    this.handOver,
    this.iHave,
    this.moneyLeft,
    this.masara,
    this.moneySaved = false,
  });

  factory Kitab.fromJson(Map<String, dynamic> json) {
    var rawDays = json['days'];
    List<DayEntry> parsedDays = [];
    if (rawDays is List) {
      parsedDays = rawDays.map((d) => DayEntry.fromJson(d)).toList();
    }

    return Kitab(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      username: json['username']?.toString(),
      title: json['title']?.toString() ?? 'Kitab',
      number: json['number'] is int
          ? json['number']
          : int.tryParse(json['number']?.toString() ?? '1') ?? 1,
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      days: parsedDays,
      completed: json['completed'] == true,
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      spendMoney: json['spendMoney']?.toString(),
      handOver: json['handOver']?.toString() ?? json['moneyLeft']?.toString(),
      iHave: json['iHave']?.toString() ?? json['masara']?.toString(),
      moneyLeft: json['moneyLeft']?.toString() ?? json['handOver']?.toString(),
      masara: json['masara']?.toString() ?? json['iHave']?.toString(),
      moneySaved: json['moneySaved'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      if (username != null) 'username': username,
      'title': title,
      'number': number,
      'startDate': startDate,
      'endDate': endDate,
      'days': days.map((d) => d.toJson()).toList(),
      'completed': completed,
      'createdAt': createdAt,
      'spendMoney': spendMoney,
      'handOver': handOver,
      'iHave': iHave,
      'moneyLeft': handOver ?? moneyLeft,
      'masara': iHave ?? masara,
      'moneySaved': moneySaved,
    };
  }

  KitabStats get stats {
    final filledDays = days.where((d) => d.saved && d.income.trim().isNotEmpty).toList();
    final total = filledDays.fold<double>(0.0, (sum, d) => sum + d.incomeValue);
    final completedCount = filledDays.length;
    final remaining = 15 - completedCount;
    final avg = completedCount > 0 ? total / completedCount : 0.0;
    final prog = (completedCount / 15.0) * 100.0;

    return KitabStats(
      totalIncome: total,
      avgIncome: avg,
      daysCompleted: completedCount,
      daysRemaining: remaining < 0 ? 0 : remaining,
      progress: prog.clamp(0.0, 100.0),
    );
  }

  static String formatPKR(num amount) {
    final formatter = NumberFormat('#,##,###', 'en_PK');
    return formatter.format(amount.round());
  }

  static String formatDate(String dateStr) {
    try {
      final d = DateTime.parse('${dateStr}T00:00:00');
      return DateFormat('MMMM d, y').format(d);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatKitabDate(String dateStr) {
    try {
      final d = DateTime.parse('${dateStr}T00:00:00');
      return DateFormat('d MMM y').format(d);
    } catch (_) {
      return dateStr;
    }
  }

  static String getDayName(String dateStr) {
    try {
      final d = DateTime.parse('${dateStr}T00:00:00');
      return DateFormat('EEEE').format(d);
    } catch (_) {
      return '';
    }
  }

  static bool isFriday(String dateStr) {
    return getDayName(dateStr).toLowerCase() == 'friday';
  }

  static Kitab createNew({
    required DateTime start,
    required int existingCount,
    required String? username,
    required String? userId,
  }) {
    final id = 'kitab_${DateTime.now().millisecondsSinceEpoch}';
    final number = existingCount + 1;
    final end = start.add(const Duration(days: 14));

    final startStr = DateFormat('yyyy-MM-dd').format(start);
    final endStr = DateFormat('yyyy-MM-dd').format(end);

    final titleStart = DateFormat('MMM d').format(start);
    final titleEnd = DateFormat('MMM d, y').format(end);
    final title = 'Kitab #$number – $titleStart to $titleEnd';

    List<DayEntry> days = [];
    for (int i = 0; i < 15; i++) {
      final currentDay = start.add(Duration(days: i));
      days.add(DayEntry(
        dayNumber: i + 1,
        date: DateFormat('yyyy-MM-dd').format(currentDay),
        income: '',
        notes: '',
        saved: false,
      ));
    }

    return Kitab(
      id: id,
      userId: userId,
      username: username,
      title: title,
      number: number,
      startDate: startStr,
      endDate: endStr,
      days: days,
      completed: false,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
