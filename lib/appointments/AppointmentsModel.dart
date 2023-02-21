import 'package:dayos_book_app/BaseModel.dart';

class Appointment {
  String appointmentDate;
  String appointmentTime;
  String description;
  int id;
  String title;

  @override
  String toString() {
    return "id = $id, description = $description, date = $appointmentDate, "
        "time = $appointmentTime";
  }
}

class AppointmentsModel extends BaseModel {
  String appointmentTime;

  void setAppointmentTime(String inAppointmentTime) {
    appointmentTime = inAppointmentTime;
    notifyListeners();
  }
}

AppointmentsModel appointmentsModel = AppointmentsModel();
