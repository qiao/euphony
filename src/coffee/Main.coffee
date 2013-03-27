$(document)
  .on 'selectstart', ->
    false
  .on 'mousewheel', ->
    false
  .on 'dragover', ->
    false
  .on 'dragenter', ->
    false
  .on 'ready', ->

    # global loader to show progress
    window.loader = new LoaderWidget()
    loader.message('Downloading')

    #start app
    window.app = new Euphony()
    app.initMidi ->
      app.initScene()
      app.loadBuiltinPlaylist (playlist) ->
        window.player = new PlayerWidget('#player')
        player.setPlaylist(playlist)
        player.on('pause', app.pause)
        player.on('resume', app.resume)
        player.on('stop', app.stop)
        player.on('play', app.start)
        player.on('progress', app.setProgress)
        player.on 'trackchange', (trackId) ->
          loader.message 'Loading MIDI', ->
            app.loadBuiltinMidi trackId, ->
              loader.stop ->
                player.play()
        player.on 'filedrop', (midiFile) ->
          player.stop()
          loader.message 'Loading MIDI', ->
            app.loadMidiFile midiFile, ->
              loader.stop ->
                player.play()
        app.on('progress', player.displayProgress)

        player.show ->
          if window.location.hash
            player.setTrackFromHash()
          else
            candidates = [3, 5, 6, 7, 10, 11, 12, 13, 14, 16, 19, 30]
            id = Math.floor(Math.random() * candidates.length)
            player.setTrack(candidates[id])

        setTimeout (->
          player.hide()
          player.autoHide()
        ), 5000

        # drag and drop MIDI files to play
        $(document).on 'drop', (event) ->
          event or= window.event
          event.preventDefault()
          event.stopPropagation()

          # jquery wraps the original event
          event = event.originalEvent or event

          files = event.files or event.dataTransfer.files
          file = files[0]

          reader = new FileReader()
          reader.onload = (e) ->
            midiFile = e.target.result
            player.stop()
            loader.message 'Loading MIDI', ->
              app.loadMidiFile midiFile, ->
                loader.stop ->
                  player.play()
          reader.readAsDataURL(file)
