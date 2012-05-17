$(document).ready ->

  # global loader to show progress
  window.loader = new LoaderWidget()
  loader.message('Loading')

  # start app
  window.app = new Euphony('#canvas')
  app.init ->
    trackNames = Object.keys(MIDIFiles)
    midiFile = MIDIFiles[trackNames[13]]
    app.setMidiFile midiFile, ->

      $('#player')
        .animate {
          left: '0px'
        }, {
          duration: 1000
          easing: 'easeInQuad'
        }


      $('#control-play').toggle (->
        app.play()
        $(this)
          .removeClass('icon-play')
          .addClass('icon-pause')
      ), (->
        app.pause()
        $(this)
          .removeClass('icon-pause')
          .addClass('icon-play')
      )

      $('#control-pause').on 'click', ->
