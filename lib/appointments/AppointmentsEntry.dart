import 'package:flutter/material.dart';
import 'package:dayos_book_app/appointments/AppointmentsDBWorker.dart';
import 'package:dayos_book_app/appointments/AppointmentsEntry.dart';
import 'package:dayos_book_app/appointments/AppointmentsList.dart';
import 'package:dayos_book_app/appointments/AppointmentsModel.dart';
import 'package:scoped_model/scoped_model.dart';

class Appointments extends StatelessWidget {
  Appointments() {
    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
  }

  Widget build(BuildContext inContext) {
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget inChild,
            AppointmentsModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: <Widget>[AppointmentsList(), AppointmentsEntry()],
          );
        },
      ),
    );
  }
}