# The Euphony class provides interfaces to play MIDI files and do 3D visualization.
# The controller and playlist on the left of the screen is not part of it.
class Euphony

  constructor: ->
    @design = new PianoKeyboardDesign()
    @keyboard = new PianoKeyboard(@design)
    @rain = new NoteRain(@design)
    @particles = new NoteParticles(@design)

    @player = MIDI.Player
    @player.addListener (data) =>
      NOTE_OFF = 128
      NOTE_ON  = 144
      {note, message} = data
      if message is NOTE_ON
        @keyboard.press(note)
        @particles.createParticles(note)
      else if message is NOTE_OFF
        @keyboard.release(note)
    @player.setAnimation
      delay: 20
      callback: (data) =>
        {now, end} = data
        @onprogress?(
          current: now
          total: end
        )
        @rain.update(now * 1000)

  initScene: ->
    @scene = new Scene('#canvas')
    @scene.add(@keyboard.model)
    @scene.add(@rain.model)
    @scene.add(@particles.model)
    @scene.animate =>
      @keyboard.update()
      @particles.update()

  initMidi: (callback) ->
    MIDI.loadPlugin ->
      # mute channel 10, which is reserved for percussion instruments only.
      # the channel index is off by one
      MIDI.channels[9].mute = true
      callback?()

  loadBuiltinPlaylist: (callback) ->
    return callback(@playlist) if @playlist
    $.getJSON 'tracks/index.json', (@playlist) =>
      callback(@playlist)

  loadBuiltinMidi: (id, callback) ->
    return unless 0 <= id < @playlist.length

    # try to load the MIDI file from localStorage
    if localStorage?[id]
      return @loadMidiFile(localStorage[id], callback)

    # if the file is not available in the localStorage
    # then issue an AJAX request to get it from remote server
    # and try to save the file into localStorage
    $.ajax
      url: "tracks/#{@playlist[id]}"
      dataType: 'text'
      success: (data) =>
        @loadMidiFile(data, callback)
        try
          localStorage?[id] = data
        catch e
          console?.error('localStorage quota limit reached')

  # load a base64 encoded or binary XML MIDI file
  loadMidiFile: (midiFile, callback) ->
    @player.loadFile midiFile, =>
      @rain.setMidiData(@player.data, callback)

  start: =>
    @player.start()
    @playing = true

  resume: =>
    @player.currentTime += 1e-6 # bugfix for MIDI.js
    @player.resume()
    @playing = true

  stop: =>
    @player.stop()
    @playing = false

  pause: =>
    @player.pause()
    @playing = false

  getEndTime: =>
    @player.endTime

  setCurrentTime: (currentTime) =>
    @player.pause()
    @player.currentTime = currentTime
    @player.resume() if @playing

  setProgress: (progress) =>
    currentTime = @player.endTime * progress
    @setCurrentTime(currentTime)

  on: (eventName, callback) ->
    @["on#{eventName}"] = callback

# exports to global
@Euphony = Euphony
