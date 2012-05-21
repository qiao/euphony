class LoaderWidget
  opts:
    color: '#aaaaaa'
    width: 4

  constructor: ->
    @window = $(window)

    @overlay = $('<div>')
      .width(@window.width())
      .height(@window.height())
      .hide()
      .css
        position: 'absolute'
        top: 0
        left: 0
        'z-index': 10000
        background: 'rgba(0, 0, 0, 0.7)'
        'text-align': 'center'
      .appendTo(document.body)
      .on('selectstart', (-> false))

    @box = $('<div>')
      .width(300)
      .height(200)
      .appendTo(@overlay)
    
    @canvas = $('<div>')
      .height(100)
      .appendTo(@box)

    @text = $('<div>')
      .css
        color: '#ddd'
        'font-size': '12px'
        cursor: 'default'
      .appendTo(@box)

    @onresize()
    @window.resize(@onresize)

  onresize: =>
    [width, height] = [@window.width(), @window.height()]
    @box
      .css
        position: 'absolute'
        top: (height - 200) / 2
        left: (width - 300) / 2
    @overlay
      .width(width)
      .height(height)


  message: (msg, callback) =>
    @text.html(msg) if msg?
    if @isActive
      callback?()
    else
      @start(callback)

  start: (callback) =>
    @overlay.fadeIn =>
      callback?()
    if @spin
      @spin.spin(@canvas[0])
    else
      @spin = new Spinner(@opts)
      @spin.spin(@canvas[0])
    @isActive = true
  
  stop: (callback) =>
    @overlay.fadeOut 'slow', =>
      @spin?.stop()
      @isActive = false
      callback?()

@LoaderWidget = LoaderWidget
