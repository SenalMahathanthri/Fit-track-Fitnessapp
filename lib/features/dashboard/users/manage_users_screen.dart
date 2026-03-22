import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _updateUserRole(String userId, String newRole) async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(userId).update({'role': newRole});
      Get.snackbar('Success', 'User role updated to $newRole');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user role: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : FutureBuilder<QuerySnapshot>(
        future: _firestore.collection('users').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading users"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final doc = users[index];
              final userData = doc.data() as Map<String, dynamic>;
              final user = UserModel.fromMap(doc.id, userData);
              final currentRole = user.role;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(user.name.isNotEmpty ? user.name : user.email, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Email: ${user.email}"),
                  trailing: DropdownButton<String>(
                    value: ['admin', 'coach', 'customer'].contains(currentRole) ? currentRole : 'customer',
                    items: const [
                      DropdownMenuItem(value: 'customer', child: Text('Customer')),
                      DropdownMenuItem(value: 'coach', child: Text('Coach')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      if (value != null && value != currentRole) {
                        _updateUserRole(doc.id, value);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
