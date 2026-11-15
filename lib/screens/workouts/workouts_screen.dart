import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/workout.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/workout_card.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final Uuid _uuid = const Uuid();
  String _selectedFilter = 'All';

  final List<String> _workoutTypes = [
    'Walking',
    'Running',
    'Cycling',
    'Yoga',
    'Strength Training',
    'Other Activities',
  ];

  void _showAddWorkoutSheet(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);
    final health = Provider.of<HealthProvider>(context, listen: false);

    String selectedType = 'Running';
    final durationController = TextEditingController(text: '30');
    final caloriesController = TextEditingController(text: '240');
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    void updateEstimatedCalories(String type, String durStr) {
      final dur = int.tryParse(durStr) ?? 0;
      final weight = health.profile?.weightKg ?? 68.0;
      final est = Workout.estimateCalories(type, dur, weight);
      caloriesController.text = '$est';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Log New Workout 🏃‍♂️',
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
                  const SizedBox(height: 16),

                  // Select Workout Type
                  const Text(
                    'Workout Type',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _workoutTypes.map((type) {
                      final isSelected = selectedType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: AppTheme.tealContainer,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? AppTheme.primaryTealDark
                              : AppTheme.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setSheetState(() {
                              selectedType = type;
                              updateEstimatedCalories(
                                  type, durationController.text);
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: durationController,
                          label: 'Duration (min)',
                          hint: '30',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.timer_outlined,
                          onChanged: (val) {
                            setSheetState(() {
                              updateEstimatedCalories(selectedType, val);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomTextField(
                          controller: caloriesController,
                          label: 'Calories (kcal)',
                          hint: '240',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.local_fire_department_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date picker
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 60)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderGrey),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 18, color: AppTheme.primaryTeal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted)),
                                Text(
                                  DateFormatter.formatFullDate(selectedDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down,
                              color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: notesController,
                    label: 'Notes (Optional)',
                    hint: 'Felt energetic, good pace',
                    prefixIcon: Icons.note_alt_outlined,
                  ),

                  const SizedBox(height: 24),

                  CustomButton(
                    text: 'Save Workout',
                    onPressed: () {
                      final duration =
                          int.tryParse(durationController.text.trim()) ?? 0;
                      final calories =
                          int.tryParse(caloriesController.text.trim()) ?? 0;

                      if (duration <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a valid duration')),
                        );
                        return;
                      }

                      final newWorkout = Workout(
                        workoutId: _uuid.v4(),
                        userId: auth.user?.uid ?? 'guest',
                        workoutType: selectedType,
                        duration: duration,
                        workoutDate: selectedDate,
                        caloriesBurned: calories,
                        notes: notesController.text.trim(),
                      );

                      workoutProvider.addWorkout(newWorkout);
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '$selectedType workout ($duration min) recorded! 🔥'),
                          backgroundColor: AppTheme.primaryTeal,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final health = Provider.of<HealthProvider>(context);

    final int weeklyTarget = health.workoutGoalMinutes;
    final int weeklyCompleted = workoutProvider.totalMinutesThisWeek;
    final double weeklyProgress =
        weeklyTarget > 0 ? (weeklyCompleted / weeklyTarget).clamp(0.0, 1.0) : 0.0;

    final allWorkouts = workoutProvider.workouts;
    final filteredWorkouts = _selectedFilter == 'All'
        ? allWorkouts
        : allWorkouts
            .where((w) => w.workoutType == _selectedFilter)
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Workouts & Fitness'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28),
            onPressed: () => _showAddWorkoutSheet(context),
            tooltip: 'Add Workout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Goal Summary Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryTealDark, AppTheme.primaryTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Weekly Workout Goal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(weeklyProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$weeklyCompleted',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ $weeklyTarget min',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: weeklyProgress,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weeklyCompleted >= weeklyTarget
                        ? 'Great job! Weekly fitness target reached! 🏆'
                        : '${weeklyTarget - weeklyCompleted} minutes left to reach weekly goal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Workout Categories Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', ..._workoutTypes].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppTheme.tealContainer,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppTheme.primaryTealDark
                            : AppTheme.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Workout History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${filteredWorkouts.length} entries',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (filteredWorkouts.isEmpty)
              EmptyStateView(
                icon: Icons.fitness_center_rounded,
                title: 'No Workouts Found',
                message: _selectedFilter == 'All'
                    ? 'Start tracking your exercises to monitor weekly goals and burned calories.'
                    : 'No workouts recorded under $_selectedFilter.',
                actionLabel: 'Log First Workout',
                onAction: () => _showAddWorkoutSheet(context),
              )
            else
              ...filteredWorkouts.map((w) {
                return WorkoutCard(
                  workout: w,
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: const Text('Delete Workout?'),
                        content: Text(
                            'Are you sure you want to remove this ${w.workoutType} workout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              workoutProvider.deleteWorkout(w.workoutId);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Workout deleted')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentCoral),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWorkoutSheet(context),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Workout'),
      ),
    );
  }
}
