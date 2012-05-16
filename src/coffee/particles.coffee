{random} = Math

class ParticleSystem

  count: 100
  size: 0.02
  life: 20

  constructor: (@scene)->
    @particleSystems = []

  createParticles: ({position, color}) ->
    particles = new THREE.Geometry()
    material = new THREE.ParticleBasicMaterial
      color: color
      size: @size

    for i in [0...@count]
      particle = position.clone()
      particle.velocity = new THREE.Vector3(
        (random() - 0.5) * 0.5, random(), (random() - 0.5) * 0.5
      ).multiplyScalar(0.03)
      particles.vertices.push(particle)

    system = new THREE.ParticleSystem(particles, material)
    system.age = 0
    @particleSystems.push(system)
    @scene.add(system)

  update: =>
    for system, i in @particleSystems
      if ++system.age > @life
        @scene.remove(system)
      else
        for particle in system.geometry.vertices
          particle.addSelf(particle.velocity)
          system.geometry.verticesNeedUpdate = true
    @particleSystems = @particleSystems.filter (s) => s.age <= @life

@ParticleSystem = ParticleSystem
