$ ->
  scene = new Scene('#container')

  keyboard = new PianoKeyboard()
  scene.add(keyboard.model)

  scene.animate ->
    keyboard.update()
