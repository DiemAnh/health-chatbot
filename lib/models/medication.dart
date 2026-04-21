class MedicationRequest {
  String name;
  int dosageAmount;
  String dosageUnit;
  String frequency;
  int totalQuantity;
  String medicationTime1;
  String? medicationTime2;
  String? medicationTime3;
  String startDate;
  String endDate;

  MedicationRequest({
    required this.name,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.frequency,
    required this.totalQuantity,
    required this.medicationTime1,
    this.medicationTime2,
    this.medicationTime3,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "dosageAmount": dosageAmount,
    "dosageUnit": dosageUnit,
    "frequency": frequency,
    "totalQuantity": totalQuantity,
    "medicationTime1": medicationTime1,
    "medicationTime2": medicationTime2,
    "medicationTime3": medicationTime3,
    "startDate": startDate,
    "endDate": endDate,
  };
}