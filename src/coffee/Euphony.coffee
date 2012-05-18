class Euphony
  constructor: ->
    @design = new PianoKeyboardDesign()
    @keyboard = new PianoKeyboard(@design)
    @rain = new NoteRain(@design)

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
      delay: 20
      callback: (data) =>
        if @player.playing
          @rain.update(data.now * 1000)

  initScene: ->
    @scene = new Scene('#canvas')
    @scene.add(@keyboard.model)
    @scene.add(@rain.model)
    @scene.animate =>
      @keyboard.update()

  initMidi: (callback) ->
    MIDI.loadPlugin(callback)

  getBuiltinMidiIndex: (callback) ->
    return callback(@midiIndex) if @midiIndex
    $.getJSON 'tracks/index.json', (index) =>
      @midiIndex = index
      callback(@midiIndex)

  setBuiltinMidi: (filename, callback) ->
    if localStorage[filename]
      return @setMidiFile(localStorage[filename], callback)
    loader.start =>
      DOMLoader.sendRequest
        url: "tracks/#{filename}"
        progress: (event) ->
          #loader.message('Loading MIDI File ' + Math.round(event.loaded / event.total * 100) + '%')
          loader.message('Loading MIDI File')
        callback: (response) =>
          loader.stop()
          midiData = response.responseText
          @setMidiFile(response.responseText,callback)
          localStorage[filename] = midiData

  setMidiFile: (midiFile, callback) ->
    # load tracks
    @player.loadFile midiFile, =>
      loader.stop()
      @rain.setMidiData(@player.data, callback)

  play: =>
    if @started then @resume() else @start()

  start: =>
    @player.start()

  resume: =>
    @player.start()

  stop: =>
    @player.stop()

  pause: =>
    @player.pause()

@Euphony = Euphony
