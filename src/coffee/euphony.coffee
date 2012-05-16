class Euphony
  constructor: (container)->
    @design = new PianoKeyboardDesign()
    @keyboard = new PianoKeyboard(@design)
    @rain = new NoteRain(@design)

    @scene = new Scene(container)
    @scene.add(@keyboard.model)
    @scene.add(@rain.model)

    @player = MIDI.Player
    @player.addListener (data) =>
      NOTE_OFF = 128
      NOTE_ON  = 144
      {note, message} = data
      if message is NOTE_ON
        @keyboard.press(note)
      else if message is NOTE_OFF
        @keyboard.release(note)
    @player.setAnimation
      delay: 30
      callback: (data) => @rain.update(data.now * 1000)

  play: (midiFile) ->

  start: =>
    @scene.animate =>
      @keyboard.update()

    # initialize MIDI
    MIDI.loadPlugin =>
      loader.stop()

      # load tracks
      trackNames = Object.keys(MIDIFiles)
      @player.loadFile MIDIFiles[trackNames[12]], =>
        @rain.setMidiData(@player.data)
        # start player
        @player.start()

@Euphony = Euphony
