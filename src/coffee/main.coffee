$(document).ready ->

  # global loader to show progress
  window.loader = new LoaderWidget()

  # start app
  app = new Euphony()
  app.start()
