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
        player.on('setprogress', app.setProgress)
        player.on 'settrack', (trackId) ->
          return unless 0 <= trackId < playlist.length
          loader.message 'Loading MIDI', ->
            app.loadBuiltinMidi trackId, ->
              loader.stop ->
                player.play()
        app.on('progress', player.displayProgress)

        player.show ->
          hash = window.location.hash.slice(1)
          if hash
            player.setTrack(parseInt(hash, 10) - 1)
          else
            candidates = [3, 5, 6, 7, 10, 11, 12, 13, 14, 16, 19, 30]
            id = Math.floor(Math.random() * candidates.length)
            player.setTrack(candidates[id])
