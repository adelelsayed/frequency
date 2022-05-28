import './frequency.dart';
import './frequency_utils.dart';

///calculates the next Date Time from a Dynamic Frequency object given a zero date time point
DateTime getDynamicDate(Frequency freqObject, DateTime startDt) {
  //check utc, if utc, set to local
  startDt = startDt.isUtc ? startDt.toLocal() : startDt;
  DateTime currentDtTm = DateTime.now();

  DateTime retVal = startDt;
  if (freqObject.timesPerDay != null) {
    double intervalseconds = 86400 / freqObject.timesPerDay!;

    DateTime firstDoseNextDay = DateTime(currentDtTm.year, currentDtTm.month,
        currentDtTm.day, startDt.hour, startDt.minute, startDt.second);

    DateTime thirdtDayStart = DateTime(currentDtTm.year, currentDtTm.month,
        currentDtTm.day + 2, startDt.hour, startDt.minute, startDt.second);

    while (firstDoseNextDay.isBefore(thirdtDayStart)) {
      firstDoseNextDay =
          firstDoseNextDay.add(Duration(seconds: intervalseconds.round()));
      if (firstDoseNextDay.isAfter(currentDtTm)) {
        retVal = firstDoseNextDay;
        break;
      }
    }
  } else if (freqObject.timesPerWeek != null) {
    double intervalseconds = (7 * 86400) / freqObject.timesPerWeek!;

    DateTime firstDoseNextDay = startDt;

    DateTime nextWStart = DateTime(currentDtTm.year, currentDtTm.month,
        currentDtTm.day + 7, startDt.hour, startDt.minute, startDt.second);

    while (firstDoseNextDay.isBefore(nextWStart)) {
      firstDoseNextDay =
          firstDoseNextDay.add(Duration(seconds: intervalseconds.round()));
      if (firstDoseNextDay.isAfter(currentDtTm)) {
        retVal = firstDoseNextDay;
        break;
      }
    }
  } else if (freqObject.timesPerMonth != null) {
    double daysInCurrentMonth =
        DateTime(currentDtTm.year, currentDtTm.month + 1, 0).day as double;
    bool isInCurrentMonthFirstHalf =
        currentDtTm.day / daysInCurrentMonth < 0.5 ? true : false;
    if (!isInCurrentMonthFirstHalf) {
      daysInCurrentMonth = (daysInCurrentMonth +
              DateTime(currentDtTm.year, currentDtTm.month + 2, 0).day) /
          2;
    }

    double intervalseconds =
        (daysInCurrentMonth * 86400) / freqObject.timesPerMonth!;

    DateTime nextMStart = DateTime(
        currentDtTm.year,
        currentDtTm.month,
        currentDtTm.day + daysInCurrentMonth.round(),
        startDt.hour,
        startDt.minute,
        startDt.second); //start at 00:00:00

    DateTime nextDose = startDt;

    while (nextDose.isBefore(nextMStart)) {
      //append second day timestamp by substraction from third day

      nextDose = nextDose.add(Duration(seconds: intervalseconds.round()));
      if (nextDose.isAfter(currentDtTm)) {
        retVal = nextDose;
        break;
      }
    }
  } else if (freqObject.timesPerYear != null) {
    int daysInCurrentYear = inLeapYear() ? 366 : 365;

    double intervalseconds =
        (daysInCurrentYear * 86400) / freqObject.timesPerYear!;

    DateTime nextDose = startDt;

    DateTime nextYStart = DateTime(
        currentDtTm.year,
        currentDtTm.month,
        currentDtTm.day + daysInCurrentYear,
        startDt.hour,
        startDt.minute,
        startDt.second);

    while (nextDose.isBefore(nextYStart)) {
      //append second day timestamp by substraction from third day

      nextDose = nextDose.add(Duration(seconds: intervalseconds.round()));
      if (nextDose.isAfter(currentDtTm)) {
        retVal = nextDose;
        break;
      }
    }
  } else {
    throw Exception(
        "insufficient parameters for dynamic frequency, start date will be returned!");
  }

  return retVal;
}
