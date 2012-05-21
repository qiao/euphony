$(document)
  .on 'selectstart', ->
    false
  .on 'ready', ->

    # global loader to show progress
    window.loader = new LoaderWidget()
    loader.message('Downloading')

    #start app
    window.app = new Euphony()
    app.initScene()
    app.initMidi ->
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
        app.on('progress', player.displayProgress)

        player.show ->
          player.setTrackFromHash()
