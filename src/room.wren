// Button of Signs (that don't shape your future)
// Room layouts, door choices, and deceptive sign logic

import "./door" for Door

class Room {
  construct new(roomNum, random) {
    _roomNum = roomNum
    _random = random
    _doors = []
    generate()
  }

  doors { _doors }
  signDoor { _signDoor }
  signType { _signType }

  generate() {
    var colors = ["Red", "Blue", "Green", "Purple", "Orange", "Pink", "Cyan", "Yellow"]
    var shapes = ["Circle", "Square", "Triangle", "Diamond", "Star", "Hexagon"]
    _random.shuffle(colors)
    var shapeOffset = (_roomNum * 2) % shapes.count
    _signType = _random.int(9)
    var signIdx = _random.int(3)
    var signShape = shapes[(shapeOffset + signIdx) % shapes.count]

    for (i in 0...3) {
      var color = colors[i]
      var shape = shapes[(shapeOffset + i) % shapes.count]
      var isCorrect = i != signIdx
      if (_signType == 1 || _signType == 3 || _signType == 5) {
        isCorrect = i == signIdx
      } else if (_signType == 7) {
        isCorrect = shape != signShape
      } else if (_signType == 8) {
        isCorrect = true
      }
      _doors.add(Door.new(i + 1, color, shape, isCorrect))
    }

    _signDoor = _doors[signIdx]
  }

  getSignPrompt() {
    if (_signType == 1) {
      return "DO NOT OPEN: %(_signDoor.color) %(_signDoor.shape)"
    } else if (_signType == 2) {
      return "SAFE DOOR: %(_signDoor.color) %(_signDoor.shape)"
    } else if (_signType == 3) {
      return "LOCKED: %(_signDoor.color) %(_signDoor.shape)"
    } else if (_signType == 4) {
      return "THIS WAY OUT: %(_signDoor.color) %(_signDoor.shape)"
    } else if (_signType == 5) {
      return "NEVER PICK: %(_signDoor.color) %(_signDoor.shape)"
    } else if (_signType == 6) {
      return "%(_signDoor.color) %(_signDoor.shape) IS SAFE"
    } else if (_signType == 7) {
      return "CHOOSE THE %(_signDoor.shape)"
    } else if (_signType == 8) {
      return "EVERY DOOR IS A TRAP"
    } else {
      return "OPEN THIS DOOR: %(_signDoor.color) %(_signDoor.shape)"
    }
  }
}
