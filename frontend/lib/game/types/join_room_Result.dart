enum JoinRoomResult { success, invalidRoom }

JoinRoomResult parseJoinRoomResult(String response) {
  if (response == 'Success') {
    return JoinRoomResult.success;
  }
  return JoinRoomResult.invalidRoom;
}
