// import 'dart:convert';
// import 'package:health_chatbot/screens/user_screen_action/add_user_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:health_chatbot/screens/user_screen_action/edit_user_screen.dart';
// import '../services/api_service.dart';
// import '../constants/api_constants.dart';

// class UserScreen extends StatefulWidget {
//   const UserScreen({super.key});

//   @override
//   State<UserScreen> createState() => _UserScreenState();
// }

// class _UserScreenState extends State<UserScreen> {
//   final ApiService _api = ApiService();

//   List users = [];
//   bool loading = false;

//   @override
//   void initState() {
//     super.initState();
//     loadUsers();
//   }

//   Future<void> loadUsers() async {
//     setState(() => loading = true);

//     final res = await _api.get(ApiConstants.users, auth: true);

//     if (res.statusCode == 200) {
//       setState(() {
//         users = jsonDecode(res.body);
//       });
//     }

//     setState(() => loading = false);
//   }

//   Future<void> deleteUser(int id) async {
//     final res =
//         await _api.post("${ApiConstants.deleteUser}/$id", auth: true);

//     if (res.statusCode == 200) {
//       loadUsers();
//     }
//   }

//   void confirmDelete(int id) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Delete user?"),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel")),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               deleteUser(id);
//             },
//             child: const Text("Delete",
//                 style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void goAdd() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddUserScreen()),
//     );

//     if (result == true) loadUsers();
//   }

//   void goEdit(Map item) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => EditUserScreen(user: item),
//       ),
//     );

//     if (result == true) loadUsers();
//   }

//   Color statusColor(bool active) =>
//       active ? Colors.green : Colors.red;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Users"),
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: loadUsers),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: goAdd,
//         child: const Icon(Icons.add),
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: users.length,
//               itemBuilder: (_, i) {
//                 final u = users[i];

//                 return Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                    shadowColor: Colors.transparent,
//                     child: ListTile(
//                       title: Row(
//                         children: [
//                           Text(u['name'] ?? ''),
//                             const SizedBox(width: 4),
//                            Icon(
//                             Icons.circle,
//                             size: 12,
//                             color: statusColor(u['activation']),
//                           ),
//                         ],
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: [
//                           Text("Role: ${u['role']}"),
//                           Text("Name: ${u['fullName'] ?? ''}"),
//                           Text("Phone: ${u['phone'] ?? ''}"),
//                         ],
//                       ),
//                       trailing: Column(
//                         mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                         children: [
                        
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.edit_outlined),
//                                 onPressed: u['canEdit'] == true
//                                     ? () => goEdit(u)
//                                     : null,
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.delete_outlined,
//                                     color: Colors.red),
//                                 onPressed: u['canEdit'] == true
//                                     ? () => confirmDelete(u['id'])
//                                     : null,
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }