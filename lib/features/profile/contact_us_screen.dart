import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load user data when screen initializes
    _loadUserData();

    // Add a listener to reset scroll position when inputs are cleared
    _messageController.addListener(_handleMessageChange);
  }

  void _handleMessageChange() {
    // When the message is cleared, we want to ensure the form is visible
    if (_messageController.text.isEmpty) {
      // This is handled in the submit function now, so we don't need to duplicate it here
      // Just keeping the listener for future enhancements
    }
  }

  // Load current user data
  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Set email from Firebase Auth
      if (currentUser.email != null && currentUser.email!.isNotEmpty) {
        _emailController.text = currentUser.email!;
      }

      // Set display name if available
      if (currentUser.displayName != null &&
          currentUser.displayName!.isNotEmpty) {
        _nameController.text = currentUser.displayName!;
      } else {
        // If display name is not available, try to fetch user data from Firestore
        try {
          final userDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .get();

          if (userDoc.exists) {
            final userData = userDoc.data();
            if (userData != null && userData['fullName'] != null) {
              setState(() {
                _nameController.text = userData['fullName'];
              });
            }
          }
        } catch (e) {
          // Silently handle error - we'll just let the user enter their name manually
          debugPrint('Error fetching user data: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    // Remove listener before disposing
    _messageController.removeListener(_handleMessageChange);

    // Dispose controllers
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Validate email using regex
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Submit form to Firebase
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current timestamp
      final timestamp = Timestamp.now();

      // Get current user ID if logged in
      final String? userId = FirebaseAuth.instance.currentUser?.uid;

      // Prepare data to save
      final contactData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
        'timestamp': timestamp,
        'status': 'new', // Can be used to track if message was handled
        'userId': userId, // Store user ID if available
      };

      // Save to Firestore
      await FirebaseFirestore.instance.collection('contactUs').add(contactData);

      // Show success message
      if (mounted) {
        _showSuccessMessage();

        // Only clear message field (keep name and email since they were auto-filled)
        _messageController.clear();
        _formKey.currentState!.reset();

        // Re-populate name and email fields after form reset
        _loadUserData();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Show success message with animation
  void _showSuccessMessage() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryBlue,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thank You!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your message has been sent successfully. We will get back to you soon!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
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
                      Icon(Icons.mail_outline, color: Colors.white, size: 50),
                      SizedBox(height: 10),
                      Text(
                        "Contact Us",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "We'd love to hear from you!",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Contact Information
                const SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: media.width * 0.08),
                  child: Column(
                    children: [
                      _buildContactInfoItem(
                        icon: Icons.phone_outlined,
                        title: "Phone",
                        subtitle: "+1 (555) 123-4567",
                        color: AppColors.secondaryPurple,
                      ),
                      const SizedBox(height: 16),
                      _buildContactInfoItem(
                        icon: Icons.email_outlined,
                        title: "Email",
                        subtitle: "support@yourcompany.com",
                        color: AppColors.secondaryPink,
                      ),
                      const SizedBox(height: 16),
                      _buildContactInfoItem(
                        icon: Icons.location_on_outlined,
                        title: "Address",
                        subtitle:
                            "123 Business Avenue, Suite 456, New York, NY 10001",
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),

                // Form
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: media.width * 0.08,
                    vertical: 32,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            "Send us a message",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _nameController,
                            hint: "Your Name",
                            icon: Icons.person_outline,
                            readOnly: _nameController.text.isNotEmpty,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildTextField(
                            controller: _emailController,
                            hint: "Email Address",
                            icon: Icons.email_outlined,
                            readOnly: _emailController.text.isNotEmpty,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!_isValidEmail(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildTextField(
                            controller: _messageController,
                            hint: "Message",
                            icon: Icons.message_outlined,
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your message';
                              }
                              if (value.trim().length < 10) {
                                return 'Message is too short';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _isLoading ? null : _submitForm,
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ),
                                      )
                                      : const Text(
                                        "Send Message",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Social icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIconButton(
                      color: AppColors.primaryBlue,
                      icon: FontAwesomeIcons.facebook,
                      onTap: () {
                        // Handle Facebook tap
                        // For example: launchUrl(Uri.parse('https://facebook.com/yourcompany'));
                      },
                    ),
                    const SizedBox(width: 18),
                    _buildSocialIconButton(
                      color: AppColors.secondaryPurple,
                      icon: FontAwesomeIcons.instagram,
                      onTap: () {
                        // Handle Instagram tap
                      },
                    ),
                    const SizedBox(width: 18),
                    _buildSocialIconButton(
                      color: AppColors.secondaryPink,
                      icon: FontAwesomeIcons.twitter,
                      onTap: () {
                        // Handle Twitter tap
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Back button at top left
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        hintText: hint,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
      ),
    );
  }

  Widget _buildSocialIconButton({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildContactInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
