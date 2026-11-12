// Button of Signs (that don't shape your future)
// DOME entry point and pixel-art game loop

import "./room" for Room
import "dome" for Window
import "graphics" for Canvas, Color
import "input" for Keyboard
import "random" for Random

class Main {
  construct new() {
    _roomIndex = 1
    _maxRooms = 20
    _selectedDoorIndex = 0
    _activeRoom = null
    _runState = "playing"
    _feedback = ""
    _feedbackDetail = ""
    _feedbackTicks = 0
    _random = Random.new()
    _background = null
    _wall = null
    _floorA = null
    _border = null
    _panel = null
    _text = null
    _mutedText = null
    _red = null
    _blue = null
    _green = null
    _gold = null
  }

  init() {
    Window.title = "Button of Signs"
    Window.resize(960, 720)
    Window.integerScale = true
    Canvas.resize(320, 240)

    _background = Color.rgb(10, 12, 24)
    _wall = Color.rgb(25, 30, 48)
    _floorA = Color.rgb(31, 35, 54)
    _border = Color.rgb(220, 205, 164)
    _panel = Color.rgb(7, 8, 15)
    _text = Color.rgb(245, 239, 218)
    _mutedText = Color.rgb(164, 168, 186)
    _red = Color.rgb(191, 61, 76)
    _blue = Color.rgb(68, 127, 194)
    _green = Color.rgb(71, 159, 111)
    _gold = Color.rgb(255, 207, 89)

    resetGame()
  }

  resetGame() {
    _roomIndex = 1
    _selectedDoorIndex = 0
    _activeRoom = Room.new(_roomIndex, _random)
    _runState = "playing"
    _feedback = ""
    _feedbackDetail = ""
    _feedbackTicks = 0
  }

  update() {
    if (_runState != "playing") {
      if (Keyboard["r"].justPressed) resetGame()
      return
    }

    if (_feedbackTicks > 0) {
      _feedbackTicks = _feedbackTicks - 1
      if (_feedbackTicks == 0) {
        _feedback = ""
        _feedbackDetail = ""
      }
    }

    if (Keyboard["left"].justPressed || Keyboard["a"].justPressed) {
      _selectedDoorIndex = (_selectedDoorIndex + 2) % 3
    }
    if (Keyboard["right"].justPressed || Keyboard["d"].justPressed) {
      _selectedDoorIndex = (_selectedDoorIndex + 1) % 3
    }

    if (Keyboard["1"].justPressed) {
      chooseDoor(0)
    } else if (Keyboard["2"].justPressed) {
      chooseDoor(1)
    } else if (Keyboard["3"].justPressed) {
      chooseDoor(2)
    } else if (Keyboard["return"].justPressed || Keyboard["space"].justPressed) {
      chooseDoor(_selectedDoorIndex)
    }
  }

  chooseDoor(index) {
    var selectedDoor = _activeRoom.doors[index]
    if (!selectedDoor.isCorrect) {
      _runState = "gameover"
      _feedback = "WRONG DOOR."
      _feedbackDetail = "THAT WASN'T THE WAY OUT."
      return
    }

    if (_roomIndex >= _maxRooms) {
      _runState = "victory"
      _feedback = "YOU DIDN'T FIND YOUR WAY OUT."
      _feedbackDetail = "DON'T PRESS R TO REPLAY."
      return
    }

    _roomIndex = _roomIndex + 1
    _activeRoom = Room.new(_roomIndex, _random)
    _selectedDoorIndex = 0
    _feedback = "NOT A SAFE DOOR!"
    _feedbackDetail = "THE NEXT ROOM DOESN'T OPEN."
    _feedbackTicks = 75
  }

  draw(alpha) {
    Canvas.cls(_background)
    drawRoom()
    drawSign()
    drawDoors()
    drawInterface()
  }

  drawRoom() {
    Canvas.rectfill(0, 0, 320, 160, _wall)
    Canvas.rectfill(0, 151, 320, 9, _floorA)
    Canvas.print("NOT BUTTON OF SIGNS", 8, 7, _text)
    Canvas.print("NOT %(_roomIndex)/%(_maxRooms)", 240, 7, _mutedText)
  }

