import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/circular_goal_indicator.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/quick_add_button.dart';
import '../reminders/reminders_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showQuickWaterSheet(BuildContext context) {
    final health = Provider.of<HealthProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Record Water Intake 💧',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select an amount to log for today:',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      health.addWater(250);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('+250 ml water logged! 💧'),
                          backgroundColor: AppTheme.primaryTeal,
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_drink_rounded, size: 20),
                    label: const Text('+250 ml'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      health.addWater(500);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('+500 ml water logged! 💧'),
                          backgroundColor: AppTheme.primaryTeal,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryEmerald,
                    ),
                    icon: const Icon(Icons.water_drop_rounded, size: 20),
                    label: const Text('+500 ml'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      health.addWater(150);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.coffee_rounded, size: 18),
                    label: const Text('Cup (+150 ml)'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      health.addWater(750);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.sports_bar_rounded, size: 18),
                    label: const Text('Bottle (+750 ml)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showManualStepDialog(BuildContext context) {
    final health = Provider.of<HealthProvider>(context, listen: false);
    final controller = TextEditingController(text: '${health.steps}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Daily Steps'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your total step count for today:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.directions_walk_rounded),
                labelText: 'Total Steps',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val >= 0) {
                health.updateSteps(val);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Steps updated to $val! 🚶‍♂️'),
                    backgroundColor: AppTheme.secondaryEmerald,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final health = Provider.of<HealthProvider>(context);
    final workout = Provider.of<WorkoutProvider>(context);

    final userName = auth.user?.displayName.split(' ').first ?? 'Friend';
    final todayFormatted = DateFormatter.formatFullDate(DateTime.now());

    final int stepGoal = health.stepGoal;
    final int waterGoal = health.waterGoal;
    final double sleepGoal = health.sleepGoal;

    final int currentSteps = health.steps;
    final int currentWater = health.waterIntake;
    final double currentSleep = health.sleepDuration;
    final int currentWorkoutMins = workout.totalMinutesToday;
    final int caloriesToday = workout.caloriesBurnedToday + (currentSteps * 0.04).round();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (auth.user != null) {
              await Future.wait([
                health.loadUserData(auth.user!.uid),
                workout.loadWorkouts(auth.user!.uid),
              ]);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $userName 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 13, color: AppTheme.textMuted),
                            const SizedBox(width: 5),
                            Text(
                              todayFormatted,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.borderGrey),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppTheme.primaryTeal,
                          size: 22,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RemindersScreen(),
                          ),
                        );
                      },
                      tooltip: 'Reminders & Notifications',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Overall Daily Goal Progress Banner
                CircularGoalIndicator(
                  percentage: health.overallGoalPercentage,
                  title: 'Daily Goal Score',
                  subtitle: health.overallGoalPercentage >= 100
                      ? 'Incredible work! All daily goals completed!'
                      : 'Keep going! You are making steady progress.',
                ),

                const SizedBox(height: 22),

                // Quick Action Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      QuickAddButton(
                        label: '+ Water',
                        icon: Icons.local_drink_rounded,
                        color: AppTheme.accentSky,
                        onTap: () => _showQuickWaterSheet(context),
                      ),
                      const SizedBox(width: 10),
                      QuickAddButton(
                        label: 'Log Steps',
                        icon: Icons.directions_walk_rounded,
                        color: AppTheme.secondaryEmerald,
                        onTap: () => _showManualStepDialog(context),
                      ),
                      const SizedBox(width: 10),
                      QuickAddButton(
                        label: 'Reminders',
                        icon: Icons.alarm_rounded,
                        color: AppTheme.accentPurple,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RemindersScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Today's Overview",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                // 2x2 Metric Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.88,
                  children: [
                    // Steps Card
                    MetricCard(
                      title: 'Daily Steps',
                      value: '$currentSteps',
                      unit: '/ $stepGoal',
                      subtitle: currentSteps >= stepGoal
                          ? 'Goal reached! 🎉'
                          : '${stepGoal - currentSteps} steps left',
                      progress: health.stepProgress,
                      icon: Icons.directions_walk_rounded,
                      iconColor: AppTheme.secondaryEmerald,
                      onTap: () => _showManualStepDialog(context),
                    ),

                    // Water Card
                    MetricCard(
                      title: 'Water Intake',
                      value: '$currentWater',
                      unit: 'ml',
                      subtitle: currentWater >= waterGoal
                          ? 'Hydrated! 💧'
                          : '${waterGoal - currentWater} ml left',
                      progress: health.waterProgress,
                      icon: Icons.water_drop_rounded,
                      iconColor: AppTheme.accentSky,
                      onTap: () => _showQuickWaterSheet(context),
                    ),

                    // Sleep Card
                    MetricCard(
                      title: 'Sleep Duration',
                      value: currentSleep > 0
                          ? currentSleep.toStringAsFixed(1)
                          : '0',
                      unit: '/ ${sleepGoal.toInt()} hrs',
                      subtitle: health.todayRecord?.sleepQuality != null
                          ? 'Quality: ${health.todayRecord!.sleepQuality}'
                          : 'Log last night sleep',
                      progress: health.sleepProgress,
                      icon: Icons.nightlight_round,
                      iconColor: AppTheme.accentPurple,
                      onTap: () {
                        // Switch to Activity Tab
                        DefaultTabController.maybeOf(context);
                      },
                    ),

                    // Workout Duration Card
                    MetricCard(
                      title: 'Workout Today',
                      value: '$currentWorkoutMins',
                      unit: 'min',
                      subtitle: '$caloriesToday kcal burned',
                      progress: (currentWorkoutMins / 45.0).clamp(0.0, 1.0),
                      icon: Icons.fitness_center_rounded,
                      iconColor: AppTheme.accentCoral,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Activities Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today’s Activities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${health.todayRecord?.waterLogs.length ?? 0} drinks • ${workout.workouts.length} workouts',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Summary of today's events
                if (health.todayRecord != null &&
                    health.todayRecord!.waterLogs.isNotEmpty)
                  ...health.todayRecord!.waterLogs.take(3).map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: AppTheme.cardDecoration(),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentSky.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.water_drop_rounded,
                                color: AppTheme.accentSky, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '+${item.amountMl} ml Water logged',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  DateFormatter.formatTime(item.timestamp),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                size: 18, color: AppTheme.textMuted),
                            onPressed: () => health.removeWaterLog(item.id),
                          ),
                        ],
                      ),
                    );
                  })
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration(),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppTheme.primaryTeal, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No activities logged yet today. Use the quick buttons above to start tracking!',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
