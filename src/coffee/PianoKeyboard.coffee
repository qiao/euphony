# design(specification) of piano key
# based on MIDITrail(http://en.sourceforge.jp/projects/miditrail/)
class PianoKeyboardDesign

  KeyType:
    WhiteC : 0
    WhiteD : 1
    WhiteE : 2
    WhiteF : 3
    WhiteG : 4
    WhiteA : 5
    WhiteB : 6
    Black  : 7

  whiteKeyStep          : 0.236
  whiteKeyWidth         : 0.226
  whiteKeyHeight        : 0.22
  whiteKeyLength        : 1.50
  blackKeyWidth         : 0.10
  blackKeyHeight        : 0.24
  blackKeyLength        : 1.00
  blackKeyShiftCDE      : 0.0216
  blackKeyShiftFGAB     : 0.0340
  blackKeyPosY          : 0.10
  blackKeyPosZ          : -0.24
  noteDropPosZ4WhiteKey : 0.25
  noteDropPosZ4BlackKey : 0.75
  whiteKeyColor         : 0xffffff
  blackKeyColor         : 0x111111
  keyDip                : 0.08
  keyUpSpeed            : 0.03
  keyInfo               : [] # an array holding each key's type and position

  # function to convert a note to the corresponding color(synesthesia)
  noteToColor: do ->
    map = MusicTheory.Synesthesia.map('August Aeppli (1940)')
    offset = MIDI.pianoKeyOffset
    (note) ->
      return 0x000000 unless map[note - offset]?
      parseInt(map[note - offset].hex, 16)

  constructor: ->
    @keyInfo[i] = {} for i in [0...128]
    @_initKeyType()
    @_initKeyPos()

  _initKeyType: ->
    {keyInfo, KeyType} = this
    {WhiteC, WhiteD, WhiteE, WhiteF, WhiteG, WhiteA, WhiteB, Black} = KeyType

    for i in [0...10]
      noteNo = i * 12                          #  ________
      keyInfo[noteNo +  0].keyType = WhiteC    # |        |C
      keyInfo[noteNo +  1].keyType = Black     # |----####|
      keyInfo[noteNo +  2].keyType = WhiteD    # |        |D
      keyInfo[noteNo +  3].keyType = Black     # |----####|
      keyInfo[noteNo +  4].keyType = WhiteE    # |________|E
      keyInfo[noteNo +  5].keyType = WhiteF    # |        |F
      keyInfo[noteNo +  6].keyType = Black     # |----####|
      keyInfo[noteNo +  7].keyType = WhiteG    # |        |G
      keyInfo[noteNo +  8].keyType = Black     # |----####|
      keyInfo[noteNo +  9].keyType = WhiteA    # |        |A
      keyInfo[noteNo + 10].keyType = Black     # |----####|
      keyInfo[noteNo + 11].keyType = WhiteB    # |________|B

    noteNo = 120                               #  ________
    keyInfo[noteNo + 0].keyType = WhiteC       # |        |C
    keyInfo[noteNo + 1].keyType = Black        # |----####|
    keyInfo[noteNo + 2].keyType = WhiteD       # |        |D
    keyInfo[noteNo + 3].keyType = Black        # |----####|
    keyInfo[noteNo + 4].keyType = WhiteE       # |________|E
    keyInfo[noteNo + 5].keyType = WhiteF       # |        |F
    keyInfo[noteNo + 6].keyType = Black        # |----####|
    keyInfo[noteNo + 7].keyType = WhiteB       # |________|G <= shape is B
    
  _initKeyPos: ->
    # save references of instance variables
    {KeyType, keyInfo, whiteKeyStep, blackKeyShiftCDE, blackKeyShiftFGAB} = this
    {WhiteC, WhiteD, WhiteE, WhiteF, WhiteG, WhiteA, WhiteB, Black} = KeyType

    noteNo = 0
    prevKeyType = WhiteB
    posX = 0.0
    shift = 0.0

    # position of the first note
    keyInfo[noteNo].keyCenterPosX = posX
    prevKeyType = keyInfo[noteNo].keyType

    # position of the second and subsequent notes
    for noteNo in [1...128]
      if prevKeyType is Black
        if keyInfo[noteNo].keyType is Black
          # it's impossible to have two adjacent black keys
        else
          # place the black key between two white keys
          posX += whiteKeyStep / 2.0
      else # previous key is white
        if keyInfo[noteNo].keyType is Black
          posX += whiteKeyStep / 2.0
        else
          posX += whiteKeyStep
      keyInfo[noteNo].keyCenterPosX = posX
      prevKeyType = keyInfo[noteNo].keyType

    # fix the position of black keys
    prevKeyType = WhiteC

    for noteNo in [0...128]
      if keyInfo[noteNo].keyType is Black

        # get shift amount of black key
        switch prevKeyType
          when WhiteC then shift = -blackKeyShiftCDE
          when WhiteD then shift = +blackKeyShiftCDE
          when WhiteF then shift = -blackKeyShiftFGAB
          when WhiteG then shift = 0.0
          when WhiteA then shift = +blackKeyShiftFGAB
          else             shift = 0.0

        # set the center position of last black key
        if (noteNo == 126)
          shift = 0.0

        # fix the position
        keyInfo[noteNo].keyCenterPosX += shift

      prevKeyType = keyInfo[noteNo].keyType


