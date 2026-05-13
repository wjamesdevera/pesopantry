import 'package:flutter/material.dart';
import 'package:peso_pantry/config/app_theme.dart';
import 'package:peso_pantry/services/auth_service.dart';
import 'package:peso_pantry/services/firebase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _budgetController = TextEditingController();
  double _currentBudget = 0.0;
  bool _isEditing = false;
  bool _isLoading = false;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = AuthService.getCurrentUserId();
      if (userId != null) {
        final user = await FirebaseService.getUserById(userId);
        setState(() {
          _currentBudget = user.budget;
          _userEmail = user.email;
          _budgetController.text = _currentBudget.toStringAsFixed(2);
        });
      }
    } catch (e) {
      // Handle error silently or show toast
      _showError('Error loading profile: $e');
    }
  }

  Future<void> _updateBudget() async {
    final newBudget = double.tryParse(_budgetController.text) ?? _currentBudget;

    if (newBudget < 0) {
      _showError('Budget must be positive');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = AuthService.getCurrentUserId();
      if (userId != null) {
        await FirebaseService.updateUserBudget(userId, newBudget);
        setState(() {
          _currentBudget = newBudget;
          _isEditing = false;
          _isLoading = false;
        });
        _showSuccess('Budget updated successfully');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error: $e');
    }
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      _showError('Logout failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontSize: 28,
          ),
        ),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Full-width banner header
          Image.asset(
            'peso_pantry_banner.png',
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // User email overlay
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Text(
              _userEmail,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const SizedBox(height: 24),
                   // Budget section
                   Text(
                     'Budget Settings',
                     style: Theme.of(context).textTheme.headlineSmall,
                   ),
                   const SizedBox(height: 16),
                   Card(
                     elevation: 4,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: Padding(
                       padding: const EdgeInsets.all(20),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text(
                                 'Monthly Budget',
                                 style: Theme.of(context).textTheme.bodyMedium,
                               ),
                               Container(
                                 padding: const EdgeInsets.symmetric(
                                   horizontal: 16,
                                   vertical: 8,
                                 ),
                                 decoration: BoxDecoration(
                                   color: AppTheme.primary.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(8),
                                 ),
                          child: Text(
                            '₱${_currentBudget.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isEditing) ...[
                      TextField(
                        controller: _budgetController,
                        decoration: const InputDecoration(
                          hintText: 'Enter new budget',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _isEditing = false),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _updateBudget,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Save'),
                          ),
                        ],
                      ),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _budgetController.text =
                                _currentBudget.toStringAsFixed(2);
                            setState(() => _isEditing = true);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Budget'),
                        ),
                      ),
                   ],
                 ),
               ),
             ),
                   const SizedBox(height: 32),
                   // Saved recipes section
                   Text(
                     'Saved Recipes',
                     style: Theme.of(context).textTheme.headlineSmall,
                   ),
                   const SizedBox(height: 16),
                   Card(
                     elevation: 4,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: Padding(
                       padding: const EdgeInsets.all(20),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 'Your Saved Recipes',
                                 style: Theme.of(context).textTheme.bodyMedium,
                               ),
                               const SizedBox(height: 4),
                               Text(
                                 '0 saved',
                                 style: Theme.of(context).textTheme.bodySmall
                                     ?.copyWith(color: AppTheme.textSecondary),
                               ),
                             ],
                           ),
                           ElevatedButton.icon(
                             onPressed: () {
                               Navigator.of(context).pushReplacementNamed('/saved-recipe');
                             },
                             icon: const Icon(Icons.bookmark),
                             label: const Text('View'),
                           ),
                         ],
                       ),
                     ),
                   ),
                   const SizedBox(height: 32),
                   // Account section
                   Text(
                     'Account',
                     style: Theme.of(context).textTheme.headlineSmall,
                   ),
                   const SizedBox(height: 16),
                   OutlinedButton.icon(
                     onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Change password feature')),
                       );
                     },
                     icon: const Icon(Icons.lock),
                     label: const Text('Change Password'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }




