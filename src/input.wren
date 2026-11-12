// Editor fallback declarations; DOME uses its built-in input module at runtime.
class KeyState {
  construct new() {}
  justPressed { false }
}

class Keyboard {
  static [key] { KeyState.new() }
}

class MouseButton {
  construct new() {}
  justPressed { false }
}

class Mouse {
  static x { 0 }
  static y { 0 }
  static [button] { MouseButton.new() }
}
