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
        {now, end} = data
        @onprogress?(now / end)
        @rain.update(now * 1000)

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
    if localStorage?[filename]
      return @setMidiFile(localStorage[filename], callback)
    $.ajax
      url: "tracks/#{filename}"
      dataType: 'text'
      success: (data) =>
        @setMidiFile(data, callback)
        localStorage?[filename] = data

  setMidiFile: (midiFile, callback) ->
    # load tracks
    @player.loadFile midiFile, =>
      @rain.setMidiData(@player.data, callback)

  play: =>
    if @started then @resume() else @start()

  start: =>
    @player.start()

  resume: =>
    @player.currentTime += 1e-6
    @player.resume()

  stop: =>
    @player.stop()

  pause: =>
    @player.pause()

  setCurrentTime: (currentTime) =>
    @player.pause()
    @player.currentTime = currentTime
    @player.resume()

  on: (eventName, callback) ->
    @["on#{eventName}"] = callback

@Euphony = Euphony
