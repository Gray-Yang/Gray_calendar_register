import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final Color textColor = Color.fromARGB(255, 0, 0, 0);

class Calendar extends StatefulWidget {
  const Calendar({Key key}) : super(key: key);
  @override
  _CalendarState createState() => _CalendarState();
}

class Event {
  final String title;
  Event({@required this.title});

  String toString() => this.title;
}

class AppBarContent extends StatelessWidget {
  const AppBarContent({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          //padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          padding: const EdgeInsets.only(left: 19, right: 19, top: 5),
          child: Row(
            children: <Widget>[
              const Text(
                'Your office days',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarState extends State<Calendar> {
  final Stream<QuerySnapshot> users =
      FirebaseFirestore.instance.collection('users').snapshots();

  Map<DateTime, List<Event>> selectedEvents;
  Map<DateTime, bool> store;

  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  bool registered = false;
  bool pressGeoON = false;
  bool cmbscritta = false;

  @override
  void initState() {
    selectedEvents = {};
    store = {};
    super.initState();
  }

  List<Event> _getEventsfromDay(DateTime date) {
    return selectedEvents[date] ?? [];
  }

  bool _getStorefromDay(DateTime date) {
    return store[date] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    DateTime U_date = DateTime.now();
    var register = false;
    var user_email = "***@gmail.com";
    //CollectionReference user = FirebaseFirestore.instance.collection('users');
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(102.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white30,
          ),
          child: const AppBarContent(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 270, right: 0, top: 0),
            child: RaisedButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.transparent)),
                color: Color.fromARGB(255, 212, 210, 210),
                textColor: Colors.black,
                child: cmbscritta
                    ? Text("Unregister",
                        style: TextStyle(fontWeight: FontWeight.bold))
                    : Text("Register"),
                //    style: TextStyle(fontSize: 14)
                onPressed: () {
                  setState(() {
                    pressGeoON = !pressGeoON;
                    cmbscritta = !cmbscritta;
                    if (pressGeoON == true) {
                      register = true;
                      U_date = selectedDay;
                      //email = new email

                      final docUser = FirebaseFirestore.instance
                          .collection('users')
                          .doc(
                              user_email); //use user_email to classify the different user account
                      final json = {
                        'email': user_email,
                        'register': register,
                        'date': U_date,
                      };

                      docUser
                          .set(json)
                          .then((value) => print('Success Register'))
                          .catchError(
                              (error) => print('Failed to add user: $error'));

                      //change color to register
                      selectedEvents[selectedDay] = [
                        Event(title: "Registered")
                      ];
                      store[selectedDay] = true; //means registered
                    } else {
                      //delete the database element
                      //change color back to normal
                      final docUser = FirebaseFirestore.instance
                          .collection('users')
                          .doc(user_email);
                      docUser
                          .delete()
                          .then((value) => print('Cancel Register'))
                          .catchError(
                              (error) => print('Failed to add user: $error'));
                      selectedEvents[selectedDay] = [];
                      store[selectedDay] = false;
                    }
                  });
                }),
          ),
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime(2013),
            lastDay: DateTime(2200),
            calendarFormat: format,
            onFormatChanged: (CalendarFormat _format) {
              setState(() {
                format = _format;
              });
            },
            startingDayOfWeek: StartingDayOfWeek.sunday,
            daysOfWeekVisible: true,

            //Day Changed
            onDaySelected: (DateTime selectDay, DateTime focusDay) {
              setState(() {
                if (focusedDay != focusDay) {
                  if (store[selectDay] == true) {
                    pressGeoON = true;
                    cmbscritta = true;
                  } else {
                    pressGeoON = false;
                    cmbscritta = false;
                  }
                }
                selectedDay = selectDay;
                focusedDay = focusDay;
              });
              print(focusedDay);
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(selectedDay, date);
            },

            eventLoader: _getEventsfromDay,
            //To style the Calendar
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.purpleAccent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5.0),
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SizedBox(
              height: 64,
              child: TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xE5E5E5E5))),
                onPressed: () {},
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Create schedule",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.normal),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );

    // ignore: dead_code
  }
}
