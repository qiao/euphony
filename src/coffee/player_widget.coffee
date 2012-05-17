class PlayerWidget
  constructor: ->
    @container = $('#panel')
    @prevBtn   = $('#control-prev').click => @prev()
    @stopBtn   = $('#control-stop').click => @stop()
    @nextBtn   = $('#control-next').click => @next()
    @pauseBtn  = $('#control-pause').click => @pause()
    @playBtn   = $('#control-play').click =>
      if @current is 'paused' then @resume() else @play()

  oninit: =>
    @container
      .animate {
        left: '0px'
      }, {
        duration: 1000
        easing: 'easeInOutCubic'
      }

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
