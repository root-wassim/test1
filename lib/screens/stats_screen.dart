import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../config/theme.dart';
import '../services/auth_service.dart';
import '../services/stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  StreamSubscription<int>? _todaySub;
  StreamSubscription<Map<String, int>>? _dailySub;

  // live from streams
  int _todayMinutes = 0;
  Map<String, int> _daily = {};

  // loaded once
  int _goalHours = 20;
  int _totalSeconds = 0;
  List<Map<String, dynamic>> _mostPlayed = [];
  String _userName = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _subscribeStreams();
    _loadOnce();
  }

  void _subscribeStreams() {
    // today counter — updates instantly when a track finishes
    _todaySub = StatsService.todayMinutesStream().listen((v) {
      if (mounted) setState(() => _todayMinutes = v);
    });
    // bar chart — updates as days accumulate
    _dailySub = StatsService.dailyMinutesThisMonthStream().listen((v) {
      if (mounted) setState(() => _daily = v);
    });
  }

  Future<void> _loadOnce() async {
    final user = await AuthService.getAppUser();
    final goal = await StatsService.getGoalHours();
    final total = await StatsService.getTotalSecondsThisMonth();
    final mostPlayed = await StatsService.getMostPlayed();

    if (mounted) {
      setState(() {
        _userName = user?.fullName ?? 'User';
        _goalHours = goal;
        _totalSeconds = total;
        _mostPlayed = mostPlayed;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await _loadOnce();
  }

  @override
  void dispose() {
    _todaySub?.cancel();
    _dailySub?.cancel();
    super.dispose();
  }

  // derived
  int get _totalMinutes => _totalSeconds ~/ 60;
  int get _totalHours => _totalMinutes ~/ 60;
  int get _remainingMinutes => _totalMinutes % 60;
  num get _goalProgress =>
      (_goalHours == 0 ? 0 : _totalHours / _goalHours).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppTheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Welcome ────────────────────────────────────────────────
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                  children: [
                    const TextSpan(text: 'Welcome back,\n'),
                    TextSpan(
                      text: _userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Colors.white),
                    ),
                    const TextSpan(text: ' 👋'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Today card (live) ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Today', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    '$_todayMinutes min',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const Text('listened today',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Monthly total ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Icon(Icons.calendar_month, color: AppTheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('This Month',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(
                      '${_totalHours}h ${_remainingMinutes}m',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text('Total listening time',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Monthly goal ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Monthly Goal',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    // Dropdown saves to SharedPreferences, triggers setState
                    DropdownButton<int>(
                      value: _goalHours,
                      dropdownColor: AppTheme.card,
                      style: const TextStyle(color: AppTheme.primary),
                      underline: const SizedBox(),
                      items: [10, 15, 20, 30, 50, 100]
                          .map((h) => DropdownMenuItem(
                          value: h, child: Text('$h hours')))
                          .toList(),
                      onChanged: (v) async {
                        if (v != null) {
                          await StatsService.setGoalHours(v);
                          if (mounted) setState(() => _goalHours = v);
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 12),
                  LinearPercentIndicator(
                    lineHeight: 10,
                    percent: _goalProgress.toDouble(),
                    backgroundColor: AppTheme.surface,
                    progressColor: AppTheme.secondary,
                    barRadius: const Radius.circular(5),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_totalHours / $_goalHours hours  (${(_goalProgress * 100).toInt()}%)',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Daily bar chart (live) ─────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Minutes Per Day',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  const SizedBox(height: 20),
                  SizedBox(height: 160, child: _buildChart()),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Most played ────────────────────────────────────────────
              if (_mostPlayed.isNotEmpty) ...[
                const Text('Most Played',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                const SizedBox(height: 12),
                ..._mostPlayed
                    .asMap()
                    .entries
                    .map((e) => _buildMostPlayedTile(e.key + 1, e.value)),
              ],

              if (_mostPlayed.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
                  child: const Column(children: [
                    Icon(Icons.headphones, color: Colors.white24, size: 48),
                    SizedBox(height: 12),
                    Text('No listening history yet',
                        style: TextStyle(color: Colors.white38)),
                    Text('Start playing music to see stats',
                        style: TextStyle(color: Colors.white24, fontSize: 12)),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_daily.isEmpty) {
      return const Center(
          child: Text('No data yet', style: TextStyle(color: Colors.white38)));
    }

    final now = DateTime.now();
    final daysInMonth = StatsService.daysInCurrentMonth();
    final bars = <BarChartGroupData>[];

    for (int d = 1; d <= daysInMonth; d++) {
      final key =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
      final mins = (_daily[key] ?? 0).toDouble();
      bars.add(BarChartGroupData(x: d, barRods: [
        BarChartRodData(
          toY: mins,
          color: AppTheme.primary,
          width: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ]));
    }

    return BarChart(BarChartData(
      barGroups: bars,
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (v, meta) {
              if (v % 7 != 1) return const SizedBox.shrink();
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4,
                child: Text(
                  '${v.toInt()}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
    ));
  }

  Widget _buildMostPlayedTile(int rank, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2), shape: BoxShape.circle),
          child: Center(
              child: Text('$rank',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['title'] ?? '',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text('${item['count']} plays',
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ]),
        ),
        const Icon(Icons.bar_chart, color: AppTheme.primary, size: 20),
      ]),
    );
  }
}