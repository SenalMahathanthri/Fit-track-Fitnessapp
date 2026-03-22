import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/models/workout_plan.dart';

class CoachController extends GetxController {
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> clients = <UserModel>[].obs;
  final RxList<WorkoutPlan> pendingPlans = <WorkoutPlan>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }
  
  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      
      // Fetch users (customers and legacy users without role field)
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      
      allUsers.value = usersSnapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['role'] ??= 'customer';
            return UserModel.fromMap(doc.id, data);
          }).toList();
          
      // Filter clients assigned to this coach
      clients.value = allUsers.where((u) => u.role == 'customer' && u.coachId == currentUserId).toList();
      
      final currentClientIds = clients.map((c) => c.uid).toSet();
      
      // Fetch pending plans
      final plansSnapshot = await FirebaseFirestore.instance
          .collection('workout_plans')
          .where('status', isEqualTo: 'pending')
          .get();
          
      // Only show pending plans for clients assigned to this coach
      pendingPlans.value = plansSnapshot.docs
          .map((doc) => WorkoutPlan.fromFirestore(doc))
          .where((plan) => currentClientIds.contains(plan.userId))
          .toList();
          
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch coach data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  UserModel? getClient(String userId) {
    try {
      return allUsers.firstWhere((c) => c.uid == userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> approvePlan(String planId, String comments) async {
    try {
      await FirebaseFirestore.instance.collection('workout_plans').doc(planId).update({
        'status': 'approved',
        'coachComments': comments,
      });
      Get.snackbar('Success', 'Plan approved successfully');
      fetchData(); // Refresh list
      Get.back(); // Go back to previous screen
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve plan: $e');
    }
  }

  Future<void> rejectPlan(String planId, String comments) async {
    try {
      await FirebaseFirestore.instance.collection('workout_plans').doc(planId).update({
        'status': 'rejected',
        'coachComments': comments,
      });
      Get.snackbar('Success', 'Plan rejected successfully');
      fetchData(); // Refresh list
      Get.back(); // Go back to previous screen
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject plan: $e');
    }
  }
}
