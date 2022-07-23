import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

RowLayout {
  id: channel
  Layout.minimumHeight: parent.height
  property var users: []
  spacing: plasmoid.configuration.userSpacing
  Component.onCompleted: {
    console.log(JSON.stringify(users))
    users.forEach(u => {
      var avatar = Qt.createComponent("avatar.qml")
      avatar.createObject(channel, { source: u.avatar })
    });
  }
}
