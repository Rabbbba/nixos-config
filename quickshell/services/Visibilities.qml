pragma Singleton
import QtQuick

QtObject {
  id: root

  property string current: ""

  function toggle(name) {
    if(current === name) current = "";
    else current = name;
  }
  function close() {
    current = "";
  }
}
