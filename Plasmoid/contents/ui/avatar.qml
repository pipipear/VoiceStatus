import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Image {
  sourceSize.width: parent.height
  sourceSize.height: parent.height
  fillMode: Image.PreserveAspectFit
  mipmap: plasmoid.configuration.avatarMipmap
}