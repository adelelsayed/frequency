import './frequency.dart';
import './frequency_utils.dart';

///calculates the next Date Time from a Static Frequency object given a zero date time point
DateTime getStaticDate(Frequency freqObject, DateTime startDt) {
  startDt = startDt.isUtc ? startDt.toLocal() : startDt;

  DateTime retVal = startDt;
  DateTime currentDtTm = DateTime.now();

  if ((freqObject.hoursAtDay != null) && freqObject.hoursAtDay!.isNotEmpty) {
    //list passed as ["08:00:00","16:00:00",...]
    double intervalseconds = 86400 / freqObject.hoursAtDay!.length;

    DateTime firstDoseNextDay =
        DateTime(currentDtTm.year, currentDtTm.month, currentDtTm.day);

    DateTime thirdtDayStart = DateTime(currentDtTm.year, currentDtTm.month,
        currentDtTm.day + 2, startDt.hour, startDt.minute, startDt.second);

    bool found = false;
    while (firstDoseNextDay.isBefore(thirdtDayStart)) {
      if (firstDoseNextDay.isAfter(currentDtTm) ||
          (firstDoseNextDay ==
              DateTime(currentDtTm.year, currentDtTm.month, currentDtTm.day))) {
        String firstDoseString = "";
        for (var hr in freqObject.hoursAtDay!) {
          firstDoseString = firstDoseNextDay.year.toString() +
              "-" +
              firstDoseNextDay.month.toString() +
              "-" +
              firstDoseNextDay.day.toString() +
              " " +
              hr;

          DateTime firstDoseStringDate = DateTime.parse(firstDoseString);

          if (firstDoseStringDate.isAtSameMomentAs(firstDoseNextDay) ||
              firstDoseStringDate.isAfter(firstDoseNextDay)) {
            retVal = firstDoseStringDate;
            found = true;
            break;
          }
        }
        if (found) {
          break;
        }
      }
      firstDoseNextDay =
          firstDoseNextDay.add(Duration(seconds: intervalseconds.round()));
    }
  } else if ((freqObject.daysAtWeek != null) &&
      freqObject.daysAtWeek!.isNotEmpty) {
    //["Sunday","TuesDay",...]
    double intervalseconds = (7 * 86400) / freqObject.daysAtWeek!.length;

    DateTime firstDoseNextDay =
        DateTime(startDt.year, startDt.month, startDt.day);

    DateTime nextWStart = DateTime(currentDtTm.year, currentDtTm.month,
        currentDtTm.day + 7, startDt.hour, startDt.minute, startDt.second);

    bool found = false;
    while (firstDoseNextDay.isBefore(nextWStart)) {
      firstDoseNextDay =
          firstDoseNextDay.add(Duration(seconds: intervalseconds.round()));
      if (firstDoseNextDay.isAfter(currentDtTm)) {
        for (var dy in freqObject.daysAtWeek!) {
          if (firstDoseNextDay.weekday == weekDays.indexOf(dy)) {
            found = true;
            break;
          }
        }

        if (found) {
          break;
        }
      }
    }
  } else if ((freqObject.daysAtMonth != null) &&
      freqObject.daysAtMonth!.isNotEmpty) {
    for (var mDay in freqObject.daysAtMonth!) {
      DateTime mDayDate = DateTime(currentDtTm.year, currentDtTm.month,
          int.parse(mDay), currentDtTm.hour, 0, 0);
      if (mDayDate.isAfter(currentDtTm)) {
        retVal = mDayDate;
        break;
      }
    }
  } else if ((freqObject.daysAtYear != null) &&
      freqObject.daysAtYear!.isNotEmpty) {
    for (var yrDay in freqObject.daysAtYear!) {
      DateTime yrDayDate = DateTime.parse(yrDay);
      if (yrDayDate.isAfter(currentDtTm)) {
        retVal = yrDayDate;
        break;
      }
    }
  } else {
    throw Exception(
        "insufficient parameters for Static frequency, start date will be returned!");
  }
  return retVal;
}
