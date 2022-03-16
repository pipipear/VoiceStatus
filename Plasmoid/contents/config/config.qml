import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
  ConfigCategory {
    name: i18n("Display")
    icon: "configure"
    source: "configDisplay.qml"
  }
  ConfigCategory {
    name: i18n("Backend")
    icon: "preferences-system-network-server"
    source: "configBackend.qml"
  }
}