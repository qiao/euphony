class NoteRain

  lengthScale: 0.001

  constructor: (@pianoDesign) ->
    @model = new THREE.Object3D()

  # midiData is acquired from MIDI.Player.data
  setMidiData: (midiData, callback) ->
    @clear()
    noteInfos = @_getNoteInfos(midiData)
    @_buildNoteMeshes(noteInfos, callback)

  # clear all existing note rains
  clear: ->
    for child in @model.children.slice(0)
      @model.remove(child)

  # the raw midiData uses delta time between events to represent the flow
  # and it's quite unintuitive
  # here we calculates the start and end time of each notebox
  _getNoteInfos: (midiData) ->
    currentTime = 0
    noteInfos = []
    noteTimes = []

    for [{event}, interval] in midiData
      currentTime += interval
      {subtype, noteNumber, channel} = event

      # In General MIDI, channel 10 is reserved for percussion instruments only.
      # It doesn't make any sense to convert it into piano notes. So just skip it.
      continue if channel is 9 # off by 1

      if subtype is 'noteOn'
        # if note is on, record its start time
        noteTimes[noteNumber] = currentTime

      else if subtype is 'noteOff'
        # if note if off, calculate its duration and build the model
        startTime = noteTimes[noteNumber]
        duration = currentTime - startTime
        noteInfos.push {
          noteNumber: noteNumber
          startTime: startTime
          duration: duration
        }
    noteInfos


  # given a list of note info, build their meshes
  # the callback is called on finishing this task
  _buildNoteMeshes: (noteInfos, callback) ->
    {blackKeyWidth, blackKeyHeight, keyInfo, KeyType, noteToColor} = @pianoDesign
    {Black} = KeyType

    # function to split an array into groups
    splitToGroups = (items, sizeOfEachGroup) ->
      groups = []
      numGroups = Math.ceil(items.length / sizeOfEachGroup)
      start = 0
      for i in [0...numGroups]
        groups[i] = items[start...(start + sizeOfEachGroup)]
        start += sizeOfEachGroup
      groups

    # the sleep tasks will be inserted into the mesh-building procedure
    # in order to not to block the rendering of the browser UI
    sleepTask = (done) ->
      setTimeout (->
        done(null)
      ), 0

    # tasks to build the meshes
    # all the tasks are asynchronous
    tasks = []

    # split the note infos into groups
    # for each group, generate a task that will build the notes' meshes
    SIZE_OF_EACH_GROUP = 100
    groups = splitToGroups(noteInfos, SIZE_OF_EACH_GROUP)
    for group in groups
      # insert an sleep task between every two mesh-building tasks
      tasks.push(sleepTask)

      # insert the mesh-building task
      # note that we are now in a loop. so use of the `do` keyword. it prevents the generated functions
      # to share the final values of the `group` variable.
      tasks.push do (group) =>
        # every task will be an asynchronous function. the `done` callback will be
        # called on finishing the task
        (done) =>
          for noteInfo in group
            {noteNumber, startTime, duration} = noteInfo

            # scale the length of the note
            length = duration * @lengthScale

            # calculate the note's position
            x = keyInfo[noteNumber].keyCenterPosX
            y = startTime * @lengthScale + (length / 2)
            z = -0.2

            # because the black key is higher than the white key,
            # so we have to add an offset onto the note's y coordinate
            if keyInfo[noteNumber].keyType is Black
              y += blackKeyHeight / 2

            color = noteToColor(noteNumber)
            geometry = new THREE.BoxGeometry(blackKeyWidth, length, blackKeyWidth)
            material = new THREE.MeshPhongMaterial
              color: color
              emissive: color
              opacity: 0.7
              transparent: true
            mesh = new THREE.Mesh(geometry, material)
            mesh.position.set(x, y, z)
            @model.add(mesh)
          done(null)

    # use the `async` library to execute the tasks in series
    async.series tasks, ->
      callback?()

  update: (playerCurrentTime) =>
    @model.position.y = -playerCurrentTime * @lengthScale

# export to global
@NoteRain = NoteRain
