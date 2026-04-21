class ApiConstants {
  static const baseUrl = 'http://160.30.136.196:3465';

  // AUTH
  static const login = '/api/v1/auth/authenticate';
  static const register = '/api/v1/auth/register';

  // MEDICATION
  static const medications = '/api/v1/medications';
  static String medicationById(int id) => '/api/v1/medications/$id';
  static String deleteMedication(int id) => '/api/v1/medications/$id';
  static String consumeMedication(int id) =>
      '/api/v1/medications/$id/consume';
  static String consumptionHistory(int id) =>
      '/api/v1/medications/$id/consumption-history';

  // PROFILE
  static const profile = '/api/v1/user/profile';
  static String profileById(int id) => '/api/v1/user/profile/$id';
  static const updateProfile = '/api/v1/user/profile';
  static const uploadAvatar = '/api/v1/user/profile/avatar';
  static const fcmToken = '/api/v1/user/fcm-token';

  // FILE
  static String fileView(String filename) => '/api/v1/file/view/$filename';
  static String fileDownload(String filename) =>
      '/api/v1/file/download/$filename';
  static String avatar(String filename) =>
      '/api/v1/file/avatar/$filename';

  // CHAT
  static const createConversation = '/api/v1/chat/create_conversation';
  static const sendMessage = '/api/v1/chat/send_message';
  static const listConversation = '/api/v1/chat/get_list_conversation';
  static String getMessages(int id) =>
      '/api/v1/chat/get_messages/$id';
  static String deleteConversation(int id) =>
      '/api/v1/chat/delete_conversation/$id';
}