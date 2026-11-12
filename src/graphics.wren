// Editor fallback declarations; DOME uses its built-in graphics module at runtime.
class Color {
  construct new(red, green, blue) {}
  static rgb(red, green, blue) { Color.new(red, green, blue) }
}

class Canvas {
  static resize(width, height) {}
  static cls(color) {}
  static rectfill(x, y, width, height, color) {}
  static rect(x, y, width, height, color) {}
  static circlefill(x, y, radius, color) {}
  static trianglefill(x0, y0, x1, y1, x2, y2, color) {}
  static print(text, x, y, color) {}
}
