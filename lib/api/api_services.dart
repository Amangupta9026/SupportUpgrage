import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:support/model/listner/helpers_list_model.dart';

import '../model/addmoneyinwallet.dart';
import '../model/agora_data_model.dart';
import '../model/bell_icon_notify_model.dart';
import '../model/busy_online.dart';
import '../model/charge_wallet_model.dart';
import '../model/chat_notification.dart';
import '../model/delete_model.dart';
import '../model/feedback_model.dart';
import '../model/get_call_id_model.dart';
import '../model/get_chat_end.dart';
import '../model/get_chat_end_model.dart';
import '../model/get_chat_request_from_user.dart';
import '../model/listner/block_user_model.dart';
import '../model/listner/listner_availability_model.dart';
import '../model/listner/listner_chat_request_model.dart';
import '../model/listner/nick_name_get_model.dart';
import '../model/listner/nick_name_model.dart';
import '../model/listner/togglebutton_on_off_model.dart';
import '../model/listner/update_chat_request_model.dart';
import '../model/listner_display_model.dart';
import '../model/mywalletamount_model.dart';
import '../model/rating_model.dart';
import '../model/razorpay_orderid.dart';
import '../model/register_model.dart';
import '../model/report_model.dart';
import '../model/send_chat_id.dart';
import '../model/show_transaction_model.dart';
import '../model/support_chat_model.dart';
import '../model/user_chat_send_request.dart';
import '../model/withdrawal_model.dart';
import '../screen/call/call.dart';
import '../sharedpreference/sharedpreference.dart';
import 'api_constant.dart';
import 'dioclient.dart';
import 'package:http/http.dart' as http;

