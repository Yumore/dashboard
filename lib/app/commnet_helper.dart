import 'dart:convert';

import 'package:flutter_dmzj/app/api.dart';
import 'package:flutter_dmzj/app/config_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CommentHelper {
  static Future<bool> likeComment(int objId, String commentId, int type) async {
    try {
      var result = "";
      var response =
          await http.get(Uri.parse(Api.likeCommentV3(objId, commentId, type)));
      result = response.body;
      var jsonMap = jsonDecode(result);
      if (jsonMap["code"] == 0) {
        //TODO 添加到数据库中
        Fluttertoast.showToast(msg: "点赞成功");
        return true;
      } else {
        Fluttertoast.showToast(msg: "点赞失败");
        return false;
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "点赞出现错误");
      return false;
    }
  }

  static Future<CommnetResult> checkStatus() async {
    try {
      var uid = ConfigHelper.getUserInfo()?.uid ?? "";

      var result = "";
      var response = await http.get(Uri.parse(Api.checkCommentV3(uid)));
      result = response.body;
      var jsonMap = jsonDecode(result);
      if (jsonMap["msg"] == "") {
        return CommnetResult(true, "");
      } else {
        return CommnetResult(false, jsonMap["msg"].toString());
      }
    } catch (e) {
      return CommnetResult(true, "");
    }
  }

  static Future<CommnetResult> addComment(int objId, int type, String content,
      {String toCommentId = "0",
      String originCommentId = "0",
      String toUid = "0"}) async {
    try {
      if (!ConfigHelper.getUserIsLogined() ?? false) {
        //TODO 跳转登录
        return CommnetResult(false, "没有登录");
      }
      var token = ConfigHelper.getUserInfo()?.dmzj_token ?? "";
      var response = await http.post(Uri.parse(Api.addCommentV3(type)), body: {
        "obj_id": objId,
        "to_comment_id": toCommentId,
        "origin_comment_id": originCommentId,
        "to_uid": toUid,
        "sender_terminal": 1,
        "content": content,
        "dmzj_token": token,
        "_debug": 0
      });
      var jsonMap = jsonDecode(response.body);

      if (jsonMap["code"] == 0) {
        return CommnetResult(true, "发表评论失败");
      } else {
        return CommnetResult(false, jsonMap["msg"].toString());
      }
    } catch (e) {
      print(e);
      return CommnetResult(true, "发表评论出现错误");
    }
  }
}

class CommnetResult {
  bool result;
  String msg;
  CommnetResult(this.result, this.msg);
}
