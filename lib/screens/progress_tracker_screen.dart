import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/health_viewmodel.dart';
import '../models/health_data_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class ProgressTrackerScreen extends StatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
  State<ProgressTrackerScreen> createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  double _waterIntake = 1.2;
  double _waterGoal = 2.0;
  double _caloriesConsumed = 1200;
  double _caloriesGoal = 2000;
  bool _showWeeklyView = false;
  int _selectedTabIndex = 0;
  
  final List<String> _tabTitles = ['Day', 'Week', 'Month'];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(
            color: Color(0xFF0B4C37),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              _showGoalSettingDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B4C37),
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeRangeSelector(),
            const SizedBox(height: 24),
            _buildWeightSection(),
            const SizedBox(height: 24),
            _buildWaterIntakeSection(context),
            const SizedBox(height: 24),
            _buildCaloriesSection(context),
            const SizedBox(height: 24),
            _buildExerciseProgressSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProgressDialog(context);
        },
        backgroundColor: const Color(0xFF0B4C37),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildTimeRangeSelector() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(
          _tabTitles.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedTabIndex == index 
                      ? const Color(0xFF0B4C37) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _tabTitles[index],
                    style: TextStyle(
                      color: _selectedTabIndex == index 
                          ? Colors.white
                          : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightSection() {
    return Consumer<HealthViewModel>(
      builder: (context, healthViewModel, child) {
        final weightData = healthViewModel.weightData;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Weight',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B4C37),
                      ),
                    ),
                    Text(
                      '${healthViewModel.currentWeight} kg',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: healthViewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : weightData.isEmpty
                          ? const Center(child: Text('No weight data available'))
                          : _buildWeightChart(weightData),
                ),
                if (healthViewModel.error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    healthViewModel.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightChart(List<HealthDataPoint> data) {
    // Filter data based on selected tab
    final DateTime now = DateTime.now();
    final DateTime filterDate = _selectedTabIndex == 0
        ? now.subtract(const Duration(days: 1))
        : _selectedTabIndex == 1
            ? now.subtract(const Duration(days: 7))
            : now.subtract(const Duration(days: 30));
    
    final filteredData = data
        .where((point) => point.date.isAfter(filterDate))
        .toList();
    
    if (filteredData.isEmpty) {
      return const Center(child: Text('No data for selected period'));
    }
    
    // Get min and max values for the Y-axis
    double minY = filteredData
        .map((e) => e.value)
        .reduce((a, b) => a < b ? a : b) - 1;
    double maxY = filteredData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b) + 1;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < filteredData.length) {
                  final date = filteredData[value.toInt()].date;
                  return Text(
                    DateFormat('dd/MM').format(date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            left: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        minX: 0,
        maxX: filteredData.length - 1.0,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              filteredData.length,
              (index) => FlSpot(index.toDouble(), filteredData[index].value),
            ).reversed.toList(),
            isCurved: true,
            barWidth: 3,
            color: const Color(0xFF0B4C37),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: const Color(0xFF0B4C37),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF0B4C37).withOpacity(0.2),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildWaterIntakeSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Water Intake',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B4C37),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          if (_waterIntake > 0.1) {
                            _waterIntake = double.parse((_waterIntake - 0.1).toStringAsFixed(1));
                          }
                        });
                      },
                      color: Theme.of(context).primaryColor,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          _waterIntake = double.parse((_waterIntake + 0.1).toStringAsFixed(1));
                        });
                      },
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 60,
                      height: 80,
                      child: CustomPaint(
                        painter: _WaterLevelPainter(
                          percentage: (_waterIntake / _waterGoal) * _progressAnimation.value,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_waterIntake L / $_waterGoal L',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B4C37),
                        ),
                      ),
                      Text(
                        'Daily Goal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (_waterIntake / _waterGoal) * _progressAnimation.value,
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${((_waterIntake / _waterGoal) * 100).toInt()}% completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickAddButton('+ 0.25L', () {
                  setState(() {
                    _waterIntake = double.parse((_waterIntake + 0.25).toStringAsFixed(2));
                  });
                }),
                _buildQuickAddButton('+ 0.5L', () {
                  setState(() {
                    _waterIntake = double.parse((_waterIntake + 0.5).toStringAsFixed(1));
                  });
                }),
                _buildQuickAddButton('+ 1L', () {
                  setState(() {
                    _waterIntake = double.parse((_waterIntake + 1.0).toStringAsFixed(1));
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Calories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B4C37),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          if (_caloriesConsumed > 100) {
                            _caloriesConsumed -= 100;
                          }
                        });
                      },
                      color: Theme.of(context).primaryColor,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          _caloriesConsumed += 100;
                        });
                      },
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      Center(
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: (_caloriesConsumed / _caloriesGoal) * _progressAnimation.value,
                                backgroundColor: Colors.grey[200],
                                strokeWidth: 8,
                                color: Colors.orange,
                              ),
                            );
                          },
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.local_fire_department_outlined,
                          color: Colors.orange,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_caloriesConsumed.toInt()} / ${_caloriesGoal.toInt()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B4C37),
                        ),
                      ),
                      Text(
                        'Daily Goal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${((_caloriesConsumed / _caloriesGoal) * 100).toInt()}% consumed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickAddButton('+ 100 cal', () {
                  setState(() {
                    _caloriesConsumed += 100;
                  });
                }),
                _buildQuickAddButton('+ 250 cal', () {
                  setState(() {
                    _caloriesConsumed += 250;
                  });
                }),
                _buildQuickAddButton('+ 500 cal', () {
                  setState(() {
                    _caloriesConsumed += 500;
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseProgressSection(BuildContext context) {
    // Sample exercise progress data
    final exercises = {
      'Mon': 45,
      'Tue': 30,
      'Wed': 60,
      'Thu': 0,
      'Fri': 20,
      'Sat': 40,
      'Sun': 0,
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.fitness_center, color: Color(0xFF0B4C37)),
                SizedBox(width: 8),
                Text(
                  'Exercise Minutes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B4C37),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceBetween,
                      maxY: 60,
                      barGroups: exercises.entries.map((entry) {
                        return BarChartGroupData(
                          x: exercises.keys.toList().indexOf(entry.key),
                          barRods: [
                            BarChartRodData(
                              toY: entry.value * _progressAnimation.value,
                              width: 15,
                              color: entry.value > 0 
                                  ? const Color(0xFF0B4C37)
                                  : Colors.grey[300],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                exercises.keys.elementAt(value.toInt()),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[300],
                            strokeWidth: 1,
                            dashArray: [5],
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Weekly target: 180 mins'),
                Text(
                  'Total: ${exercises.values.reduce((a, b) => a + b)} mins',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }

  void _showGoalSettingDialog(BuildContext context) {
    double tempWaterGoal = _waterGoal;
    double tempCaloriesGoal = _caloriesGoal;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Your Daily Goals'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Water Intake Goal (L)'),
              Slider(
                value: tempWaterGoal,
                min: 0.5,
                max: 5,
                divisions: 9,
                label: tempWaterGoal.toString(),
                onChanged: (value) {
                  tempWaterGoal = double.parse(value.toStringAsFixed(1));
                  (context as Element).markNeedsBuild();
                },
              ),
              Text('${tempWaterGoal.toStringAsFixed(1)} L'),
              const SizedBox(height: 16),
              const Text('Calorie Goal'),
              Slider(
                value: tempCaloriesGoal,
                min: 500,
                max: 4000,
                divisions: 35,
                label: tempCaloriesGoal.round().toString(),
                onChanged: (value) {
                  tempCaloriesGoal = value.roundToDouble();
                  (context as Element).markNeedsBuild();
                },
              ),
              Text('${tempCaloriesGoal.round()} calories'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _waterGoal = tempWaterGoal;
                  _caloriesGoal = tempCaloriesGoal;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goals updated successfully')),
                );
              },
              child: const Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B4C37),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddProgressDialog(BuildContext context) {
    final types = ['Weight', 'Water', 'Calories', 'Exercise'];
    String selectedType = types[0];
    double value = 0;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double minValue = 0;
            double maxValue = 100;
            int divisions = 100;
            String unit = '';
            
            switch (selectedType) {
              case 'Weight':
                minValue = 30;
                maxValue = 150;
                divisions = 120;
                unit = 'kg';
                if (value == 0) value = 70;
                break;
              case 'Water':
                minValue = 0;
                maxValue = 5;
                divisions = 50;
                unit = 'L';
                if (value == 0) value = 1;
                break;
              case 'Calories':
                minValue = 0;
                maxValue = 3000;
                divisions = 60;
                unit = 'cal';
                if (value == 0) value = 500;
                break;
              case 'Exercise':
                minValue = 0;
                maxValue = 180;
                divisions = 36;
                unit = 'min';
                if (value == 0) value = 30;
                break;
            }
            
            return AlertDialog(
              title: const Text('Add Progress'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: types.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedType = newValue;
                          value = 0; // Reset value when type changes
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Value ($unit)'),
                  Slider(
                    value: value,
                    min: minValue,
                    max: maxValue,
                    divisions: divisions,
                    label: selectedType == 'Calories' 
                        ? value.round().toString() 
                        : value.toStringAsFixed(1),
                    onChanged: (newValue) {
                      setState(() {
                        value = newValue;
                      });
                    },
                  ),
                  Text(
                    selectedType == 'Calories' 
                        ? '${value.round()} $unit' 
                        : '${value.toStringAsFixed(1)} $unit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    // Handle saving the progress data
                    switch (selectedType) {
                      case 'Weight':
                        // In a real app, you'd call the ViewModel to update weight
                        Provider.of<HealthViewModel>(context, listen: false)
                            .updateWeight(value);
                        break;
                      case 'Water':
                        setState(() {
                          _waterIntake = value;
                        });
                        break;
                      case 'Calories':
                        setState(() {
                          _caloriesConsumed = value;
                        });
                        break;
                      case 'Exercise':
                        // Handle exercise tracking
                        break;
                    }
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$selectedType progress updated')),
                    );
                  },
                  child: const Text('Save'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4C37),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Custom painter for water bottle visualization
class _WaterLevelPainter extends CustomPainter {
  final double percentage;
  
  _WaterLevelPainter({required this.percentage});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint bottlePaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final Paint waterPaint = Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final double bottleWidth = size.width * 0.7;
    final double bottleHeight = size.height * 0.8;
    final double bottleNeckWidth = size.width * 0.3;
    final double bottleNeckHeight = size.height * 0.2;
    final double startX = (size.width - bottleWidth) / 2;
    
    // Draw bottle shape
    final Path bottlePath = Path()
      ..moveTo(startX + (bottleWidth - bottleNeckWidth) / 2, 0)
      ..lineTo(startX + (bottleWidth + bottleNeckWidth) / 2, 0)
      ..lineTo(startX + (bottleWidth + bottleNeckWidth) / 2, bottleNeckHeight)
      ..lineTo(startX + bottleWidth, bottleNeckHeight)
      ..lineTo(startX + bottleWidth, bottleHeight + bottleNeckHeight)
      ..arcToPoint(
        Offset(startX, bottleHeight + bottleNeckHeight),
        radius: const Radius.circular(10),
        largeArc: true,
      )
      ..lineTo(startX, bottleNeckHeight)
      ..lineTo(startX + (bottleWidth - bottleNeckWidth) / 2, bottleNeckHeight)
      ..close();
    
    canvas.drawPath(bottlePath, bottlePaint);
    
    // Calculate water level
    final waterLevel = bottleHeight + bottleNeckHeight - (bottleHeight * percentage);
    
    // Draw water only if percentage > 0
    if (percentage > 0) {
      final Path waterPath = Path()
        ..moveTo(startX, waterLevel)
        ..lineTo(startX + bottleWidth, waterLevel)
        ..lineTo(startX + bottleWidth, bottleHeight + bottleNeckHeight)
        ..arcToPoint(
          Offset(startX, bottleHeight + bottleNeckHeight),
          radius: const Radius.circular(10),
          largeArc: true,
        )
        ..close();
      
      // Draw waves effect
      for (int i = 0; i < 3; i++) {
        final wavePath = Path();
        final waveHeight = 5.0;
        final frequency = 2 * math.pi / bottleWidth;
        final offsetY = i * 1.5;
        
        wavePath.moveTo(startX, waterLevel + offsetY);
        
        for (double x = 0; x <= bottleWidth; x += 5) {
          final y = waterLevel + math.sin(frequency * x) * waveHeight + offsetY;
          wavePath.lineTo(startX + x, y);
        }
        
        wavePath.lineTo(startX + bottleWidth, bottleHeight + bottleNeckHeight);
        wavePath.lineTo(startX, bottleHeight + bottleNeckHeight);
        wavePath.close();
        
        final wavePaint = Paint()
          ..color = Colors.blue.withOpacity(0.2 - i * 0.05)
          ..style = PaintingStyle.fill;
        
        canvas.drawPath(wavePath, wavePaint);
      }
      
      canvas.drawPath(waterPath, waterPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}