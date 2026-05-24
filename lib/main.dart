import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_calendar/calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';

late Box calendarBox;
var today = DateTime.now().toLocal().toString().split(' ')[0];
int glassCount = 0;
int milliliters = 0;
int drink = 0;


void main() async {
  await Hive.initFlutter();
  calendarBox = await Hive.openBox('calendarBox');
  HiveCheck();
  print(today);
  runApp(MaterialApp(

    theme: ThemeData(),
    darkTheme: ThemeData.dark(),
    themeMode: ThemeMode.system,
    initialRoute: '/',
    routes: {
      '/': (context) => WaterCounter(),
      '/calendar': (context) => WaterCalendar(),
    },
    )
  );
}


class WaterCounter extends StatelessWidget {
  const WaterCounter({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                decoration: InputDecoration(hintText: 'How many milliliters?'),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: (value) {
                  if (value.isEmpty){
                      drink = 0;
                  }else{
                    drink = int.parse(value);}
                }, 
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            SizedBox(height: 16,),
            ElevatedButton(
              onPressed: () {
                glassCount = glassCount + 1;
                milliliters = milliliters + drink;
                calendarBox.put(today, {'glass': glassCount, 'ml': milliliters});
                print(calendarBox.get(today));},
              child: Text('Drink!')),
            SizedBox( height: 16,),
            ElevatedButton(onPressed: () {Navigator.pushNamed(context, '/calendar');}, child: Text('Calendar')),
            SizedBox(height: 16,),
            ElevatedButton(onPressed: () {calendarBox.clear(); glassCount = 0; milliliters = 0;}, child: Text("Reset"))
          ],
        ),
      )  
    );
  }
}


class HiveCheck {

  var todaysData = calendarBox.get(today);

  HiveCheck(){
    if (todaysData != null){
      glassCount = todaysData['glass'];
      milliliters = todaysData['ml'];
    }
  }
}
