class NoteRain

  noteScale: 0.001

  # midiData is acquired from MIDI.Player.data
  constructor: ({midiData, pianoDesign, noteToColor}) ->
    {blackKeyWidth, keyInfo} = pianoDesign

    # the raw midiData uses delta time between events to represent the flow
    # and it's quite unintuitive
    # here we calculates the start and end time of each notebox
    @model = new THREE.Object3D()
    notes = []
    currentTime = 0

    for [{event}, interval] in midiData
      currentTime += interval
      {subtype, noteNumber} = event

      if subtype is 'noteOn'
        # if note is on, record its start time
        notes[noteNumber] = currentTime

      else if subtype is 'noteOff'
        # if note if off, calculate its duration and build the modle
        startTime = notes[noteNumber]
        duration = currentTime - startTime

        length = duration * @noteScale

        x = keyInfo[noteNumber].keyCenterPosX
        y = startTime * @noteScale + (length / 2)
        z = -0.3

        # build model
        color = noteToColor(noteNumber)
        geometry = new THREE.CubeGeometry(blackKeyWidth, length, blackKeyWidth)
        material = new THREE.MeshPhongMaterial
          color: color
          emissive: color
          opacity: 0.7
          transparent: true
        mesh = new THREE.Mesh(geometry, material)
        mesh.position.set(x, y, z)
        @model.add(mesh)

  update: (playerCurrentTime) =>
    @model.position.y = -playerCurrentTime * @noteScale

# export to global
@NoteRain = NoteRain
