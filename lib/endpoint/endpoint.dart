class Endpoint {
  static final String baseUrl = 'https://appabsensi.mobileprojp.com/api';
  static final String register = '$baseUrl/register';
  static final String login = '$baseUrl/login';
  static final String batches = '$baseUrl/batches';
  static final String trainings = '$baseUrl/trainings';
  static final String allHistoryAbsen = '$baseUrl/absen/history';
  static final String statAbsen = '$baseUrl/absen/stats';
  static final String profile = '$baseUrl/profile';
  static final String profilePhoto = '$baseUrl/profile/photo';
  static final String checkIn = '$baseUrl/absen/check-in';
  static final String checkOut = '$baseUrl/absen/check-out';
  static final String permission = '$baseUrl/izin';
  static final String resetPassword = '$baseUrl/reset-password';
  static final String forgotPassword = '$baseUrl/forgot-password';
  static String deleteAbsen(int id) => '$baseUrl/absen/$id';
  static String todayAbsen(String attendanceDate) =>
      '$baseUrl/absen/today?attendance_date=$attendanceDate';
}
