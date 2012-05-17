class LoaderWidget
  opts:
    color: '#aaaaaa'
    width: 4

  constructor: ->
    $window = $(window)

    @overlay = $('<div>')
      .width($window.width())
      .height($window.height())
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
      .css
        position: 'absolute'
        top: ($window.height() - 200) / 2
        left: ($window.width() - 300) / 2
      .appendTo(@overlay)
    
    @canvas = $('<div>')
      .height(100)
      .appendTo(@box)

    @text = $('<div>')
      .css
        color: '#ddd'
        'font-size': '0.9em'
        cursor: 'default'
      .appendTo(@box)

  message: (msg) =>
    @start() unless @isActive
    @text.html(msg) if msg?

  start: =>
    @overlay.fadeIn()
    if @spin
      @spin.spin(@canvas[0])
    else
      @spin = new Spinner(@opts)
      @spin.spin(@canvas[0])
    @isActive = true
  
  stop: (callback) =>
    @overlay.fadeOut('slow', callback)
    @spin?.stop()
    @isActive = false

@LoaderWidget = LoaderWidget
