frequency

Utility that calculates frequency based on passed attributes OR based on FHIR resources for healthcare applications. package has no dependency on other packages, uses plain dart code.

example:

Frequency freqObj = Frequency.dynamic("every 8 hours", "Day", 3);
  print(freqObj.getNextFreq(DateTime.now()));

  Map<String, dynamic> pfhirTiming = {
    "frequency": 1,
    "period": 4.0,
    "periodUnit": "h"
  };
  String pfhirFreqText = "";

  Frequency freqObjFhir =
      Frequency.buildFromFHIRRepeat(pfhirTiming, pfhirFreqText);
  print(freqObjFhir.getNextFreq(DateTime.now()));
}
