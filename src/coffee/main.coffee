$(document).ready ->

  # global loader to show progress
  window.loader = new LoaderWidget()
  loader.message('Loading')

  # start app
  window.app = new Euphony('#container')
  app.init ->
    trackNames = Object.keys(MIDIFiles)
    midiFile = MIDIFiles[trackNames[11]]
    app.setMidiFile midiFile, ->
      console.log 'ready'
