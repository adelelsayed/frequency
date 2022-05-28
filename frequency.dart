import './frequency_utils.dart';
import './frequency_dynamic_utils.dart';
import './frequency_static_utils.dart';

/**
 * this module would ideally be used in healthcare apps context as it was built with that in mind
 * this class is the central class of the module, user is advised to interact only with it.
 * user objective is to successfully instantiate an instance of this class for the frequency desired, 
 * then user can call instance method getNextFreq() to get a string represents the next date time occurrence of this frequency.
 *  you can use it in two ways:
 * 1- build from FHIR resource
 * according to the guideline defined here http://www.hl7.org/fhir/datatypes.html#Timing
 * passing a fhir Timing.repeat Map to the static class method Frequency.BuildFromFHIRRepeat(Map<String, dynamic> fhirMap, String fallback_text)
 * 2- create custom frequencies
 * using this class constructors:
 *  - once frequency constructor: creates a once only occurence frequency
 *    Frequency My_frequncy=Frequency.Once("my frequency name");
 *  - dynamic frequency constructor: creates a frequency with occureances dynamically set taking DateTime.now() time as starting point.
 *    Frequency My_frequncy=Frequency.Dynamic("my frequency name","Day" ,3);
 *    will yield a frequency of 3 occureances every day with now time as starting point
 *  - static frequency constructor: creates a frequency with occureances statically set by user.
 *    Frequency My_frequncy=Frequency.Static("my frequency name","Day", ["02:00","10:00", "18:00"]);
 * 
 *  supported intervals for both dynamic and static frequencies are "Day", "Week", "Month", "Year"
 */
class Frequency {
  String? name;
  bool isText = false;
  bool isOnce = false;

  ///dynamic calculation -- no specific timing
  bool isDynamic = false;
  int? timesPerDay;
  int? timesPerWeek;
  int? timesPerMonth;
  int? timesPerYear;

  ///static timings
  List<String>? hoursAtDay;
  List<String>? daysAtWeek;
  List<String>? daysAtMonth;
  List<String>? daysAtYear;

  Frequency(
      String pName,
      bool pIsOnce,
      bool pIsDynamic,
      int pTimesPerDay,
      int pTimesPerWeek,
      int pTimesPerMonth,
      int pTimesPerYear,
      List<String> pHoursAtDay,
      List<String> pDaysAtWeek,
      List<String> pDaysAtMonth,
      List<String> pDaysAtYear) {
    this.name = pName;
    this.isOnce = pIsOnce;
    this.isDynamic = pIsDynamic;
    this.timesPerDay = pTimesPerDay;
    this.timesPerWeek = pTimesPerWeek;
    this.timesPerMonth = pTimesPerMonth;
    this.timesPerYear = pTimesPerYear;
    this.hoursAtDay = pHoursAtDay;
    this.daysAtWeek = pDaysAtWeek;
    this.daysAtMonth = pDaysAtMonth;
    this.daysAtYear = pDaysAtYear;
  }

  ///single occureance frequency constructor
  Frequency.Once(String pName) {
    this.name = pName;
    this.isOnce = true;

    this.isDynamic = false;
    this.isText = false;
    this.timesPerDay = 0;
    this.timesPerWeek = 0;
    this.timesPerMonth = 0;
    this.timesPerYear = 0;
    this.hoursAtDay = [];
    this.daysAtWeek = [];
    this.daysAtMonth = [];
    this.daysAtYear = [];
  }

  ///dynamic occureance frequency constructor
  Frequency.Dynamic(String pName, String pInterval, int pTimesPerInterval) {
    this.name = pName;
    this.isOnce = false;

    this.isDynamic = true;
    this.isText = false;
    pInterval == "Day" ? this.timesPerDay = pTimesPerInterval : 0;
    pInterval == "Week" ? this.timesPerWeek = pTimesPerInterval : 0;
    pInterval == "Month" ? this.timesPerMonth = pTimesPerInterval : 0;
    pInterval == "Year" ? this.timesPerYear = pTimesPerInterval : 0;
    this.hoursAtDay = [];
    this.daysAtWeek = [];
    this.daysAtMonth = [];
    this.daysAtYear = [];
  }

