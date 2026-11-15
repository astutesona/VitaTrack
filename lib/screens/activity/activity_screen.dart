import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/health_provider.dart';
import '../../services/step_counter_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/custom_button.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sleep time pickers state
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  String _selectedQuality = 'Deep';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Calculate sleep duration automatically
  double _calculateSleepDuration(TimeOfDay start, TimeOfDay end) {
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60; // Next day
    }

    final diffMinutes = endMinutes - startMinutes;
    return diffMinutes / 60.0;
  }

  void _showManualStepDialog(BuildContext context, HealthProvider health) {
    final controller = TextEditingController(text: '${health.steps}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Manual Step Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your step count manually:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.directions_walk_rounded),
                labelText: 'Steps',
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
              }
            },
            child: const Text('Save Steps'),
          ),
        ],
      ),
    );
  }

  void _showCustomWaterDialog(BuildContext context, HealthProvider health) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Custom Water'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter quantity consumed in milliliters (ml):',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.water_drop_outlined),
                labelText: 'Amount (ml)',
                suffixText: 'ml',
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
              if (val != null && val > 0) {
                health.addWater(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final health = Provider.of<HealthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Health Tracking'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryTeal,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryTeal,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.directions_walk_rounded), text: 'Steps'),
            Tab(icon: Icon(Icons.water_drop_rounded), text: 'Water'),
            Tab(icon: Icon(Icons.bedtime_rounded), text: 'Sleep'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStepsTab(health),
          _buildWaterTab(health),
          _buildSleepTab(health),
        ],
      ),
    );
  }

  // ================= 1. STEPS TRACKING TAB =================
  Widget _buildStepsTab(HealthProvider health) {
    final int currentSteps = health.steps;
    final int stepGoal = health.stepGoal;
    final double progress = health.stepProgress;
    final double distanceKm = currentSteps * 0.00078; // Approx 0.78m per step
    final int calories = (currentSteps * 0.04).round();

    final isSensorActive = health.sensorStatus == SensorStatus.listening;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Hardware Sensor Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSensorActive
                  ? AppTheme.emeraldLight
                  : AppTheme.tealContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSensorActive
                    ? AppTheme.secondaryEmerald.withOpacity(0.4)
                    : AppTheme.primaryTeal.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSensorActive
                      ? Icons.sensors_rounded
                      : Icons.edit_note_rounded,
                  color: isSensorActive
                      ? AppTheme.onEmerald
                      : AppTheme.onTealContainer,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isSensorActive
                        ? 'Hardware Pedometer Active: Live step counting enabled'
                        : 'Manual Step Mode: Enter or update your daily steps directly',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSensorActive
                          ? AppTheme.onEmerald
                          : AppTheme.onTealContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Big Circular Step Progress Indicator
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.cardDecoration(),
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 16,
                          strokeCap: StrokeCap.round,
                          backgroundColor: AppTheme.borderGrey.withOpacity(0.5),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.secondaryEmerald),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_walk_rounded,
                              size: 32, color: AppTheme.secondaryEmerald),
                          const SizedBox(height: 6),
                          Text(
                            '$currentSteps',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            'Goal: $stepGoal steps',
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
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          distanceKm.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Distance (km)',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    Container(height: 30, width: 1, color: AppTheme.borderGrey),
                    Column(
                      children: [
                        Text(
                          '$calories',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Calories (kcal)',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    Container(height: 30, width: 1, color: AppTheme.borderGrey),
                    Column(
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondaryEmerald,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Completed',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          CustomButton(
            text: 'Log Steps Manually',
            icon: Icons.edit_note_rounded,
            backgroundColor: AppTheme.secondaryEmerald,
            onPressed: () => _showManualStepDialog(context, health),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              health.updateSteps(currentSteps + 500);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('+500 steps added!'),
                  backgroundColor: AppTheme.secondaryEmerald,
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Quick Add +500 Steps'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 2. WATER TRACKING TAB =================
  Widget _buildWaterTab(HealthProvider health) {
    final int current = health.waterIntake;
    final int goal = health.waterGoal;
    final double progress = health.waterProgress;
    final int remaining = (goal - current).clamp(0, 99999);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Water Progress Card with Bottle Visualization
          Container(
            padding: const EdgeInsets.all(22),
            decoration: AppTheme.cardDecoration(),
            child: Row(
              children: [
                // Bottle visual
                Container(
                  width: 70,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.accentSky, width: 3),
                    color: AppTheme.accentSky.withOpacity(0.05),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          width: double.infinity,
                          height: 140 * progress,
                          color: AppTheme.accentSky.withOpacity(0.75),
                        ),
                        Center(
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: progress > 0.45
                                  ? Colors.white
                                  : AppTheme.accentSky,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hydration Goal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$current',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentSky,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ $goal ml',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        remaining > 0
                            ? '$remaining ml remaining today'
                            : 'Daily hydration goal reached! 💧🎉',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: remaining > 0
                              ? AppTheme.textSecondary
                              : AppTheme.secondaryEmerald,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Add Buttons
          const Text(
            'Quick Add Water',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => health.addWater(250),
                  icon: const Icon(Icons.local_drink_rounded, size: 18),
                  label: const Text('+250 ml'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentSky,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => health.addWater(500),
                  icon: const Icon(Icons.water_drop_rounded, size: 18),
                  label: const Text('+500 ml'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => health.addWater(100),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+100 ml'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCustomWaterDialog(context, health),
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text('Custom ml'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Water Consumption History
          const Text(
            "Today's Drink Logs",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (health.todayRecord != null &&
              health.todayRecord!.waterLogs.isNotEmpty)
            ...health.todayRecord!.waterLogs.map((log) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          color: AppTheme.accentSky, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '+${log.amountMl} ml',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            DateFormatter.formatTime(log.timestamp),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppTheme.textMuted),
                      onPressed: () => health.removeWaterLog(log.id),
                      tooltip: 'Remove entry',
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
              child: const Text(
                'No water logs recorded yet today. Tap +250 ml to begin.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  // ================= 3. SLEEP TRACKING TAB =================
  Widget _buildSleepTab(HealthProvider health) {
    final double sleepHours = health.sleepDuration;
    final double goal = health.sleepGoal;
    final calculatedDuration =
        _calculateSleepDuration(_sleepTime, _wakeTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Logged Sleep Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration(),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.nightlight_round,
                      size: 34, color: AppTheme.accentPurple),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recorded Sleep Today',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sleepHours > 0
                            ? '${sleepHours.toStringAsFixed(1)} hours'
                            : 'Not recorded yet',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target: ${goal.toInt()} hours per night',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sleep Entry Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Log Last Night Sleep',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Set your bedtime and wake-up time. Duration is calculated automatically.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 20),

                // Sleep Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _sleepTime,
                          );
                          if (picked != null) {
                            setState(() => _sleepTime = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLightGrey,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderGrey),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Bedtime 🌙',
                                  style: TextStyle(
                                      fontSize: 12, color: AppTheme.textSecondary)),
                              const SizedBox(height: 6),
                              Text(
                                _sleepTime.format(context),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _wakeTime,
                          );
                          if (picked != null) {
                            setState(() => _wakeTime = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLightGrey,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderGrey),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Wake-up ☀️',
                                  style: TextStyle(
                                      fontSize: 12, color: AppTheme.textSecondary)),
                              const SizedBox(height: 6),
                              Text(
                                _wakeTime.format(context),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Calculated Duration Card
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Calculated Duration:',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${calculatedDuration.toStringAsFixed(1)} hrs',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Sleep Quality selector
                const Text(
                  'Sleep Quality:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Deep', 'Light', 'Restless'].map((quality) {
                    final isSelected = _selectedQuality == quality;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(quality),
                        selected: isSelected,
                        selectedColor: AppTheme.accentPurple.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.accentPurple
                              : AppTheme.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedQuality = quality);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                CustomButton(
                  text: 'Save Sleep Record',
                  icon: Icons.check_circle_outline_rounded,
                  backgroundColor: AppTheme.accentPurple,
                  onPressed: () {
                    health.logSleep(
                      startTime: _sleepTime.format(context),
                      endTime: _wakeTime.format(context),
                      durationHours: calculatedDuration,
                      quality: _selectedQuality,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Sleep duration (${calculatedDuration.toStringAsFixed(1)} hrs) saved! 🌙'),
                        backgroundColor: AppTheme.accentPurple,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Academic note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLightGrey,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: AppTheme.textMuted),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sleep hours are logged manually via user input and verified using actual arithmetic time calculations.',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
