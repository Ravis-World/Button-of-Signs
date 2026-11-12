// Editor fallback declarations; DOME uses its built-in dome module at runtime.
class Window {
  static title { "" }
  static title=(value) {}
  static width { 960 }
  static height { 720 }
  static integerScale { false }
  static integerScale=(value) {}
  static resize(width, height) {}
}

class Process {
  static exit() {}
}
