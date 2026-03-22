import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_pages.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_controller.dart';
import 'coach_controller.dart';
import 'package:intl/intl.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CoachController _controller = Get.put(CoachController());
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
            onPressed: () => _controller.fetchData(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _authController.logout(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Clients'),
            Tab(icon: Icon(Icons.assignment), text: 'Pending Plans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClientsTab(),
          _buildPendingPlansTab(),
        ],
      ),
    );
  }

  Widget _buildClientsTab() {
    return Obx(() {
      if (_controller.isLoading.value && _controller.clients.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (_controller.clients.isEmpty) {
        return const Center(child: Text("No clients found."));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.clients.length,
        itemBuilder: (context, index) {
          final client = _controller.clients[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                child: const Icon(Icons.person, color: AppColors.primaryBlue),
              ),
              title: Text(client.name.isNotEmpty ? client.name : 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(client.email),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to client details
                Get.toNamed(Routes.clientDetails, arguments: client);
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildPendingPlansTab() {
    return Obx(() {
      if (_controller.isLoading.value && _controller.pendingPlans.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (_controller.pendingPlans.isEmpty) {
        return const Center(child: Text("No pending plans to review."));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.pendingPlans.length,
        itemBuilder: (context, index) {
          final plan = _controller.pendingPlans[index];
          final dateStr = DateFormat('MMM d, yyyy').format(plan.date);
          final client = _controller.getClient(plan.userId);
          final clientName = client?.name ?? 'Unknown Customer';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top, color: Colors.orange),
              ),
              title: Text("$clientName's Plan", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${plan.name}\nDate: $dateStr • ${plan.workouts.length} workouts"),
              isThreeLine: true,
              trailing: ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.planApproval, arguments: plan);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Review'),
              ),
            ),
          );
        },
      );
    });
  }
}
