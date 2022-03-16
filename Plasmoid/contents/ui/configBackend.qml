import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
  id: page

  property alias cfg_localhostPort: localhostPort.value
  property alias cfg_reconnectDelay: reconnectDelay.value
  
  SpinBox {
    id: localhostPort
    Kirigami.FormData.label: i18n('Localhost port: ')
    from: 1024 // lowest user port
    to: 65535
    textFromValue: function (v) { return v } // remove comma
  }

  SpinBox {
    id: reconnectDelay
    Kirigami.FormData.label: i18n('Reconnect delay: ')
    from: 1
    to: 60
    textFromValue: function (v) { return v + ' second' + (v == 1 ? '' : 's') }
    valueFromText: function (t) { return Math.min(t.replace(/\D/g,''), 60) }
  }

  Item {
    Kirigami.FormData.isSection: false
  }

  Button {
    Kirigami.FormData.label: i18n('See here to configure: ')
    text: "github.com/pipipear/VoiceStatus"
    onClicked: Qt.openUrlExternally("https://github.com/pipipear/VoiceStatus");
  }
}