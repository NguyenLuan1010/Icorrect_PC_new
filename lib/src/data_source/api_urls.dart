//Example
// final Uri API_USER_LIST = Uri.parse('https://api.randomuser.me/?results=50');

const API_DOMAIN = "http://api.ielts-correction.com/";
const ICORRECT_DOMAIN = "https://ielts-correction.com/";
const PUBLISH_DOMAIN = "http://public.icorrect.vn/";
const TOOL_DOMAIN = "http://tool.ielts-correction.com/";

///// api endpoints
const String registerEP = 'auth/register';
const String loginEP = 'auth/login';
const String getUserInforEP = 'me';
const String logoutEP = 'auth/logout';
const String profileInfoEP = 'auth/profile-info';
const String updateInfoEP = 'auth/update-info';
const String changePasswordEP = 'auth/change-password';
const String getTestInfoEP = 'api/v1/ielts-test/syllabus/create';
const String getHomeWorksEP = 'api/list-activity-v2';
String downloadFileEP(String name) => '${API_DOMAIN}file?filename=$name';

class RequestMethod {
  static const POST = 'POST';
  static const GET = 'GET';
  static const PATCH = 'PATCH';
  static const PUT = 'PUT';
  static const DELETE = 'DELETE';
}
