$ ->
  scene = new Scene('#container')

  design = new PianoKeyboardDesign()
  keyboard = new PianoKeyboard(design)
  scene.add(keyboard.model)

  scene.animate ->
    keyboard.update()

  window.keyboard = keyboard

  NOTE_OFF = 128
  NOTE_ON  = 144

  MIDI.loadPlugin ->
    player = MIDI.Player

    player.loadFile MIDIFiles['014-Bach, JS - Minuet in G'], (midifile) ->
      player.start()

      rain = new NoteRain
        midiData: MIDI.Player.data
        pianoDesign: design

      player.setAnimation
        delay: 30
        callback: (data) -> rain.update(data.now * 1000)

      scene.add(rain.model)

    player.addListener (data) ->
      {note, message} = data
      if message is NOTE_ON
        keyboard.press(note)
      else if message is NOTE_OFF
        keyboard.release(note)
