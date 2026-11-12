// Editor fallback declarations; DOME uses its built-in input module at runtime.
class KeyState {
  construct new() {}
  justPressed { false }
}

class Keyboard {
  static [key] { KeyState.new() }
}
