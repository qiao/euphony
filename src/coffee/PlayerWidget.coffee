class PlayerWidget
  constructor: (container) ->
    @$container = $(container)

    @$controlsContainer  = $('.player-controls', @$container)
    @$playlistContainer  = $('.player-playlist-container', @$container)
    @$progressContainer  = $('.player-progress-container', @$container)
    @$filedragContainer  = $('.player-filedrag', @$container)

    @$progressBar        = $('.player-progress-bar', @$container)
    @$progressText       = $('.player-progress-text', @$container)
    @$playlist           = $('.player-playlist', @$container)

    @$prevBtn  = $('.player-prev', @$container)
    @$nextBtn  = $('.player-next', @$container)
    @$playBtn  = $('.player-play', @$container)
    @$stopBtn  = $('.player-stop', @$container)
    @$pauseBtn = $('.player-pause', @$container)

    @$prevBtn.click  => @onprev()
    @$nextBtn.click  => @onnext()
    @$stopBtn.click  => @stop()
    @$pauseBtn.click => @pause()
    @$playBtn.click =>
      if @current is 'paused' then @resume() else @play()

    @$progressContainer.click (event) =>
      progress = (event.clientX - @$progressContainer.offset().left) / @$progressContainer.width()
      @progressCallback?(progress)

    @$playlist.click (event) =>
      $target = $(event.target)
      if $target.is('li')
        $list = $('li', @$playlist)
        @setTrack($list.index($target))

    @$container.on 'mousewheel', (event) ->
      event.stopPropagation()

    @updateSize()

    $(window).resize(@updateSize)
    $(window).on('hashchange', @setTrackFromHash)

  updateSize: =>
    @$playlistContainer
      .height(
        @$container.innerHeight() -
        @$controlsContainer.outerHeight(true) -
        @$progressContainer.outerHeight(true) -
        @$filedragContainer.outerHeight(true)
      )
      .nanoScroller()

  show: (callback) =>
    @$container
      .animate {
        left: '0px'
      }, {
        duration: 1000
        easing: 'easeInOutCubic'
        complete: callback
      }

  setPlaylist: (@playlist) ->
    @$playlist.html('')
    for trackName in playlist
      @$playlist.append($('<li>').text(trackName))
    @$playlistContainer.nanoScroller()

  on: (eventName, callback) ->
    @["#{eventName}Callback"] = callback

  onplay: =>
    @$playBtn.hide()
    @$pauseBtn.show()
    @playCallback?()

  onpause: =>
    @$pauseBtn.hide()
    @$playBtn.show()
    @pauseCallback?()

  onresume: =>
    @$playBtn.hide()
    @$pauseBtn.show()
    @resumeCallback?()

  onstop: =>
    @$pauseBtn.hide()
    @$playBtn.show()
    @stopCallback?()

  onprev: =>
    return unless @currentTrackId > 0
    @currentTrackId -= 1
    @setTrack(@currentTrackId)

  onnext: =>
    return unless @currentTrackId < @playlist.length - 1
    @currentTrackId += 1
    @setTrack(@currentTrackId)

  ontrackchange: (trackId) =>
    return unless 0 <= trackId < @playlist.length
    @stop()
    @$currentTrack?.removeClass('player-current-track')
    @$currentTrack = @$playlist
      .find("li")
      .eq(trackId)
      .addClass('player-current-track')
    @trackchangeCallback?(trackId)
    @currentTrackId = trackId

  setTrack: (trackId) =>
    window.location.hash = trackId + 1

  setTrackFromHash: =>
    hash = window.location.hash.slice(1)
    @ontrackchange(parseInt(hash, 10) - 1) if hash

  getRandomTrack: =>
    @playlist[Math.floor(Math.random() * @playlist.length)]

  displayProgress: (event) =>
    {current, total} = event
    current = Math.min(current, total)
    progress = current / total
    @$progressBar.width(@$progressContainer.width() * progress)
    curTime = @_formatTime(current)
    totTime = @_formatTime(total)
    @$progressText.text("#{curTime} / #{totTime}")

  _formatTime: (time) ->
    minutes = time / 60 >> 0
    seconds = String(time - (minutes * 60) >> 0)
    if seconds.length is 1
      seconds = "0#{seconds}"
    "#{minutes}:#{seconds}"

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
