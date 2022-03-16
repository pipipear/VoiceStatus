import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
  id: page

  property alias cfg_sortByNick:              sortByNick.checked
  property alias cfg_sortByUsername:          sortByUsername.checked
  property alias cfg_sortById:                sortById.checked
  property alias cfg_serverId:                serverId.text
  property alias cfg_sortDirectionAscending:  sortDirectionAscending.checked
  property alias cfg_sortDirectionDescending: sortDirectionDescending.checked
  property alias cfg_sortStyleApp:            sortStyleApp.checked
  property alias cfg_sortStyleOverlay:        sortStyleOverlay.checked
  property alias cfg_userSpacing:             userSpacing.value
  property alias cfg_channelSpacing:          channelSpacing.value
  property alias cfg_avatarMipmap:            avatarMipmap.checked

  Item {
    Kirigami.FormData.isSection: false
  }
  
  Column {
    Kirigami.FormData.label: i18n('Sort users by: ')

    ButtonGroup {
      id: sortByGroup
    }

    RadioButton {
      id: sortByNick
      text: i18n('Nickname')
      ButtonGroup.group: sortByGroup
    }
  
    RadioButton {
      id: sortByUsername
      text: i18n('Username')
      ButtonGroup.group: sortByGroup
    }
  
    RadioButton {
      id: sortById
      text: i18n('User ID')
      ButtonGroup.group: sortByGroup
    }
  }

  Item {
    Kirigami.FormData.isSection: false
  }

  TextField {
    Kirigami.FormData.label: i18n('ID of server to display: ')
    id: serverId
  }

  Item {
    Kirigami.FormData.isSection: false
  }

  Column {
    Kirigami.FormData.label: i18n('User sort direction: ')

    ButtonGroup {
      id: sortDirectionGroup
    }
  
    RadioButton {
      id: sortDirectionAscending
      text: i18n('Ascending')
      ButtonGroup.group: sortDirectionGroup
    }
  
    RadioButton {
      id: sortDirectionDescending
      text: i18n('Descending')
      ButtonGroup.group: sortDirectionGroup
    }
  }

  Item {
    Kirigami.FormData.isSection: false
  }

  Column {
    Kirigami.FormData.label: i18n('User sort style: ')

    ButtonGroup {
      id: sortStyleGroup
    }
  
    RadioButton {
      id: sortStyleApp
      text: i18n('Discord app')
      ButtonGroup.group: sortStyleGroup
    }
  
    RadioButton {
      id: sortStyleOverlay
      text: i18n('Discord overlay')
      ButtonGroup.group: sortStyleGroup
    }
  }

  Item {
    Kirigami.FormData.isSection: false
  }
  
  SpinBox {
    id: userSpacing
    Kirigami.FormData.label: i18n('Spacing between users: ')
    textFromValue: function (v) { return v + ' px' } // suffix doesn't work
    valueFromText: function (t) { return Math.min(t.replace(/\D/g,''), 99) } // not perfect
  }

  SpinBox {
    id: channelSpacing
    Kirigami.FormData.label: i18n('Spacing between channels: ')
    textFromValue: function (v) { return v + ' px' }
    valueFromText: function (t) { return Math.min(t.replace(/\D/g,''), 99) }
  }

  Item {
    Kirigami.FormData.isSection: false
  }

  CheckBox {
    id: avatarMipmap
    text: i18n('Avatar mipmap')
  }
}