enum ServerType { directMessage, group }

class ServerTypeConverter {
  static ServerType convertToServerType(String str) {
    switch (str) {
      case "directMessage":
        return ServerType.directMessage;
      case "group":
        return ServerType.group;

      default:
        return ServerType.directMessage;
    }
  }

  static String convertToInt(ServerType type) {
    switch (type) {
      case ServerType.directMessage:
        return "directMessage";
      case ServerType.group:
        return "group";
      default:
        return "directMesage";
    }
  }
}
