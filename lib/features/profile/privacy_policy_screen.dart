import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<String> _loadPolicy() async {
    return await rootBundle.loadString('assets/markdown/privacy_policy.md');
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Gradient Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: media.height * 0.06),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.blueGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.white, size: 50),
                    SizedBox(height: 10),
                    Text(
                      "Privacy Policy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Your data, our responsibility.",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              // Policy Content Card
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: media.width * 0.08,
                    vertical: 24,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FutureBuilder<String>(
                      future: _loadPolicy(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return MarkdownWidget(
                          data: snapshot.data!,
                          config: MarkdownConfig(
                            configs: [
                              const PConfig(
                                textStyle: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 15,
                                ),
                              ),
                              const H1Config(
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const H2Config(
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const H3Config(
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Back button (top left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryBlue,
                ),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
