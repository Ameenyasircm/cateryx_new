class BoyRequestModel {
  final String docId;
  final String name;
  final String phone;
  final String guardianPhone;
  final String bloodGroup;
  final String dob;
  final String address;
  final String place;
  final String district;
  final String pinCode;
  final String status;

  BoyRequestModel({
    required this.docId,
    required this.name,
    required this.phone,
    required this.guardianPhone,
    required this.bloodGroup,
    required this.dob,
    required this.address,
    required this.place,
    required this.district,
    required this.pinCode,
    required this.status,
  });

  factory BoyRequestModel.fromDoc(
      Map<String, dynamic> map, String docId) {
    return BoyRequestModel(
      docId: docId,
      name: map['NAME'] ?? '',
      phone: map['PHONE'] ?? '',
      guardianPhone: map['GUARDIAN_PHONE'] ?? '',
      bloodGroup: map['BLOOD_GROUP'] ?? '',
      dob: map['DOB'] ?? '',
      address: map['ADDRESS'] ?? '',
      place: map['PLACE'] ?? '',
      district: map['DISTRICT'] ?? '',
      pinCode: map['PIN_CODE'] ?? '',
      status: map['STATUS'] ?? '',
    );
  }
}
