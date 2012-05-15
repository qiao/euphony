# based on source of MIDITrail
class PianoKeyboardDesign

  @KeyType: KeyType =
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
  blackKeyHeight        : 0.32
  blackKeyLength        : 1.00
  blackKeyShiftCDE      : 0.0216
  blackKeyShiftFGAB     : 0.0340
  noteDropPosZ4WhiteKey : 0.25
  noteDropPosZ4BlackKey : 0.75
  whiteKeyColor         : 0xffffff
  blackKeyColor         : 0x111111
  keyDip                : 0.07
  keyUpSpeed            : 0.03
  keyInfo               : [] # an array holding each key's type and position

  constructor: ->
    @keyInfo[i] = {} for i in [0...128]
    @_initKeyType()
    @_initKeyPos()

  _initKeyType: ->
    {keyInfo} = this
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
    {keyInfo, whiteKeyStep, blackKeyShiftCDE, blackKeyShiftFGAB} = this
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


class PianoKey
  constructor: ({@design, keyType, position}) ->
    if keyType is PianoKeyboardDesign.KeyType.Black
      width  = @design.blackKeyWidth
      height = @design.blackKeyHeight
      length = @design.blackKeyLength
      color  = @design.blackKeyColor
    else
      width  = @design.whiteKeyWidth
      height = @design.whiteKeyHeight
      length = @design.whiteKeyLength
      color  = @design.whiteKeyColor

    geometry = new THREE.CubeGeometry(width, height, length)
    material = new THREE.MeshLambertMaterial(color: color)
    @mesh = new THREE.Mesh(geometry, material)
    @mesh.position.copy(position)

    @originalY = position.y
    @pressedY = @originalY - @design.keyDip

  press: ->
    @mesh.position.y = @pressedY
    @isPressed = true

  release: ->
    @isPressed = false

  update: ->
    if @mesh.position.y < @originalY and !@isPressed
      offset = @originalY - @mesh.position.y
      @mesh.position.y += Math.min(offset, @design.keyUpSpeed)


class PianoKeyboard
  constructor: ->
    design = new PianoKeyboardDesign
    {Black} = PianoKeyboardDesign.KeyType

    model = new THREE.Object3D()
    keys = []
    blackKeyY = (design.blackKeyHeight - design.whiteKeyHeight) / 2 + 0.001
    blackKeyZ = (design.blackKeyLength - design.whiteKeyLength) / 2 + 0.001

    for {keyType, keyCenterPosX} in design.keyInfo
      if keyType is Black
        pos = new THREE.Vector3(keyCenterPosX, blackKeyY, blackKeyZ)
      else
        pos = new THREE.Vector3(keyCenterPosX, 0, 0)
      key = new PianoKey
        design: design
        keyType: keyType
        position: pos
      keys.push(key)
      model.add(key.mesh)

    @keys  = keys
    @model = model

  press: (note) ->
    @keys[note].press()

  release: (note) ->
    @keys[note].release()

  update: =>
    key.update() for key in @keys

@PianoKeyboard = PianoKeyboard
