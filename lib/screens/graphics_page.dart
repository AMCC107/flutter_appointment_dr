import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GraphicsPage extends StatefulWidget {
  const GraphicsPage({super.key});

  @override
  State<GraphicsPage> createState() => _GraphicsPageState();
}

class _GraphicsPageState extends State<GraphicsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userRole;
  bool _isRoleLoading = true;
  bool _isLoading = true;
  Map<String, int> _appointmentsPerMonth = {};
  int _citasCompletadas = 0;
  int _citasPendientes = 0;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      setState(() {
        _userRole = doc.data()?['rol'] ?? 'paciente';
        _isRoleLoading = false;
      });
      
      // Only load data if user is a doctor
      if (_userRole == 'medico') {
        _loadData();
      }
    } else {
      setState(() {
        _isRoleLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all appointments from Firestore (collection 'citas')
      final snapshot = await _firestore.collection('citas').get();

      // Process data for monthly appointments
      final Map<String, int> monthlyCounts = {};
      
      // Process data for completed vs pending appointments
      final now = DateTime.now();
      int citasCompletadas = 0;
      int citasPendientes = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Process date for monthly chart
        final fecha = data['fecha'] as Timestamp?;
        if (fecha != null) {
          final dateTime = fecha.toDate();
          final monthKey = DateFormat('MMM yyyy').format(dateTime);
          monthlyCounts[monthKey] = (monthlyCounts[monthKey] ?? 0) + 1;
          
          // Check if appointment is completed or pending
          // Compare date and time if available
          final horaInicio = data['horaInicio'] as Timestamp?;
          if (horaInicio != null) {
            final fechaHoraCita = horaInicio.toDate();
            if (fechaHoraCita.isBefore(now)) {
              citasCompletadas++;
            } else {
              citasPendientes++;
            }
          } else {
            // If no time, just compare dates
            final fechaNormalizada = DateTime(dateTime.year, dateTime.month, dateTime.day);
            final ahoraNormalizada = DateTime(now.year, now.month, now.day);
            if (fechaNormalizada.isBefore(ahoraNormalizada)) {
              citasCompletadas++;
            } else {
              citasPendientes++;
            }
          }
        }
      }

      setState(() {
        _appointmentsPerMonth = monthlyCounts;
        _citasCompletadas = citasCompletadas;
        _citasPendientes = citasPendientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check role loading state
    if (_isRoleLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if user is not a doctor
    if (_userRole != 'medico') {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Appointment Statistics'),
          centerTitle: true,
          backgroundColor: Colors.redAccent,
          elevation: 4,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Acceso Denegado',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Solo los usuarios con rol de médico pueden acceder a esta página.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Appointment Statistics'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    const Text(
                      'Appointment Statistics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Visual insights into your appointment data',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bar Chart Card - Appointments per Month
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  color: Colors.blueAccent,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Citas por Mes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_appointmentsPerMonth.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.insert_chart,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No hay datos de citas disponibles',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                height: 300,
                                child: Stack(
                                  children: [
                                    BarChart(
                                      _buildMonthlyBarChartData(),
                                    ),
                                    _buildBarLabels(),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Pie Chart Card - Completed vs Pending Appointments
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.pie_chart,
                                  color: Colors.blueAccent,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Estado de Citas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_citasCompletadas == 0 && _citasPendientes == 0)
                              const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_note,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No hay datos de citas disponibles',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  SizedBox(
                                    height: 300,
                                    child: PieChart(
                                      _buildPieChartData(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Legend
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildLegendItem(
                                        'Citas Completadas',
                                        Colors.green,
                                        _citasCompletadas,
                                      ),
                                      const SizedBox(width: 24),
                                      _buildLegendItem(
                                        'Citas Pendientes',
                                        Colors.orange,
                                        _citasPendientes,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  BarChartData _buildMonthlyBarChartData() {
    final sortedMonths = _appointmentsPerMonth.keys.toList()
      ..sort((a, b) {
        // Sort by date
        try {
          final dateA = DateFormat('MMM yyyy').parse(a);
          final dateB = DateFormat('MMM yyyy').parse(b);
          return dateA.compareTo(dateB);
        } catch (e) {
          return a.compareTo(b);
        }
      });

    final maxValue = _appointmentsPerMonth.values.isEmpty
        ? 1
        : _appointmentsPerMonth.values.reduce((a, b) => a > b ? a : b);

    // Calculate dynamic maxY to ensure bars don't touch the top
    final maxY = maxValue + 1;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY.toDouble(),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.blueAccent,
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final month = sortedMonths[groupIndex];
            final count = _appointmentsPerMonth[month] ?? 0;
            return BarTooltipItem(
              '$month\n$count citas',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
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
              if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                final month = sortedMonths[value.toInt()];
                // Show abbreviated month
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    month.length > 7 ? month.substring(0, 3) : month,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const Text('');
            },
            reservedSize: 40,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 1, // CRITICAL FIX: Prevent duplicate Y-axis labels
            getTitlesWidget: (value, meta) {
              // Only show integer values
              if (value == value.toInt().toDouble()) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2), // Very subtle
            strokeWidth: 1,
            dashArray: [5, 5], // Dashed lines
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
          left: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      barGroups: sortedMonths.asMap().entries.map((entry) {
        final index = entry.key;
        final month = entry.value;
        final count = _appointmentsPerMonth[month] ?? 0;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.blue,
                  Colors.blueAccent,
                ],
              ),
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8), // Rounded top corners
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBarLabels() {
    final sortedMonths = _appointmentsPerMonth.keys.toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('MMM yyyy').parse(a);
          final dateB = DateFormat('MMM yyyy').parse(b);
          return dateA.compareTo(dateB);
        } catch (e) {
          return a.compareTo(b);
        }
      });

    if (sortedMonths.isEmpty) return const SizedBox.shrink();

    final maxValue = _appointmentsPerMonth.values.isEmpty
        ? 1
        : _appointmentsPerMonth.values.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue + 1;

    // Chart dimensions (approximate, adjust based on actual chart size)
    const chartHeight = 300.0;
    const bottomPadding = 40.0; // Reserved space for bottom titles
    const leftPadding = 40.0; // Reserved space for left titles
    const topPadding = 0.0;
    const usableHeight = chartHeight - bottomPadding - topPadding;

    return LayoutBuilder(
      builder: (context, constraints) {
        final actualWidth = constraints.maxWidth;
        final actualBarSpacing = (actualWidth - leftPadding) / sortedMonths.length;
        
        return Stack(
          children: sortedMonths.asMap().entries.map((entry) {
            final index = entry.key;
            final month = entry.value;
            final count = _appointmentsPerMonth[month] ?? 0;
            
            // Calculate position
            final barCenterX = leftPadding + (index * actualBarSpacing) + (actualBarSpacing / 2);
            final barHeight = (count / maxY) * usableHeight;
            final labelY = chartHeight - bottomPadding - barHeight - 20; // 20px above bar
            
            return Positioned(
              left: barCenterX - 15, // Center the label
              top: labelY,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  PieChartData _buildPieChartData() {
    final total = _citasCompletadas + _citasPendientes;
    
    if (total == 0) {
      return PieChartData();
    }

    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 60,
      sections: [
        PieChartSectionData(
          value: _citasCompletadas.toDouble(),
          title: '${_citasCompletadas}\n(${((_citasCompletadas / total) * 100).toStringAsFixed(1)}%)',
          color: Colors.green,
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          value: _citasPendientes.toDouble(),
          title: '${_citasPendientes}\n(${((_citasPendientes / total) * 100).toStringAsFixed(1)}%)',
          color: Colors.orange,
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              '$value citas',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
