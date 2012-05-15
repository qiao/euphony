$ ->
  scene = new Scene('#container')

  keyboard = new PianoKeyboard()
  scene.add(keyboard.model)

  scene.animate ->
    keyboard.update()

  window.keyboard = keyboard

  NOTE_OFF = 128
  NOTE_ON  = 144

  MIDI.loadPlugin ->
    player = MIDI.Player
    player.loadFile MIDIFiles['014-Bach, JS - Minuet in G'], ->
      player.start()
    player.addListener (data) ->
      {note, message} = data
      if message is NOTE_ON
        keyboard.press(note)
      else if message is NOTE_OFF
        keyboard.release(note)
