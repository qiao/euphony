class PlayerWidget
  constructor: ->
    @container = $('#player')
    @prevBtn = $('#control-prev').click(@prev)
    @playBtn = $('#control-play').toggle(@play, @pause)
    @stopBtn = $('#control-stop').click(@stop)
    @nextBtn = $('#control-next').click(@next)

  init: =>
    @container
      .animate {
        left: '0px'
      }, {
        duration: 1000
        easing: 'easeInOutCubic'
      }

  bind: (eventName, callback) ->
    @["on#{eventName}"] = callback

  play: =>
    @playBtn
      .removeClass('icon-play')
      .addClass('icon-pause')
    @onplay?()

  pause: =>
    @playBtn
      .removeClass('icon-pause')
      .addClass('icon-play')
    @onpause?()

  resume: =>
    @playBtn
      .removeClass('icon-play')
      .addClass('icon-pause')
    @onresume?()

  stop: =>
    @playBtn
      .removeClass('icon-pause')
      .addClass('icon-play')
    @onstop?()

  prev: =>
    @onprev?()

  next: =>
    @onnext?()

@PlayerWidget = PlayerWidget
