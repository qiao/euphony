$ ->
  # create scene
  scene = new Scene('#container')

  # the keyboard design is used by both the keyboard and rain
  design = new PianoKeyboardDesign()

  # create keyboard
  keyboard = new PianoKeyboard(design)
  scene.add(keyboard.model)

  scene.animate ->
    keyboard.update()

  # place holder for rain
  rain = null

  # initialize MIDI
  MIDI.loadPlugin ->
    player = MIDI.Player

    # synchronize piano keyboard with note events
    NOTE_OFF = 128
    NOTE_ON  = 144
    player.addListener (data) ->
      {note, message} = data
      if message is NOTE_ON
        keyboard.press(note)
      else if message is NOTE_OFF
        keyboard.release(note)

    # load tracks
    trackNames = Object.keys(MIDIFiles)
    player.loadFile MIDIFiles[trackNames[0]], (midifile) ->

      # create rain
      if rain
        scene.remove(rain.model)
      rain = new NoteRain
        midiData: MIDI.Player.data
        pianoDesign: design
      scene.add(rain.model)

      # start player
      player.start()
      player.setAnimation
        delay: 30
        callback: (data) -> rain.update(data.now * 1000)
