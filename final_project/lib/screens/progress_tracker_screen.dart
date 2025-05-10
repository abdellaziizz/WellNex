import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellnex/viewmodels/health_viewmodel.dart';

class ProgressTrackerScreen extends StatelessWidget {
  const ProgressTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final healthViewModel = Provider.of<HealthViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B4C37),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.analytics,
                    color: Colors.grey[700],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Progress Title
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B4C37),
                ),
              ),
              const SizedBox(height: 30),
              // Weight Graph
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B4C37),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Weight Graph
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomPaint(
                        painter: WeightGraphPainter(),
                        size: const Size(double.infinity, 150),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Weight Values
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '67.0',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Text(
                          '68.0',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Text(
                          '71.0',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Text(
                          '70.0',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Health Metrics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Blood Pressure
                  _buildMetricCard(
                    title: 'RBC count',
                    value: '12.0',
                    unit: 'mm',
                    subtitle: 'Cap meter',
                    icon: Icons.watch_later_outlined,
                    color: Colors.red[100]!,
                    iconColor: Colors.red,
                  ),
                  // Heart Rate
                  _buildMetricCard(
                    title: 'O2',
                    value: '67',
                    unit: 'bpm',
                    subtitle: 'SpO2bk',
                    icon: Icons.favorite_border,
                    color: Colors.green[100]!,
                    iconColor: Colors.green,
                  ),
                  // Calories
                  _buildMetricCard(
                    title: 'Calories',
                    value: '71.02',
                    unit: 'km',
                    subtitle: 'Calories burn',
                    icon: Icons.local_fire_department_outlined,
                    color: Colors.blue[100]!,
                    iconColor: Colors.blue,
                  ),
                ],
              ),
              const Spacer(),
              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/articles');
                  },
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF0B4C37),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class WeightGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;

    // Path for the line graph
    final path = Path();

    // Define data points (normalized to fit within the canvas)
    final points = [
      Offset(0, height * 0.6),
      Offset(width * 0.2, height * 0.4),
      Offset(width * 0.4, height * 0.7),
      Offset(width * 0.6, height * 0.5),
      Offset(width * 0.8, height * 0.3),
      Offset(width, height * 0.5),
    ];

    // Create the path
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Draw the path
    final paint = Paint()
      ..color = const Color(0xFF0B4C37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF0B4C37)
      ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }

    // Fill area under the line
    final fillPath = Path()
      ..addPath(path, Offset.zero)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    final fillPaint = Paint()
      ..color = const Color(0xFF0B4C37).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}