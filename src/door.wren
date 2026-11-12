// Button of Signs (that don't shape your future)
// door.wren - Door data structure

class Door {
construct new(id, color, shape, isCorrect) {
_id = id
_color = color
_shape = shape
_isCorrect = isCorrect
}

id { _id }
color { _color }
shape { _shape }
isCorrect { _isCorrect }
}