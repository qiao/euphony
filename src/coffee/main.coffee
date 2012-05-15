$ ->
  scene = new Scene('#container')
  scene.animate()

  design = new PianoKeyboardDesign
  width = design.whiteKeyWidth
  height = design.whiteKeyHeight
  length = design.whiteKeyLength
  {Black} = PianoKeyboardDesign.KeyType

  for {keyType, keyCenterPosX} in design.keyInfo
    unless keyType is Black
      pos = new THREE.Vector3(keyCenterPosX, 0, 0)
      key = new PianoKey
        width: width
        height: height
        length: length
        color: 0xffffff
        position: pos
        dip: 0
      scene.add(key.mesh)
