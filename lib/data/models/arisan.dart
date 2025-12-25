class Arisan {
  final String id;
  final String name; // Nama arisan/yang ngadain
  final String memberId; // Member yang ngadain arisan
  final DateTime startDate; // Tanggal mulai arisan
  final int cycleLengthMonths; // Berapa bulan siklus arisan (biasanya 10-12)
  final double monthlyAmount; // Jumlah bayar per bulan
  final List<String> participantMemberIds; // List member yang ikut arisan
  final int userPosition; // Posisi user dalam urutan penerima (1, 2, 3, ...)
  final List<ArisanPayment> paymentHistory; // History pembayaran
  final String status; // 'active', 'completed', 'on_hold'
  final DateTime createdAt;

  Arisan({
    String? id,
    required this.name,
    required this.memberId,
    required this.startDate,
    required this.cycleLengthMonths,
    required this.monthlyAmount,
    required this.participantMemberIds,
    required this.userPosition,
    List<ArisanPayment>? paymentHistory,
    this.status = 'active',
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        paymentHistory = paymentHistory ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Get next payment date
  DateTime getNextPaymentDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var nextDate = DateTime(startDate.year, startDate.month, startDate.day);
    
    while (nextDate.isBefore(today)) {
      nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
    }
    
    return nextDate;
  }

  // Get when user will receive arisan
  DateTime getUserReceiveDate() {
    var receiveDate = startDate;
    for (int i = 1; i < userPosition; i++) {
      receiveDate = DateTime(receiveDate.year, receiveDate.month + 1, receiveDate.day);
    }
    return receiveDate;
  }

  // Check if user already received
  bool hasUserReceived() {
    return getUserReceiveDate().isBefore(DateTime.now());
  }

  // Get total amount user will receive
  double getTotalReceiveAmount() {
    return monthlyAmount * participantMemberIds.length;
  }

  // Get days until next payment
  int getDaysUntilNextPayment() {
    final nextDate = getNextPaymentDate();
    return nextDate.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'memberId': memberId,
      'startDate': startDate.toIso8601String(),
      'cycleLengthMonths': cycleLengthMonths,
      'monthlyAmount': monthlyAmount,
      'participantMemberIds': participantMemberIds,
      'userPosition': userPosition,
      'paymentHistory': paymentHistory.map((p) => p.toJson()).toList(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Arisan.fromJson(Map<String, dynamic> json) {
    return Arisan(
      id: json['id'],
      name: json['name'],
      memberId: json['memberId'],
      startDate: DateTime.parse(json['startDate']),
      cycleLengthMonths: json['cycleLengthMonths'],
      monthlyAmount: (json['monthlyAmount'] as num).toDouble(),
      participantMemberIds: List<String>.from(json['participantMemberIds']),
      userPosition: json['userPosition'],
      paymentHistory: (json['paymentHistory'] as List?)
          ?.map((p) => ArisanPayment.fromJson(p))
          .toList(),
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ArisanPayment {
  final String id;
  final String arisanId;
  final String payerMemberId; // Siapa yang bayar di bulan ini
  final double amount;
  final DateTime paymentDate;
  final bool isPaid;

  ArisanPayment({
    String? id,
    required this.arisanId,
    required this.payerMemberId,
    required this.amount,
    required this.paymentDate,
    this.isPaid = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arisanId': arisanId,
      'payerMemberId': payerMemberId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'isPaid': isPaid,
    };
  }

  factory ArisanPayment.fromJson(Map<String, dynamic> json) {
    return ArisanPayment(
      id: json['id'],
      arisanId: json['arisanId'],
      payerMemberId: json['payerMemberId'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
      isPaid: json['isPaid'] ?? false,
    );
  }
}
