import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/databases/medication_database.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_component_plan.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_component_plan_entry.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_plan.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class UserCalendarPage extends StatefulWidget {
  const UserCalendarPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserCalendarPageState createState() => _UserCalendarPageState();
}

class _UserCalendarPageState extends State<UserCalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [],
      ),
      body: FutureBuilder<_AppointmentDataSource>(
        future: _getCalendarDataSource(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return SfCalendar(
              view: CalendarView.week,
              firstDayOfWeek: 1,
              showNavigationArrow: true,
              dataSource: snapshot.data,
              onTap: onTapOnCalendar,
            );
          } else {
            return const Center();
          }
        },
      ),
    );
  }

  Future<_AppointmentDataSource> _getCalendarDataSource() async {
    List<MedicationPlan> medicationPlans = await MedicationDatabaseHelper.instance.getAllMedicationPlans();
    List<Appointment> appointments = <Appointment>[];

    for (MedicationPlan medicationPlan in medicationPlans) {
      if (medicationPlan.active) {
        for (MedicationComponentPlan medicationComponentPlan in medicationPlan.medicationComponentPlans) {
          TimeOfDay timeOfDay = _convertStringToTimeOfDay(medicationComponentPlan.time);
          DateTime startTime = DateTime.parse(medicationPlan.startDateString);
          startTime = DateTime(startTime.year, startTime.month, startTime.day, timeOfDay.hour, timeOfDay.minute);

          if (medicationComponentPlan.frequency != 0.0) {
            appointments.add(Appointment(
              startTime: startTime,
              endTime: startTime.add(const Duration(minutes: 60)),
              subject: medicationPlan.name,
              color: Colors.blue,
              startTimeZone: '',
              endTimeZone: '',
              recurrenceRule: 'FREQ=DAILY;INTERVAL=${medicationComponentPlan.frequency.toInt().toString()}',
              notes: jsonEncode(medicationComponentPlan.toMap()),
            ));
          } else {
            String abbreviatedWeekdaysString = medicationComponentPlan.intakeDays
                .map((day) {
                  return day.substring(0, 2).toUpperCase();
                })
                .toList()
                .join(',');

            appointments.add(Appointment(
              startTime: startTime,
              endTime: startTime.add(const Duration(minutes: 60)),
              subject: medicationPlan.name,
              color: Colors.blueGrey,
              startTimeZone: '',
              endTimeZone: '',
              recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=$abbreviatedWeekdaysString',
              notes: jsonEncode(medicationComponentPlan.toMap()),
            ));
          }
        }
      }
    }

    return _AppointmentDataSource(appointments);
  }

  TimeOfDay _convertStringToTimeOfDay(String time) {
    final format = DateFormat.jm();
    DateTime? dateTime = format.parseStrict(time);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  void onTapOnCalendar(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == CalendarElement.appointment ||
        calendarTapDetails.targetElement == CalendarElement.agenda) {
      final Appointment appointmentDetails = calendarTapDetails.appointments![0];
      String subjectText = appointmentDetails.subject;
      String dateText = DateFormat('hh:mm a MMMM dd, yyyy').format(appointmentDetails.startTime).toString();
      String startTimeText = DateFormat('hh:mm a').format(appointmentDetails.startTime).toString();

      // Decode the MedicationComponentPlan from appointment.notes
      Map<String, dynamic> notesMap = jsonDecode(appointmentDetails.notes!);
      MedicationComponentPlan medicationPlan = MedicationComponentPlan.fromMap(notesMap);
      // Include the starting time and type of the medication
      String medicationDetails = "Component: ${medicationPlan.medicationComponent.name}\n"
          "Dosage: ${medicationPlan.dosage}${medicationPlan.medicationComponent.unit}\n"
          "Type: ${medicationPlan.type}\n";

      // Display Dialog with Medication Details and Action Buttons
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(subjectText),
              content: SizedBox(
                height: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      dateText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      medicationDetails,
                      style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await MedicationDatabaseHelper.instance.insertMedicationComponentPlanEntry(
                          MedicationComponentPlanEntry(
                              intakeDate: appointmentDetails.startTime, medicationComponentPlan: medicationPlan));
                      List<MedicationComponentPlanEntry> list =
                          await MedicationDatabaseHelper.instance.getAllMedicationComponentPlanEntries();
                      for (MedicationComponentPlanEntry entry in list) {
                        debugPrint(entry.toMap().toString());
                      }
                    },
                    child: const Text('Took Medication')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Did Not Take')),
              ],
            );
          });
    }
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