  ///static occureance frequency constructor
  Frequency.Static(
      String pName, String pPeriod, List<String> pListOfTimesAtPeriod) {
    this.name = pName;
    this.isOnce = false;

    this.isDynamic = false;
    this.isText = false;
    this.timesPerDay = 0;
    this.timesPerWeek = 0;
    this.timesPerMonth = 0;
    this.timesPerYear = 0;
    pPeriod == "Day" ? this.hoursAtDay = pListOfTimesAtPeriod : [];
    pPeriod == "Week" ? this.daysAtWeek = pListOfTimesAtPeriod : [];
    pPeriod == "Month" ? this.daysAtMonth = pListOfTimesAtPeriod : [];
    pPeriod == "Year" ? this.daysAtYear = pListOfTimesAtPeriod : [];

    if (pPeriod == "Day") {
      //list of hours in pattern ["08:00:00","10:00:00",..]
      DateTime nw = DateTime.now();
      this.hoursAtDay!.sort((a, b) => DateTime(
              nw.year,
              nw.month,
              nw.day,
              int.parse(a.split(":")[0]),
              int.parse(a.split(":")[1]),
              int.parse(a.split(":")[2]))
          .compareTo(DateTime(
              nw.year,
              nw.month,
              nw.day,
              int.parse(a.split(":")[0]),
              int.parse(a.split(":")[1]),
              int.parse(a.split(":")[2]))));
    }

    if (pPeriod == "Week") {
      //list of weekdays ["Monday","Tuesday",..]
      this
          .daysAtWeek!
          .sort((a, b) => weekDays.indexOf(a).compareTo(weekDays.indexOf(b)));
    }

    if (pPeriod == "Month") {
      //list of month days by index [1,2,9]
      this.daysAtMonth!.sort((a, b) => a.compareTo(b));
    }

    if (pPeriod == "Year") {
      //list of time stamps across the year with datetime format as Y-m-d H:m:s Z 2022-02-22 09:00:00 +0400
      this
          .daysAtYear!
          .sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
    }
  }

  ///frequency as Text notion
  Frequency.Text(String pName) {
    this.name = pName;
    this.isText = true;
  }

  ///build a Frequency object from a FHIR Timing.repeat Map
  static Frequency BuildFromFHIRRepeat(
      Map<String, dynamic> fhirTiming, String fhirFreqText) {
    Map<String, String> periodUnitMap = {
      "d": "Day",
      "h": "Hour",
      "wk": "Week",
      "mo": "Month",
      "y": "Year"
    };

    Map<String, String> weekDaystMap = {
      "mon": "Monday",
      "tue": "Tuesday",
      "wed": "Wednesday",
      "thu": "Thursday",
      "fri": "Friday",
      "sat": "Saturday",
      "sun": "Sunday"
    };

    if (fhirTiming.containsKey("frequency") &&
        fhirTiming.containsKey("period") &&
        fhirTiming.containsKey("periodUnit")) {
      if ((fhirTiming.containsKey("timeOfDay"))) {
        String pPeriod = periodUnitMap[fhirTiming["periodUnit"]].toString();
        return Frequency.Static(
            "", pPeriod, fhirTiming["timeOfDay"].split("|"));
      } else if ((fhirTiming.containsKey("DayOfWeek"))) {
        String pPeriod = periodUnitMap[fhirTiming["periodUnit"]].toString();
        List<String> daysInWeek = fhirTiming["DayOfWeek"].split("|");
        return Frequency.Static("", pPeriod,
            daysInWeek.map((e) => weekDaystMap[e].toString()).toList());
      } else {
        String pInterval = periodUnitMap[fhirTiming["periodUnit"]].toString();

        double pTimesPerIntervald =
            (fhirTiming["frequency"]) * (fhirTiming["period"]);
        int pTimesPerInterval = pTimesPerIntervald.toInt();

        if ((pInterval == "Hour") ||
            ((pInterval == "Day") && (fhirTiming["period"] == 1))) {
          pTimesPerInterval =
              24 ~/ ((fhirTiming["frequency"]) * (fhirTiming["period"]));
          pInterval = "Day";
        } else if ((pInterval == "Day") && (fhirTiming["period"] > 1)) {
          pTimesPerInterval =
              30 ~/ ((fhirTiming["frequency"]) * (fhirTiming["period"]));
          pInterval = "Month";
        }

        return Frequency.Dynamic("", pInterval, pTimesPerInterval);
      }
    } else if (fhirTiming.containsKey("count") &&
        (fhirTiming["count"] as int == 1)) {
      return Frequency.Once("");
    }
    return Frequency.Text(fhirFreqText);
  }

  bool get isStatic {
    return !(isOnce || isDynamic);
  }

  /// will return a string of the next date time of the frequency occureance
  String getNextFreq(DateTime zerPoint) {
    String retVal = "Couldn't Calculate Next Frequency Time";

    if (this.isOnce) {
      retVal = "Once";
    } else if (this.isDynamic) {
      retVal = getDynamicDate(this, zerPoint).toString();
    } else if (this.isStatic) {
      retVal = getStaticDate(this, zerPoint).toString();
    }

    return retVal;
  }
}
