import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'disease_selection_page.dart'; // Import DiseaseSelectionPage

class BMIScreen extends StatelessWidget {
  final String userId; // Firebase user ID
  final double height;
  final double weight;

  BMIScreen({required this.userId, required this.height, required this.weight});

  double calculateBMI() {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return "Underweight - Consider a balanced diet.";
    } else if (bmi < 24.9) {
      return "Normal weight - Keep up the good work!";
    } else if (bmi < 29.9) {
      return "Overweight - Consider a healthy diet & exercise.";
    } else {
      return "Obese - It's recommended to consult a nutritionist.";
    }
  }

  // Save BMI data to Firestore
  Future<void> saveBMIToFirebase(double bmi, String category) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'bmi': bmi,
      'bmi_category': category,
      'height': height,
      'weight': weight,
    });
  }

  @override
  Widget build(BuildContext context) {
    double bmi = calculateBMI();
    String bmiCategory = getBMICategory(bmi);

    return Scaffold(
      appBar: AppBar(title: Text("Your BMI Result")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your BMI: ${bmi.toStringAsFixed(1)}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              bmiCategory,
              style: TextStyle(fontSize: 18, color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildBMIGauge(bmi), // Updated Gauge Chart
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await saveBMIToFirebase(bmi, bmiCategory); // Save BMI before moving forward
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiseaseSelectionPage(userId: userId)),
                );
              },
              child: Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIGauge(double bmi) {
    return SizedBox(
      height: 200,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 10, 
            maximum: 40, 
            startAngle: 180,
            endAngle: 0,
            radiusFactor: 0.9,
            showLabels: true,
            showTicks: false,
            axisLineStyle: AxisLineStyle(
              thickness: 15,
              color: Colors.grey.shade300,
            ),
            pointers: <GaugePointer>[
              NeedlePointer(
                value: bmi,
                enableAnimation: true,
                needleColor: Colors.black,
                knobStyle: KnobStyle(
                  color: Colors.black,
                  borderColor: Colors.white,
                  borderWidth: 0.5,
                ),
              ),
            ],
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: 10,
                endValue: 18.5,
                color: Colors.blue,
                startWidth: 15,
                endWidth: 15,
              ),
              GaugeRange(
                startValue: 18.5,
                endValue: 24.9,
                color: Colors.green,
                startWidth: 15,
                endWidth: 15,
              ),
              GaugeRange(
                startValue: 24.9,
                endValue: 29.9,
                color: Colors.orange,
                startWidth: 15,
                endWidth: 15,
              ),
              GaugeRange(
                startValue: 29.9,
                endValue: 40,
                color: Colors.red,
                startWidth: 15,
                endWidth: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
