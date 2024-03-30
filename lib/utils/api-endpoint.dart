// ignore_for_file: non_constant_identifier_names

class ApiEndPoints {
  static const String baseUrl = 'https://nqp82lpb-5050.asse.devtunnels.ms/';

  static _AuthEndPoints authEndpoints = _AuthEndPoints();
}

class _AuthEndPoints {
  final String login = 'authenticate/login';
  final String homepage = 'services/homepage';
  final String userProfile = 'services/images';
  final String personalDetail = 'services/personal-details';
  final String userAddress = 'services/user-address';
  final String userContact = 'services/user-contact';
  final String userEducation = 'services/user-education';
  final String serveEducationAttachment =
      'services/serve-education-attachment/';
  final String userClaim = 'services/user-claim';
  final String userLeave = 'services/user-leave';
  final String userServiceDesk = 'services/service-desk';
  final String userAttendance = 'services/user-attendance';
  final String userMemo = 'services/user-memo';
  final String resetPassword = 'services/reset-password';
  final String userPaySlip = 'services/user-payslip';
  final String servePayslip = 'services/serve-user-payslip/';
}
