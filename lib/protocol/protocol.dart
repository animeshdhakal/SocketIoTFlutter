class Protocol {
  static const int headerSize = 4;
  static const int auth = 1;
  static const int write = 2;
  static const int read = 3;
  static const int ping = 4;
  static const int sync = 5;
  static const int deviceStatus = 60;
  static const int pingInterval = 10000;
}
