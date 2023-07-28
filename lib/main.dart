import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Details',
      theme: ThemeData.dark(), // Set the theme to dark
      home: CarDetailsScreen(),
    );
  }
}

class CarDetails {
  final String make;
  final String model;
  final double mileage;

  CarDetails(this.make, this.model, this.mileage);
}

class CarDetailsScreen extends StatefulWidget {
  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  TextEditingController _makeController = TextEditingController();
  TextEditingController _modelController = TextEditingController();
  TextEditingController _mileageController = TextEditingController();

  List<CarDetails> _savedCars = [];

  void _saveCarDetails() {
    String make = _makeController.text;
    String model = _modelController.text;
    double mileage = double.tryParse(_mileageController.text) ?? 0.0;

    if (make.isNotEmpty && model.isNotEmpty && mileage > 0) {
      DatabaseReference carRef =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance.reference().child('cars').push();

      carRef.set({
        'make': make,
        'model': model,
        'mileage': mileage,
      }).then((_) {
        _makeController.clear();
        _modelController.clear();
        _mileageController.clear();

        setState(() {
          _savedCars.add(CarDetails(make, model, mileage));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car details saved successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving car details')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields with valid data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Details', style: TextStyle(fontSize: 24.0)),
        centerTitle: true, // Center the title
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _makeController,
                decoration: InputDecoration(labelText: 'Car Make (Name)'),
              ),
              TextField(
                controller: _modelController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Car Model (YYYY)'),
              ),
              TextField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Car Mileage (Km/L)'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveCarDetails,
                child: Text('SAVE'),
              ),
              SizedBox(height: 16.0),
              Text(
                'Saved Car Details:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Divider(), // Add a divider for a gap between sections
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _savedCars.length,
                itemBuilder: (context, index) {
                  final car = _savedCars[index];

                  // Get the current year
                  int currentYear = DateTime.now().year;

                  // Check conditions for the color and display message
                  Color carColor = Colors.red;
                  String carMessage = 'Your vehicle is Highly Pollutant';

                  if (car.mileage >= 15) {
                    int carModel = int.tryParse(car.model) ?? 0;
                    if ((currentYear - carModel) <= 5) {
                      carColor = Colors.green;
                      carMessage = 'Your vehicle is Fuel Efficient and Low Pollutant';
                    } else {
                      carColor = Colors.amber;
                      carMessage = 'Your vehicle is Fuel Efficient but Moderately Pollutant';
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: carColor,
                        child: ListTile(
                          title: Text('Make: ${car.make}'),
                          subtitle: Text('Model: ${car.model}, Mileage: ${car.mileage}'),
                        ),
                      ),
                      SizedBox(height: 8.0), // Gap between saved car details
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          carMessage,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}