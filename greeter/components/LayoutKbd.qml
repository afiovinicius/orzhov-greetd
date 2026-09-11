import QtQuick
import "../services"

Dropdown {
  id: root

  icon: "../assets/icon-keyboard.svg"

  model: {
    var names = []
    for (var i = 0; i < Keyboards.list.length; i++) {
      names.push(Keyboards.list[i].name)
    }
    return names
  }

  currentIndex: Keyboards.currentIndex

  onActivated: (index) => {
  Keyboards.select(index)
}
}