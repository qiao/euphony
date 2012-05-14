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
    camera.position.y = 400
    camera.lookAt(new THREE.Vector3())
    scene.add(camera)

    # create renderer
    renderer = new THREE.WebGLRenderer(antialias: true)
    renderer.setSize(width, height)
    renderer.setClearColor(0x000000, 1)
    renderer.autoClear = false
    $container.append(renderer.domElement)

    # create lights
    ambientLight = new THREE.AmbientLight(0xffffff, 0.3)
    scene.add(ambientLight)

    mainLight = new THREE.DirectionalLight(0xffffff, 1)
    mainLight.position.set(1, 2, 4).normalize()
    scene.add(mainLight)

    auxLight = new THREE.DirectionalLight(0xffffff, 1)
    auxLight.position.set(-4, -1, -2).normalize()
    scene.add(auxLight)

    # set instance variables
    [@camera, @scene, @renderer] = [camera, scene, renderer]

  animate: =>
    requestAnimationFrame(@animate)
    @renderer.clear()
    @renderer.render(@scene, @camera)

# export Scene to global
@Scene = Scene