class APIServices {
  // Register API
  static Future<RegistrationModel> registerAPI(
      String mobileNumber, String helpingCategory, String deviceToken) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.REGISTER_API,
              data: FormData.fromMap({
                "mobile_no": mobileNumber,
                "helping_category": helpingCategory,
                "device_token": deviceToken,
              }));

      // log("${response.data}", name: 'Before registerAPI');
      log(response.realUri.path);
      if (response.statusCode == 200) {
        return RegistrationModel.fromJson(response.data);
      } else {
        log("Response data rather than 200");
        return RegistrationModel(
            status: false, message: "Something went wrong", data: null);
      }
    } catch (e) {
      log("$e");
      // log("Api call exception");
      return RegistrationModel(
          status: false, message: "Something went wrong", data: null);
    }
  }

  // Listner Display API

  static Future<ListnerDisplayModel> getListnerData() async {
    try {
      var response = await dio
          .get(APIConstants.API_BASE_URL + APIConstants.LISTNER_DISPLAY_API);

      if (response.statusCode == 200) {
        // log("${response.data}");
        return ListnerDisplayModel.fromJson(response.data);
      } else {
        // log("Response data rather than 200");
        return ListnerDisplayModel(
            status: false, message: "Something went wrong", data: null);
      }
    } catch (e) {
      log("$e");
      // log("Api call exception");
      return ListnerDisplayModel(
          status: false, message: "Something went wrong", data: null);
    }
  }

  // Generate 6 digit unique code

  static Future<dynamic> get6digitOrderId(int amount) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.RAZOR_PAY_ORDERID,
          data: {
            "amount": amount,
          });
      if (response.statusCode == 200) {
        return RazorPayOrderIdModel.fromJson(response.data);
      } else {
        log("Response data rather than 200");
        return {
          "status": "false",
          "message": "Something went wrong",
          "data": null
        };
      }
    } catch (e) {
      //  log("$e");
      log("Api call exception");
      return {
        "status": "false",
        "message": "Something went wrong",
        "data": null
      };
    }
  }

  // Generate 6 digit unique code

  static Future<dynamic> getBusyOnline(
      String? onlineStatus, String? toUserId) async {
    try {
      var response = await dio
          .post(APIConstants.API_BASE_URL + APIConstants.ONLINE_API, data: {
        "user_id":
            // '663',
            toUserId,
        "busy_status": onlineStatus,
      });
      if (response.statusCode == 200) {
        log("${response.data}, name: 'getBusyOnline");
        return BusyOnlineModel.fromJson(response.data);
      } else {
        log("Response data rather than 200");
        return {
          "status": "false",
          "message": "Something went wrong",
          "data": null
        };
      }
    } catch (e) {
      return {
        "status": "false",
        "message": "Something went wrong",
        "data": null
      };
    }
  }

  // Wallet Fetching  // Add Money Into Wallet

  static Future<dynamic> myWalletAmount() async {
    String userId = SharedPreference.getValue(PrefConstants.MERA_USER_ID);

    try {
      var response = await dio.post(
        APIConstants.API_BASE_URL + APIConstants.ADDMONEY_INTO_WALLET + userId,
      );
      if (response.statusCode == 200) {
        return MyWalletModel.fromJson(response.data);
      } else {
        return {
          "status": "false",
          "message": "Something went wrong",
          "data": null
        };
      }
    } catch (e) {
      return {
        "status": "false",
        "message": "Something went wrong",
        "data": null
      };
    }
  }

  Future<HelpersListModel> getHelpersList(Map apiParams) async {
    try {
      var response = await dio.get(
        APIConstants.API_BASE_URL + APIConstants.getHelpersList,
      );

      var data = HelpersListModel.fromJson(response.data);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  static Future getAgoraTokens() async {
    try {
      var response =
          await dio.get(APIConstants.API_BASE_URL + APIConstants.createToken);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<RatingModel?> getListnerRating(String userId) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.getListnerRating,
          // data: apiParams,
          data: FormData.fromMap({
            "user_id": userId,
          }));

      if (response.statusCode == 200) {
        var data = RatingModel.fromJson(response.data);
        return data;
      } else {}
    } catch (e) {
      //  log("$e");
    }
    return null;
  }

  static Future<ListnerDisplayModel?> searchListener(
      {required String searchTerm}) async {
    try {
      Response response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.searchApiUrl,
              data: FormData.fromMap({
                "search_keywords": searchTerm,
              }));
      if (response.statusCode == 200) {
        ListnerDisplayModel data = ListnerDisplayModel.fromJson({
          "status": response.data["status"],
          "message": "Successful",
          "data": response.data["search_result"]
        });

        return data;
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  static Future<String?> getWalletAmount(String userId) async {
    try {
      var response = await dio.get(
          APIConstants.API_BASE_URL + APIConstants.walletAmountApiUrl + userId);
      // "${APIConstants.API_BASE_URL}${APIConstants.walletAmountApiUrl}/$userId");
      if (response.statusCode == 200) {
        return response.data["wallet_amount"][0]["wallet_amount"].toString();
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  // Show Transaction History

  static Future<ShowTransactionModel?> getTransactionHistory(
      String userId) async {
    try {
      // ignore: prefer_interpolation_to_compose_strings
      var response = await dio.get(APIConstants.API_BASE_URL +
          APIConstants.showTransactionHistory_API +
          userId);
      if (response.statusCode == 200) {
        return ShowTransactionModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  static Future<AddMoneyIntoWalletModel?> addMoneyintoWallet(
      {required String userId,
      required String mobileNumber,
      required String paymentId,
      required String orderId,
      required String signatureId,
      required String amount}) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.walletStoreApiUrl,
          data: FormData.fromMap({
            "user_id": userId,
            "mobile_no": mobileNumber,
            "payment_id": paymentId,
            "order_id": orderId,
            "signatre_id": signatureId,
            "cr_amount": amount,
          }));
      if (response.statusCode == 200) {
        return AddMoneyIntoWalletModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  static Future<DeleteModel?> getDeleteAccount(String userId) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.DELETE_API,
              data: FormData.fromMap({
                "user_id": userId,
              }));

      if (response.statusCode == 200) {
        var data = DeleteModel.fromJson(response.data);
        return data;
      } else {
        log("Response data rather than 200");
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
    return null;
  }

  // Add Nickname in Listner Profile

  static Future<NickNameModel?> getNickName(
      String fromId, String userId, String nickName) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.NICKNAME_API,
              // data: apiParams,
              data: FormData.fromMap({
                "from_id": fromId,
                "to_id": userId,
                "nickname": nickName,
              }));

      if (response.statusCode == 200) {
        var data = NickNameModel.fromJson(response.data);
        return data;
      } else {
        log("Response data rather than 200");
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
    return null;
  }

  static Future<NickNameGETModel> displayNickName() async {
    String userId = SharedPreference.getValue(PrefConstants.MERA_USER_ID);

    try {
      var response = await dio.get(
        APIConstants.API_BASE_URL + APIConstants.DISPLAY_NICKNAME_API + userId,
      );
      if (response.statusCode == 200) {
        return NickNameGETModel.fromJson(response.data);
      } else {
        log("Response data rather than 200");
        return NickNameGETModel(
            status: false, message: "Something went wrong", data: null);
      }
    } catch (e) {
      log('$e');
      return NickNameGETModel(
          status: false, message: "Something went wrong", data: null);
    }
  }

  // Get Notification

  static Future<ChatNotificationModel> getNotification() async {
    String userId = SharedPreference.getValue(PrefConstants.MERA_USER_ID);

    try {
      var response = await dio.get(
        APIConstants.API_BASE_URL + APIConstants.CHAT_NOTIFY_API + userId,
      );
      if (response.statusCode == 200) {
        return ChatNotificationModel.fromJson(response.data);
      } else {
        return ChatNotificationModel(
            status: false,
            message: "Something went wrong",
            allNotifications: null);
      }
    } catch (e) {
      log('$e');
      return ChatNotificationModel(
          status: false,
          message: "Something went wrong",
          allNotifications: null);
    }
  }

  // Read Notifications

  static Future<dynamic> readNotificationApi() async {
    try {
      Response response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.CHAT_READ_NOTIFY_API,
          data: FormData.fromMap({
            "user_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID)
          }));
      if (response.statusCode == 200) {
        // log("${response.data}");
        // return ReadNotificationModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
  }

  // Charge Display Model

  static Future<dynamic> chargeWalletDeductionApi(String fromId, String toId,
      String duration, String mode, String sessionId) async {
    try {
      Response response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.ChargeWalletDeductionApi,
          data: FormData.fromMap({
            "from_id": fromId,
            "to_id": toId,
            "duration": duration,
            "mode": mode,
            "session_id": sessionId
          }));
      if (response.statusCode == 200) {
        return ChargeWalletModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
  }

  // Withdrawal API

  static Future<dynamic> withdrawalWalletApi(String upiId, String amount,
      String accountNo, String ifscCode, String bankName) async {
    try {
      String userId = SharedPreference.getValue(PrefConstants.MERA_USER_ID);
      Response response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.WITHDRAWALWalletApi,
          data: FormData.fromMap({
            "user_id": userId,
            "upi_id": upiId,
            "amount": amount,
            "account_no": accountNo,
            "ifsc_code": ifscCode,
            "bank_name": bankName,
          }));
      if (response.statusCode == 200) {
        return WithdrawalModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
  }

  static Future<ToggleButtonONOFFModel?> toggleButtonONOFFModel(
    String userId,
  ) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.showToggleListnerONOFF_API,
          data: FormData.fromMap({"user_id": userId}));
      if (response.statusCode == 200) {
        return ToggleButtonONOFFModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  static Future<ToggleButtonONOFFModel?> makeUserNotBusy() async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.showToggleListnerONOFF_API,
          data: FormData.fromMap({
            "user_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            "busy_status": 'false'
          }));
      if (response.statusCode == 200) {
        return ToggleButtonONOFFModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  // Listner Availability API

  static Future<ListnerAvaiabilityModel?> listnerAvaiabilityModel(
      String selectAvailability) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.listnerAvailability_API,
          data: FormData.fromMap({
            "available_on": selectAvailability,
            "id": SharedPreference.getValue(PrefConstants.MERA_USER_ID)
          }));
      if (response.statusCode == 200) {
        return ListnerAvaiabilityModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  // Bell Icon Notify

  static Future<BellIconNotifyModel?> bellIconNotify(
      String userId, String toId) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.bellIconNotify_API,
          data: FormData.fromMap({
            "from_id": userId,
            "to_id": toId,
          }));
      log(userId);
      log(toId);
      if (response.statusCode == 200) {
        return BellIconNotifyModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  // Report API

  static Future<ReportModel?> reportAPI(
      String userId, String toId, String reason) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.ReportApi,
              data: FormData.fromMap({
                "from_id": userId,
                "to_id": toId,
                "reason": reason,
              }));
      if (response.statusCode == 200) {
        return ReportModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  // FeedBack API

  static Future<FeedBackModel?> feedbackAPI(
      String userId, String toId, String rating, String review) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.FEEDBACK_API,
              data: FormData.fromMap({
                "from_id": userId,
                "to_id": toId,
                "rating": rating,
                "review": review,
              }));
      if (response.statusCode == 200) {
        return FeedBackModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  //Block API

  // FeedBack API

  static Future<BlockUserModel?> blockAPI(String userId) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.block_API,
              data: FormData.fromMap({
                "user_id": userId,
              }));
      if (response.statusCode == 200) {
        //  log(response.data.toString());
        return BlockUserModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  static Future<void> sendNotification({
    String? deviceToken,
    String? senderName,
    String? cId,
    String? cTn,
    String? uid,
  }) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';

    // String toParams = "/topics/$uid";

    final data = {
      "notification": {
        "body": "Call from $senderName",
        "title": "Incoming Call",
        "sound": 'customsound',
        'android_channel_id': 'support1'
        // "default_sound": false
      },
      'android': {
        'notification': {
          'channel_id': 'support1',
          "sound": 'customsound',
          // "default_sound": false
        },
      },
      "priority": "high",
      "data": {
        "name": senderName,
        "channel_id": cId,
        "channel_token": cTn,
        "user_id": uid,
        "to_user_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "sound": 'customsound',
        // "default_sound": false
      },
      "to": deviceToken
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAsl7lYN0:APA91bEBMLw5Pdps-iv5j0zCb6O9m-9-DiJUjylvAwX4lO6FjXZAviKYdu2F6q1hLkd-ek9cridGs5mqkRlPDZT4jXH5L-gh1NjkEReQULbYF-fLWRBrcblNvieYSzxSiUWuUb7aaz5W '
    };
    var url = Uri.parse(postUrl);

    final response = await http.post(url,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      log("sent notification with data: ${response.body}");
      log("true");
    } else {
      log("failed notification with data: ${response.body}");

      log("false");
    }
  }

  // Chat Push Notification

  static Future<void> sendChatNotification({
    String? deviceToken,
    String? senderName,
  }) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';

    final data = {
      "notification": {
        "body": "You have new message from $senderName",
        "title": "Message",
        "sound": 'customsound',
        'android_channel_id': 'support1'
        // "default_sound": false
      },
      'android': {
        'notification': {
          'channel_id': 'support1',
          "sound": 'customsound',
          // "default_sound": false
        },
      },
      "priority": "high",
      "data": {
        "name": senderName,
        // "channel_id": 'support1',
        "to_user_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "sound": 'customsound',
      },
      "to": deviceToken
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAsl7lYN0:APA91bEBMLw5Pdps-iv5j0zCb6O9m-9-DiJUjylvAwX4lO6FjXZAviKYdu2F6q1hLkd-ek9cridGs5mqkRlPDZT4jXH5L-gh1NjkEReQULbYF-fLWRBrcblNvieYSzxSiUWuUb7aaz5W '
    };
    var url = Uri.parse(postUrl);

    final response = await http.post(url,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      log("sent notification with data: ${response.body}");
      log("true");
    } else {
      log("failed notification with data: ${response.body}");

      log("false");
    }
  }

  static Future<AgoraRtcUsersJoinChannelStatsModel> getAgoraChannelInfo(
      String channelName) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    const authCredentials =
        '607073556e974c68a96740fddd914dfc:6e99d44d3c0a47788395fc0b4c8d611d';
    String encoded = stringToBase64.encode(authCredentials);
    final http.Response response = await http.get(
        Uri.parse(
            'https://api.agora.io/dev/v1/channel/user/$agoraAppId/$channelName'),
        headers: <String, String>{
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Basic $encoded'
        });

    if (response.statusCode == 200) {
      log(response.body);
      return agoraRtcUsersJoinChannelStatsModelFromJson(response.body);
    } else {
      log(response.body);

      throw Exception('Failed to get right response.');
    }
  }

  static Future handleRecording(
      Map<String, String> formData, String path) async {
    final http.Response response =
        await http.post(Uri.parse(APIConstants.API_BASE_URL + path),
            headers: <String, String>{
              HttpHeaders.acceptHeader: 'application/json',
            },
            body: formData);

    if (response.statusCode == 200) {
      log(response.body, name: 'start & stop recording');
      return jsonDecode(response.body);
    } else {
      log(response.body);
      throw Exception('Failed to get right response.');
    }
  }

  // User Chat Send Request API

  static Future<SendChatIDModel?> sendChatIDAPI(
      String userId, String listenerId, String chatRoomId) async {
    Map<String, String> formData = {
      "user": userId,
      "listner": listenerId,
      "chatroom": chatRoomId,
    };

    try {
      var response = await http.post(
        Uri.parse('${APIConstants.API_BASE_URL}chats'),
        body: formData,
        headers: <String, String>{
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        log(response.body.toString(), name: 'send chat id');
        return SendChatIDModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  // Chat End API

  static Future<GetChatEndModel?> chatEndAPI(int chatId) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.chatEnd,
              data: FormData.fromMap({
                "chat_id": chatId,
              }));
      log(chatId.toString(), name: 'chat id, chat end api');
      if (response.statusCode == 200) {
        log(response.data.toString());
        return GetChatEndModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return GetChatEndModel(status: false, message: "Something went wrong");
  }

  // Get Chat End API

  static Future<APIGetChatEndModel> getChatIdListnerSideAPI(
      String userId, String usertype) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.getChat,
              data: FormData.fromMap({
                "user_id": userId,
                "user_type": usertype,
              }));
      if (response.statusCode == 200) {
        return APIGetChatEndModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return APIGetChatEndModel(
        status: false, message: "Something went wrong", data: null);
  }

  // User Chat Send Request API

  static Future<UserChatSendRequest?> userChatSendRequestAPI(
      String userId, String toId) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.userChatSendRequest,
          data: FormData.fromMap({
            "from_id": userId,
            "to_id": toId,
          }));
      if (response.statusCode == 200) {
        return UserChatSendRequest.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  // Listner Chat Request
  static Future<ListnerChatRequest?> listnerChatRequestAPI() async {
    try {
      var response = await dio.get(
        APIConstants.API_BASE_URL +
            APIConstants.listnerChatRequest +
            SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      );
      if (response.statusCode == 200) {
        return ListnerChatRequest.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  // Update Chat Request from Listner

  static Future<UpdateChatRequestModel?> updateChatRequestFromListnerAPI(
      int requestId, String status) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.UpdateChatRequest,
          data: FormData.fromMap({
            "request_id": requestId,
            "status": status,
          }));
      if (response.statusCode == 200) {
        return UpdateChatRequestModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  // Get Chat Request
  static Future<GetChatRequestByUserModel?> getChatRequestAPI(
      String requestId) async {
    try {
      var response = await dio.get(APIConstants.API_BASE_URL +
          APIConstants.getChatRequestByUser +
          requestId);
      if (response.statusCode == 200) {
        return GetChatRequestByUserModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  // Get Call Id

  static Future<GetCallIdModel?> getCallID(String userType) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.getCallID,
              data: FormData.fromMap({
                "user_id":
                    SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                "user_type": userType,
              }));
      if (response.statusCode == 200) {
        return GetCallIdModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  // Get Chat Request
  static Future<SupportChatModel?> getSupportChatAPI(String username) async {
    try {
      
      var response =
          await dio.get('https://2ndlife.in/api/get_admin_message/$username');

      // APIConstants.API_BASE_URL +
      //   APIConstants.getChatRequestByUser +
      //   requestId);
      if (response.statusCode == 200) {
        log(response.toString());
        return SupportChatModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }

  //Message REad
  // Get Chat Request
  static Future<SupportChatModel?> getSupportMessageReadAPI(int messageId) async {
    try {
   
      var response =
          await dio.get('https://2ndlife.in/api/get_admin_message/$messageId');

      // APIConstants.API_BASE_URL +
      //   APIConstants.getChatRequestByUser +
      //   requestId);
      if (response.statusCode == 200) {
        log(response.toString());
        return SupportChatModel.fromJson(response.data);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }
}
