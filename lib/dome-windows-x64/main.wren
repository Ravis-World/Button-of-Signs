import "graphics" for Canvas, Color

class Main {
  construct new() {}
  init() {}
  update() {}
  draw(dt) {
    Canvas.print("DOME Installed Successfully.", 10, 10, Color.new(255, 255, 255))
  }
}

var Game = Main.new()
