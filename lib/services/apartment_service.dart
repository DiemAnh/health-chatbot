// import 'dart:convert';
// import 'package:health_chatbot/constants/api_constants.dart';

// import 'api_service.dart';

// class ApartmentService {
//   final ApiService _api = ApiService();

//   Future<List<dynamic>> getAll() async {
//     final res = await _api.get(ApiConstants.apartments, auth: true);

//     if (res.statusCode == 200) {
//       return jsonDecode(res.body);
//     }

//     throw Exception("Load apartments failed");
//   }

//   Future<dynamic> getById(int id) async {
//     final res = await _api.get(
//       "${ApiConstants.adminEditApartment}/$id",
//       auth: true,
//     );

//     if (res.statusCode == 200) {
//       return jsonDecode(res.body);
//     }

//     throw Exception("Get apartment failed");
//   }

//   Future<void> create(Map<String, dynamic> body) async {
//     final res = await _api.post(
//       ApiConstants.adminAddApartment,
//       body: body,
//     );

//     if (res.statusCode != 201) {
//       throw Exception("Create failed: ${res.body}");
//     }
//   }

//   Future<void> update(Map<String, dynamic> body) async {
//     final res = await _api.post(
//       "${ApiConstants.adminEditApartment}", 
//       body: body,
//     );

//     if (res.statusCode != 200) {
//       throw Exception("Update failed: ${res.body}");
//     }
//   }
// }