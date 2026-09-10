import QtQuick

Dropdown {
  id: layoutDropdown
  model: ["br", "us", "es", "fr"]
  currentIndex: 0
  onActivated: {
    console.log("Layout selecionado: " + currentText + " (Requer reiniciar o compositor para aplicar no Cage)")
  }
}