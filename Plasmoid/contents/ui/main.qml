import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import QtWebSockets 1.15 // usually not installed by default

Item {
  Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
  Plasmoid.compactRepresentation: RowLayout {
    id: container
    spacing: plasmoid.configuration.channelSpacing

    property var vclist: []

    property bool firstChangeCompleted: false // hacky solution

    property var sortByNick:              plasmoid.configuration.sortByNick
    property var sortByUsername:          plasmoid.configuration.sortByUsername
    property var sortById:                plasmoid.configuration.sortById
    property var serverId:                plasmoid.configuration.serverId
    property var sortDirectionAscending:  plasmoid.configuration.sortDirectionAscending
    property var sortDirectionDescending: plasmoid.configuration.sortDirectionDescending
    property var sortStyleApp:            plasmoid.configuration.sortStyleApp
    property var sortStyleOverlay:        plasmoid.configuration.sortStyleOverlay
    property var localhostPort:           plasmoid.configuration.localhostPort
    property var reconnectDelay:          plasmoid.configuration.reconnectDelay

    onSortByNickChanged:              applyTimer.running = true
    onSortByUsernameChanged:          applyTimer.running = true
    onSortByIdChanged:                applyTimer.running = true
    onServerIdChanged:                applyTimer.running = true
    onSortDirectionAscendingChanged:  applyTimer.running = true
    onSortDirectionDescendingChanged: applyTimer.running = true
    onSortStyleAppChanged:            applyTimer.running = true
    onSortStyleOverlayChanged:        applyTimer.running = true
    onLocalhostPortChanged:           applyTimer.running = true
    
    Timer {
      id: applyTimer
      interval: 10
      running: false
      repeat: false
      property int returnedValue: 0
      onTriggered: {
        if (firstChangeCompleted) {
          socket.active = false
          socket.active = true
          applyTimer.running = false
        } else {
          firstChangeCompleted = true
        }
      }
    }

    Timer {
      id: reconnectTimer
      interval: reconnectDelay * 1000
      running: false
      repeat: false
      property int returnedValue: 0
      onTriggered: {
        socket.active = true
        reconnectTimer.running = false
      }
    }

    WebSocket {
      id: socket
      active: true
      url: `ws://localhost:${localhostPort}/ws`

      onTextMessageReceived: {
        clearChannels()
        var channel = Qt.createComponent("channel.qml")
        var servers = JSON.parse(JSON.parse(message)['voiceChannels'])
        if (!servers || servers.length == 0 || servers[serverId] == null) return
        for (const [key, value] of Object.entries(servers[serverId])) {
          if (!value) continue
          if (sortByNick || sortByUsername) {
            var sortOrder = sortDirectionAscending ? 1 : -1
            if (sortStyleApp) {
              value.sort((a, b) => {
                var aFriendly = sortByNick && a.nick || a.username
                var bFriendly = sortByNick && b.nick || b.username
                if (aFriendly.toLocaleLowerCase() < bFriendly.toLocaleLowerCase()) return -1 * sortOrder
                if (aFriendly.toLocaleLowerCase() > bFriendly.toLocaleLowerCase()) return  1 * sortOrder
                return (a.id - b.id) * sortOrder
              })
            } else if (sortStyleOverlay) {
              value.sort((a, b) => (a.nick || a.username).localeCompare(b.nick || b.username) * sortOrder)
            }
          } else if (sortById && sortDirectionDescending) {
            value.reverse()
          }
          vclist.push(channel.createObject(container, { users: value }))
        }
      }
      onStatusChanged: {
        if (socket.status == WebSocket.Error) {
          console.log(`ws error: ${socket.errorString}`);
        } else if (socket.status == WebSocket.Open) {
          console.log('ws connected');
        } else if (socket.status == WebSocket.Closed) {
          console.log('ws disconnected');
          clearChannels()
          socket.active = false
          reconnectTimer.running = true
        }
        console.log(`ws status: ${socket.status}`);
      }
    }

    function clearChannels() {
      vclist.forEach(c => c.destroy())
      vclist = []
    }
  }
}