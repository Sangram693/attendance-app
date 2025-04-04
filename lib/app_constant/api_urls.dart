class ApiUrls{
  static const String baseUrl = "http://64.227.167.191:9090";
  static const String sendOtp = "/api/student-login/mobile/send";
  static const String verifyOtp = "/api/student-login/mobile/verify-otp";
  static const String register = "/api/student-login/mobile/register";

  static const String getColleges = "/api/mobile/getAutoSuggestColleges?q=";
  static const String getCollege = "/api/college/";

  static const String giveAttendance = "/api/mobile/attendance/auto";
}