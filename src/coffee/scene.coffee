class Scene
  constructor: (container) ->
    # set dom container
    $container = $(container)
    width = $container.width()
    height = $container.height()

    # create scene
    scene = new THREE.Scene()

    # create camera
    camera = new THREE.PerspectiveCamera(30, width / height, 1, 1500)
    camera.position.set(100, 100, 100)
    camera.lookAt(new THREE.Vector3())
    scene.add(camera)

    # create renderer
    renderer = new THREE.WebGLRenderer(antialias: true)
    renderer.setSize(width, height)
    renderer.setClearColor(0x000000, 1)
    renderer.autoClear = false
    $container.append(renderer.domElement)

    # create lights
    ambientLight = new THREE.AmbientLight(0x333333)
    scene.add(ambientLight)

    mainLight = new THREE.DirectionalLight(0xffffff, 0.8)
    mainLight.position.set(1, 2, 4).normalize()
    scene.add(mainLight)

    auxLight = new THREE.DirectionalLight(0xffffff, 0.3)
    auxLight.position.set(-4, -1, -2).normalize()
    scene.add(auxLight)

    controls = new THREE.OrbitalControls(camera)

    # set instance variables
    @camera = camera
    @scene = scene
    @renderer = renderer
    @controls = controls

  add: (object) ->
    @scene.add(object)

  remove: (object) ->
    @scene.remove(object)

  animate: =>
    requestAnimationFrame(@animate)
    @controls.update()
    @renderer.clear()
    @renderer.render(@scene, @camera)

# export Scene to global
@Scene = Scene
