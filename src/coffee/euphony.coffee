class Euphony
  constructor: (container)->
    @design = new PianoKeyboardDesign()
    @keyboard = new PianoKeyboard(@design)
    @rain = new NoteRain(@design)

    @scene = new Scene(container)
    @scene.add(@keyboard.model)
    @scene.add(@rain.model)
    @scene.animate =>
      @keyboard.update()

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

  init: (callback) ->
    MIDI.loadPlugin ->
      loader.stop()
      setTimeout(callback, 1000) if callback

  setMidiFile: (midiFile, callback) ->
    # load tracks
    @player.loadFile midiFile, =>
      @rain.setMidiData(@player.data)
      callback?()

  start: =>
    @player.start()

  stop: =>
    @player.stop()

  pause: =>
    @player.pause()

  resume: =>
    @player.resume()

@Euphony = Euphony
