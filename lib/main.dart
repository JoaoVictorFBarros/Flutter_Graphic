// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Gráfico de Temperatura'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: TemperatureChart(),
      ),
    );
  }
}

class TemperatureChart extends StatefulWidget {
  @override
  _TemperatureChartState createState() => _TemperatureChartState();
}

class _TemperatureChartState extends State<TemperatureChart> {
  List<FlSpot> spots = [];
  final today = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchTemperatureData();
  }

  Future<void> fetchTemperatureData() async {
    const url = 'https://api.open-meteo.com/v1/forecast?latitude=-20.1754&longitude=-44.9137&daily=temperature_2m_min&past_days=92';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
        List<dynamic> times = data['daily']['time'];
      final List<dynamic> temperatures = data['daily']['temperature_2m_min'];

      setState(() {
        spots = List.generate(
          times.length,
          (index) => FlSpot(
            index.toInt() - 92,
            temperatures[index],
          ),
        );
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(50.0),
      color: Colors.black,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: spots.isEmpty ? CircularProgressIndicator() : LineChart(
        LineChartData(
          minX: -95,
          maxX: 7,
          minY: 4,
          maxY: 25,
          gridData: FlGridData(show: true,getDrawingHorizontalLine: (value) => FlLine(color: Colors.white,strokeWidth: 0.4,), getDrawingVerticalLine: (value) => FlLine(color: Colors.white,strokeWidth: 0.4,)),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(reservedSize: 40,showTitles: true, interval: 7,
                  getTitlesWidget: (value, meta) {
                    DateTime date = today.add(Duration(days: value.toInt()));
                    String formattedDate = DateFormat('dd/MM').format(date);
                    return Text(
                      formattedDate,
                      style: TextStyle(color: Colors.white),
                    );
                  },)),
            leftTitles: AxisTitles(sideTitles: SideTitles(reservedSize: 40,showTitles: true, getTitlesWidget: (value, meta)=> Text(value.toString(), style: TextStyle(color: Colors.white),))),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: Colors.white,
              dotData: FlDotData(show: true),
            ),
          ],
          lineTouchData: LineTouchData(enabled: true),
        ),
      ),
    );
  }
}
