// ignore_for_file: constant_identifier_names

class APIConstants {
  static const String BASE_URL = "https://support2heal.com/manage/";

  static const String API_BASE_URL = "${BASE_URL}api/";

  static const CONNECTION_TIMEOUT = 300000;
  static const RECEIVE_TIMEOUT = 300000;

  /// API Requests
  static const String REGISTER_API = "registrations";
  static const String LISTNER_DISPLAY_API = "listners";

  static const String RAZOR_PAY_ORDERID = "no_generated";
  static const String ADDMONEY_INTO_WALLET = "store_wallet/";
  static const String getHelpersList = "registrations";
  static const String getAgoraToken = "agoraToken";
  static const String getListnerRating = "all_reviews";
  static const String searchApiUrl = "search";
  static const String walletAmountApiUrl = "show_wallet/";
  static const String ChargeWalletDeductionApi = "charge";
  static const String WITHDRAWALWalletApi = "withdrawal";
  static const String ReportApi = "report";

  static const String walletStoreApiUrl = "store_wallet";
  static const String DELETE_API = "delete";
  static const String NICKNAME_API = "nickname";
  static const String FEEDBACK_API = "feedback";
  static const String DISPLAY_NICKNAME_API = "nickname_get/";
  static const String CHAT_NOTIFY_API = "get_notification/";
  static const String CHAT_READ_NOTIFY_API = "notification_read";

  static const String showTransactionHistory_API = "show_transaction/";
  static const String showToggleListnerONOFF_API = "onlineOfline";
  static const String listnerAvailability_API = "update_listner";
  static const String bellIconNotify_API = "bellnotify";

  static const String block_API = "block";

  static const String ONLINE_API = "busy_status";
  static const String ONLINE_OFLINE = "onlineOfline";
  static const String START_RECORDING = "call_start";
  static const String STOP_RECORDING = "call_end";
  static const String createToken = "create_token";
  static const String userChatSendRequest = "chat_request";
  static const String listnerChatRequest = "listener_chat_request/";
  static const String UpdateChatRequest = "update_chat_request";
  static const String getChatRequestByUser = "get_chat_request/";
  static const String getChat = "get_chat";
  static const String chatEnd = "chat_end";
  static const String getCallID = "get_call";
}

class PrefConstants {
  static const String WALLET_AMOUNT = "wallet_amount";
  static const String MOBILE_NUMBER = "mobile_number";
  static const String LISTENER_NAME = "listener_name";
  static const String LISTENER_IMAGE = "listener_image";
  static const String MERA_USER_ID = "user_id1";
  static const String ONLINE = "online";
  static const String USER_TYPE = "user_type";
  static const String LISTNER_AVAILABILITY = "listner_availability";
  static const String LISTNER_CHAT_REQUEST = "listner_chat_request";
}
