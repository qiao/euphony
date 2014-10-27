class NoteParticles

  count: 30
  size: 0.2
  life: 10

  constructor: (@pianoDesign) ->
    {noteToColor, keyInfo} = pianoDesign

    @model = new THREE.Object3D()
    @materials = []

    for note in [0...keyInfo.length]
      color = noteToColor(note)
      @materials[note] = new THREE.PointCloudMaterial
        size: @size
        map: @_generateTexture(color)
        blending: THREE.AdditiveBlending
        transparent: true
        depthWrite: false
        color: color

  _generateTexture: (hexColor) ->
    width = 32
    height = 32

    canvas = document.createElement('canvas')
    canvas.width = width
    canvas.height = height

    {width, height} = canvas

    context = canvas.getContext('2d')
    gradient = context.createRadialGradient(
      width / 2, height / 2, 0,
      width / 2, height / 2, width / 2
    )
    gradient.addColorStop(0, (new THREE.Color(hexColor)).getStyle())
    gradient.addColorStop(1, 'rgba(0, 0, 0, 0)')

    context.fillStyle = gradient
    context.fillRect(0, 0, width, height)

    texture = new THREE.Texture(
      canvas,
      new THREE.UVMapping(),
      THREE.ClampToEdgeWrapping,
      THREE.ClampToEdgeWrapping,
      THREE.NearestFilter,
      THREE.LinearMipMapLinearFilter
    )
    texture.needsUpdate = true
    texture

  update: =>
    for particleSystem in @model.children.slice(0)
      if particleSystem.age++ > @life
        @model.remove(particleSystem)
      else
        for particle in particleSystem.geometry.vertices
          particle.add(particle.velocity)
        particleSystem.geometry.verticesNeedUpdate = true

  createParticles: (note) =>
    {keyInfo, KeyType} = @pianoDesign
    {Black} = KeyType

    {keyCenterPosX, keyType} = keyInfo[note]

    posX = keyCenterPosX
    posY = if keyType is Black then 0.18 else 0.13
    posZ = -0.2

    geometry = new THREE.Geometry()
    for i in [0...@count]
      particle = new THREE.Vector3(
        posX,
        posY,
        posZ,
      )
      particle.velocity = new THREE.Vector3(
        (Math.random() - 0.5) * 0.04,
        (Math.random() - 0.3) * 0.01,
        (Math.random() - 0.5) * 0.04
      )
      geometry.vertices.push(particle)

    material = @materials[note]

    particleSystem = new THREE.PointCloud(geometry, material)
    particleSystem.age = 0
    particleSystem.transparent = true
    particleSystem.opacity = 0.8

    @model.add(particleSystem)

@NoteParticles = NoteParticles
