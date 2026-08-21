import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

ZegoSendCallInvitationButton actionButton(
bool isVideo,
String receiverId,
String receiverName,
)=> ZegoSendCallInvitationButton(
  iconSize: Size(30, 30),
    buttonSize: Size(40, 40),
    resourceID: "zeo_call",
    invitees: [ZegoUIKitUser(id: receiverId, name: receiverName)],
    isVideoCall: isVideo,
  onPressed: (code, message, errorInvites){},
);