import 'package:flutter/material.dart';

class Madicare extends StatefulWidget {
  const Madicare({super.key, required token, required name});

  @override
  State<Madicare> createState() => _MadicareState();
}

class _MadicareState extends State<Madicare> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: const Text("MediCare",
              style: TextStyle(
                color: Color.fromARGB(255, 15, 75, 11),
              )),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   "Welcom back ",
            //   style: TextStyle(color: const Color.fromARGB(255, 14, 94, 16)),
            // ),
            SizedBox(
              height: 16,
            ),
        
SizedBox(height: 16,),
            Text("How are you feeling today?"),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ImogeStyle(Icons.sentiment_very_satisfied),
                ImogeStyle(Icons.sentiment_neutral),
                ImogeStyle(Icons.sentiment_dissatisfied,),
              ],
            ),
            SizedBox(height: 16),
            Text("Today Maedications",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Aspirin 100mg",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("1 tablet"),
                  Text(
                    "8:00 AM",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Vitamin D3",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("2 capsules"),
                  Text(
                    "12:00 AM",
                    style: TextStyle(color: Colors.grey),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 111, 188, 115)),
                      onPressed: () {},
                      child: Text(
                        "Take Now",
                        style: TextStyle(color: Colors.black),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
           bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2F5D57),
              Color(0xFF4F7F77),
            ],
          ),
          borderRadius: BorderRadius.circular(35),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.home, color: Colors.white),
            Icon(Icons.medication, color: Colors.white70),
            Icon(Icons.people, color: Colors.white70),
            Icon(Icons.person_outline, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Expanded ImogeStyle(
    IconData Icn
    ) {
    return Expanded(
      child: Container(
        
        height: 150,
        width: 150,
        child: Icon(Icn),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 205, 231, 207),
            borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
