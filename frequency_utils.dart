///tests if a year is a leap year
bool inLeapYear() {
  bool retVal = false;
  DateTime currentDtTm = DateTime.now();
  if (currentDtTm.year % 4 == 0) {
    if (currentDtTm.year % 100 == 0) {
      if (currentDtTm.year % 400 == 0) {
        retVal = true;
      }
    } else {
      retVal = true;
    }
  }
  return retVal;
}

///list of week days in English
List<String> weekDays = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];
