class PianoKey
  pressedOffset: 10
  recoverSpeed: 0.2

  constructor: ({ width, length, height, color, position }) ->
    geometry = new THREE.CubeGeometry(width, length, height)
    material = new THREE.MeshLambertMaterial(color: color)
    @mesh = new THREE.Mesh(geometry, material)
    @mesh.position.copy(position)
    @originalY = position.y
    @pressedY = position.y - pressedOffset

  press: ->
    @mesh.position.y = @pressedY
    @isPressed = true

  release: ->
    @isPressed = false

  update: ->
    if @mesh.position.y < @originalY and !@isPressed
      @mesh.position.y += Math.min(@originalY - @mesh.position.y, @recoverSpeed)
