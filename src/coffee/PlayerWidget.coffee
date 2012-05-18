class PlayerWidget
  constructor: (container) ->
    @container = $(container)

    @controlsContainer  = $('.player-controls', @container)
    @playlistContainer  = $('.player-playlist-container', @container)
    @playlist           = $('.player-playlist', @container)

    @playlistContainer
      .height(@container.innerHeight() - @controlsContainer.outerHeight())
      .nanoScroller()

    @prevBtn  = $('.player-prev', @container)
    @nextBtn  = $('.player-next', @container)
    @playBtn  = $('.player-play', @container)
    @stopBtn  = $('.player-stop', @container)
    @pauseBtn = $('.player-pause', @container)

    @prevBtn.click  => @prev()
    @nextBtn.click  => @next()
    @stopBtn.click  => @stop()
    @pauseBtn.click => @pause()
    @playBtn.click =>
      if @current is 'paused' then @resume() else @play()

    @playlist.click (event) =>
      target = $(event.target)
      if target.is('li')
        @changeTrack(target.text())

    @container.on 'mousewheel', (event) ->
      event.stopPropagation()

  oninit: =>
    @container
      .animate {
        left: '0px'
      }, {
        duration: 1000
        easing: 'easeInOutCubic'
      }

  setPlaylist: (playlist) ->
    @playlist.html('')
    for trackName in playlist
      @playlist.append($('<li>').text(trackName))
    @playlistContainer.nanoScroller()

  bind: (eventName, callback) ->
    @["#{eventName}Callback"] = callback

  onplay: =>
    @playBtn.hide()
    @pauseBtn.show()
    @playCallback?()

  onpause: =>
    @pauseBtn.hide()
    @playBtn.show()
    @pauseCallback?()

  onresume: =>
    @playBtn.hide()
    @pauseBtn.show()
    @resumeCallback?()

  onstop: =>
    @pauseBtn.hide()
    @playBtn.show()
    @stopCallback?()

  onprev: =>
    @prevCallback?()

  onnext: =>
    @nextCallback?()

  onchangetrack: (trackName) =>
    @changetrackCallback?(trackName)

  changeTrack: @::onchangetrack
    
    

StateMachine.create
  target: PlayerWidget.prototype
  events: [
    { name: 'init'  , from: 'none'    , to: 'ready'   }
    { name: 'play'  , from: 'ready'   , to: 'playing' }
    { name: 'pause' , from: 'playing' , to: 'paused'  }
    { name: 'resume', from: 'paused'  , to: 'playing' }
    { name: 'stop'  , from: '*'       , to: 'ready'   }
  ]

@PlayerWidget = PlayerWidget