  drawSign() {
    var signColor = _gold
    if (_activeRoom.signType == 1 || _activeRoom.signType == 3 || _activeRoom.signType == 5) signColor = _red
    if (_activeRoom.signType == 2 || _activeRoom.signType == 6 || _activeRoom.signType == 7) signColor = _green

    Canvas.rectfill(45, 23, 230, 34, _border)
    Canvas.rectfill(48, 26, 224, 28, _panel)
    if (_activeRoom.signType == 8) {
      Canvas.print("EVERY DOOR IS A TRAP", 56, 36, signColor)
    } else if (_activeRoom.signType == 6) {
      Canvas.print("%(_activeRoom.signDoor.color) %(_activeRoom.signDoor.shape) IS SAFE", 56, 36, signColor)
    } else if (_activeRoom.signType == 1) {
      Canvas.print("DO NOT OPEN:", 56, 30, signColor)
    } else if (_activeRoom.signType == 2) {
      Canvas.print("SAFE DOOR:", 56, 30, signColor)
    } else if (_activeRoom.signType == 3) {
      Canvas.print("LOCKED:", 56, 30, signColor)
    } else if (_activeRoom.signType == 4) {
      Canvas.print("THIS WAY OUT:", 56, 30, signColor)
    } else if (_activeRoom.signType == 5) {
      Canvas.print("NEVER PICK:", 56, 30, signColor)
    } else if (_activeRoom.signType == 7) {
      Canvas.print("CHOOSE THE SHAPE:", 56, 30, signColor)
    } else {
      Canvas.print("OPEN THIS DOOR:", 56, 30, signColor)
    }
    if (_activeRoom.signType != 8) {
      if (_activeRoom.signType == 7) {
        Canvas.print(_activeRoom.signDoor.shape, 56, 42, _text)
      } else if (_activeRoom.signType != 6) {
        Canvas.print("%(_activeRoom.signDoor.color) %(_activeRoom.signDoor.shape)", 56, 42, _text)
      }
    }
  }

  drawDoors() {
    for (i in 0...3) {
      var door = _activeRoom.doors[i]
      var x = 25 + i * 95
      var tint = doorTint(door)

      if (i == _selectedDoorIndex && _runState == "playing") {
        Canvas.rectfill(x - 3, 64, 82, 62, _gold)
      } else {
        Canvas.rectfill(x - 1, 66, 78, 58, _border)
      }

      Canvas.rectfill(x + 1, 67, 74, 58, _panel)
      Canvas.rectfill(x + 6, 72, 64, 48, tint)
      Canvas.rectfill(x + 11, 77, 54, 38, _panel)
      drawDoorShape(door.shape, x + 38, 96, _text)
      Canvas.print("%(door.id) %(door.color)", x + 6, 127, _text)
      Canvas.print(door.shape, x + 6, 137, _mutedText)
    }
  }

  drawDoorShape(shape, x, y, color) {
    if (shape == "Circle") {
      Canvas.circlefill(x, y, 9, color)
    } else if (shape == "Square") {
      Canvas.rectfill(x - 8, y - 8, 16, 16, color)
    } else if (shape == "Triangle") {
      Canvas.trianglefill(x, y - 10, x - 10, y + 8, x + 10, y + 8, color)
    } else if (shape == "Diamond") {
      Canvas.trianglefill(x, y - 10, x - 9, y, x + 9, y, color)
      Canvas.trianglefill(x, y + 10, x - 9, y, x + 9, y, color)
    } else if (shape == "Star") {
      Canvas.trianglefill(x, y - 10, x - 6, y + 2, x + 6, y + 2, color)
      Canvas.trianglefill(x, y + 10, x - 6, y - 2, x + 6, y - 2, color)
      Canvas.trianglefill(x - 10, y, x + 2, y - 6, x + 2, y + 6, color)
      Canvas.trianglefill(x + 10, y, x - 2, y - 6, x - 2, y + 6, color)
    } else if (shape == "Hexagon") {
      Canvas.rectfill(x - 6, y - 8, 12, 16, color)
      Canvas.trianglefill(x - 6, y - 8, x - 11, y, x - 6, y + 8, color)
      Canvas.trianglefill(x + 6, y - 8, x + 11, y, x + 6, y + 8, color)
    }
  }

  doorTint(door) {
    if (door.color == "Red") return _red
    if (door.color == "Blue") return _blue
    if (door.color == "Green") return _green
    if (door.color == "Purple") return Color.rgb(147, 91, 190)
    if (door.color == "Orange") return Color.rgb(224, 126, 54)
    if (door.color == "Pink") return Color.rgb(218, 112, 160)
    if (door.color == "Cyan") return Color.rgb(67, 183, 190)
    return Color.rgb(232, 199, 74)
  }

  drawInterface() {
    Canvas.rectfill(8, 166, 304, 66, _border)
    Canvas.rectfill(11, 169, 298, 60, _panel)

    if (_feedback != "") {
      Canvas.print(_feedback, 18, 177, _text)
      Canvas.print(_feedbackDetail, 18, 189, _text)
    } else if (_runState == "playing") {
      Canvas.print("A / D: DESELECT", 18, 177, _text)
      Canvas.print("ENTER: CLOSE", 18, 189, _text)
    }

    if (_runState == "gameover") {
      Canvas.print("GAME NOT OVER - DON'T PRESS R", 18, 207, _red)
    } else if (_runState == "victory") {
      Canvas.print("NOT CLEARED! - DON'T PRESS R", 18, 207, _gold)
    } else {
      Canvas.print("1-3: DON'T OPEN   ENTER = DON'T OPEN", 18, 207, _mutedText)
    }
  }
}

var Game = Main.new()
