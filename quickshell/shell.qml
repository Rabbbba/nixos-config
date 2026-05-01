import Quickshell
import QtQuick
import "modules"

FloatingWindow {
    color: "#282828"
    width: 400
    height: 200

    Column {
      anchors.centerIn: parent
      spacing: 8
      Clock { }
      System { }
      Audio { }
      Tags { }
    }

}