# model of a single piano key
# usage:
#   key = new PianoKey(desing, note)
#   # key.model is an instance of THREE.Mesh and can be added into scenes
#   key.press()
#   key.release()
#   setInterval((-> key.update()), 1000 / 60)
class PianoKey
  constructor: (design, note) ->
    {
      blackKeyWidth, blackKeyHeight, blackKeyLength, blackKeyColor,
      whiteKeyWidth, whiteKeyHeight, whiteKeyLength, whiteKeyColor,
      blackKeyPosY, blackKeyPosZ, keyDip, keyInfo, keyUpSpeed, KeyType
    } = design
    {Black} = KeyType

    {keyType, keyCenterPosX} = keyInfo[note]

    if keyType is Black
      geometry = new THREE.BoxGeometry(blackKeyWidth, blackKeyHeight, blackKeyLength)
      material = new THREE.MeshPhongMaterial(color: blackKeyColor)
      position = new THREE.Vector3(keyCenterPosX, blackKeyPosY, blackKeyPosZ)
    else
      geometry = new THREE.BoxGeometry(whiteKeyWidth, whiteKeyHeight, whiteKeyLength)
      material = new THREE.MeshPhongMaterial(color: whiteKeyColor, emissive: 0x111111)
      position = new THREE.Vector3(keyCenterPosX, 0, 0)

    # create key mesh
    @model = new THREE.Mesh(geometry, material)
    @model.position.copy(position)

    @keyUpSpeed = keyUpSpeed

    # set original and pressed y coordinate
    @originalY = position.y
    @pressedY = @originalY - keyDip

  press: ->
    @model.position.y = @pressedY
    @isPressed = true

  release: ->
    @isPressed = false

  update: ->
    if @model.position.y < @originalY and !@isPressed
      offset = @originalY - @model.position.y
      @model.position.y += Math.min(offset, @keyUpSpeed)


# model of piano keyboard
# usage:
#   keyboard = new PianoKeyboard(new PianoKeyboardDesign)
#   scene.add(keyboard.model) # scene is an instance of THREE.Scene
#   setInterval(keyboard.update, 1000 / 60) 
#   keyboard.press(30)   # press the key of note 30(G1)
#   keyboard.release(60) # release the key of note 60(C4)
class PianoKeyboard
  constructor: (design, noteToColor) ->
    @model = new THREE.Object3D()
    @keys = []

    # create piano keys
    for note in [0...design.keyInfo.length]
      key = new PianoKey(design, note)
      @keys.push(key)
      if 20 < note < 109 # strip to 88 keys
        @model.add(key.model)

    @model.y -= design.whiteKeyHeight / 2

  press: (note) ->
    @keys[note].press()

  release: (note) ->
    @keys[note].release()

  update: =>
    key.update() for key in @keys


# export to global
@PianoKeyboardDesign = PianoKeyboardDesign
@PianoKeyboard = PianoKeyboard
