class ApiUrls{
  static const String baseUrl = "http://64.227.167.191:9090";
  // static const String sendOtp = "/api/student-login/mobile/send";
  // static const String verifyOtp = "/api/student-login/mobile/verify-otp";
  // static const String register = "/api/student-login/mobile/register";

  static const String login = "/api/mobile/auth/login";

  // static const String getColleges = "/api/mobile/getAutoSuggestColleges?q=";
  // static const String getCollege = "/api/college/";

  static const String getCourses = "/api/mobile/masterCourse/getAutoSuggestCourses?q=";
  static const String getSubjects = "/api/mobile/masterSubject/getAutoSuggestSubjects?q=";
  static const String generateQr = "/api/mobile/masterCourse/generateQrForAttendance";

  static const String giveAttendance = "/api/mobile/mobAttendance/attendance";
}