import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../auth/login_screen.dart';
import '../reminders/reminders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditGoalsDialog(BuildContext context, HealthProvider health) {
    final stepCtrl = TextEditingController(text: '${health.stepGoal}');
    final waterCtrl = TextEditingController(text: '${health.waterGoal}');
    final sleepCtrl =
        TextEditingController(text: '${health.sleepGoal.toInt()}');
    final workoutCtrl =
        TextEditingController(text: '${health.workoutGoalMinutes}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Daily Targets'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: stepCtrl,
                label: 'Daily Steps Goal',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.directions_walk_rounded,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: waterCtrl,
                label: 'Daily Water Goal (ml)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.water_drop_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: sleepCtrl,
                label: 'Daily Sleep Goal (hours)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.nightlight_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: workoutCtrl,
                label: 'Weekly Workout Goal (min)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.fitness_center_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final steps = int.tryParse(stepCtrl.text.trim()) ?? 8000;
              final water = int.tryParse(waterCtrl.text.trim()) ?? 2500;
              final sleep = double.tryParse(sleepCtrl.text.trim()) ?? 8.0;
              final workout = int.tryParse(workoutCtrl.text.trim()) ?? 150;

              health.updateGoals(
                stepGoal: steps,
                waterGoalMl: water,
                sleepGoalHours: sleep,
                workoutGoalMinutes: workout,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Daily targets updated successfully! 🎯'),
                  backgroundColor: AppTheme.primaryTeal,
                ),
              );
            },
            child: const Text('Save Targets'),
          ),
        ],
      ),
    );
  }

  void _showEditPhysicalStatsDialog(
      BuildContext context, HealthProvider health) {
    final heightCtrl =
        TextEditingController(text: '${health.profile?.heightCm ?? 170.0}');
    final weightCtrl =
        TextEditingController(text: '${health.profile?.weightKg ?? 68.0}');
    final nameCtrl =
        TextEditingController(text: health.profile?.name ?? 'User');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Body Stats & Name'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameCtrl,
                label: 'Display Name',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: heightCtrl,
                label: 'Height (cm)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.height_rounded,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: weightCtrl,
                label: 'Weight (kg)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.monitor_weight_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final h = double.tryParse(heightCtrl.text.trim()) ?? 170.0;
              final w = double.tryParse(weightCtrl.text.trim()) ?? 68.0;

              health.updatePhysicalStats(
                heightCm: h,
                weightKg: w,
                name: nameCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Body stats & BMI updated!'),
                  backgroundColor: AppTheme.secondaryEmerald,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.school_rounded, color: AppTheme.primaryTeal),
            SizedBox(width: 10),
            Text('About VitaTrack'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'VitaTrack – Personal Health & Wellness Tracker',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Course: Advanced Mobile Application Development (MCA)\n'
                'Subject Code: AMAD MCA Level Project\n'
                'Author: Sonali Kumari\n\n'
                'Implemented Concepts:\n'
                '• Navigation: Named Routes & Material 3 Bottom Navigation\n'
                '• Authentication: Firebase Auth & Session Management\n'
                '• Cloud Database: Google Cloud Firestore Collections\n'
                '• Local Persistence: SharedPreferences Caching\n'
                '• Device Sensors: Pedometer Hardware Step Sensor & Fallback\n'
                '• Notifications: Flutter Local Notifications & Alarm Scheduling\n'
                '• Visualizations: fl_chart Interactive Multi-metric Charts\n'
                '• UI/UX: Material 3 Design System & Responsive Widgets',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary, height: 1.45),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to sign out of your VitaTrack account?',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCoral,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final health = Provider.of<HealthProvider>(context);

    final profile = health.profile;
    final userName = profile?.name ?? auth.user?.displayName ?? 'Sonali Kumari';
    final userEmail = profile?.email.isNotEmpty == true
        ? profile!.email
        : auth.user?.email ?? 'sonali@gmail.com';

    final double bmi = profile?.bmi ?? 23.5;
    final String bmiCat = profile?.bmiCategory ?? 'Normal weight';

    Color bmiColor = AppTheme.secondaryEmerald;
    if (bmiCat == 'Underweight') bmiColor = AppTheme.accentSky;
    if (bmiCat == 'Overweight') bmiColor = AppTheme.accentAmber;
    if (bmiCat == 'Obese') bmiColor = AppTheme.accentCoral;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: AppTheme.cardDecoration(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.tealContainer,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'V',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryTealDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Active Member',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onEmerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BMI & Physical Health Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Body Mass Index (BMI)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 20, color: AppTheme.primaryTeal),
                        onPressed: () =>
                            _showEditPhysicalStatsDialog(context, health),
                        tooltip: 'Edit Height & Weight',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bmiColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              bmi.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: bmiColor,
                              ),
                            ),
                            Text(
                              bmiCat,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: bmiColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Height: ${profile?.heightCm.toInt() ?? 170} cm',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Weight: ${profile?.weightKg.toInt() ?? 68} kg',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Healthy BMI range: 18.5 – 24.9',
                              style: TextStyle(
                                  fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings & Targets Menu
            Container(
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.track_changes_rounded,
                        color: AppTheme.primaryTeal),
                    title: const Text('Daily Health Targets',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${health.stepGoal} steps • ${health.waterGoal} ml • ${health.sleepGoal.toInt()} hrs',
                        style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textMuted),
                    onTap: () => _showEditGoalsDialog(context, health),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined,
                        color: AppTheme.accentSky),
                    title: const Text('Notification Reminders',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Configure water, walk & sleep alerts',
                        style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textMuted),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RemindersScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.school_outlined,
                        color: AppTheme.accentPurple),
                    title: const Text('About Academic Project',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('MCA AMAD Specifications & Concepts',
                        style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textMuted),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            CustomButton(
              text: 'Sign Out',
              icon: Icons.logout_rounded,
              backgroundColor: AppTheme.accentCoral,
              onPressed: () => _handleLogout(context),
            ),

            const SizedBox(height: 20),

            const Text(
              'VitaTrack v1.0.0 (AMAD MCA Project)',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
