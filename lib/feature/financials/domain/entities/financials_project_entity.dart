class PaymentScheduleItemEntity {
  final String title;
  final String dateLabel;
  final int amount;
  final bool isPaid;

  const PaymentScheduleItemEntity({
    required this.title,
    required this.dateLabel,
    required this.amount,
    required this.isPaid,
  });
}

class PaymentScheduleSectionEntity {
  final String title;
  final List<PaymentScheduleItemEntity> items;

  const PaymentScheduleSectionEntity({
    required this.title,
    required this.items,
  });
}

class FinancialsProjectEntity {
  final String id;
  final String projectName;
  final String projectAddress;
  final String? thumbnailUrl;
  final int totalBudget;
  final int paidToDate;
  final int remainingBalance;
  final int paidPercent;
  final List<PaymentScheduleSectionEntity> scheduleSections;

  const FinancialsProjectEntity({
    required this.id,
    required this.projectName,
    required this.projectAddress,
    this.thumbnailUrl,
    required this.totalBudget,
    required this.paidToDate,
    required this.remainingBalance,
    required this.paidPercent,
    required this.scheduleSections,
  });
}
