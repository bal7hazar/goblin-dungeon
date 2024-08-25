import * as THREE from '../node_modules/three/build/three.module.js';

export function addHero(scene, object, position, rotation) {
    object.animationMixer = new THREE.AnimationMixer(object)
    object.animations = {
        idle: object.animationMixer.clipAction(object.animations[0])
    }
    object.animations.idle.name = 'idle'
    object.animations.idle.play()
    object.animationMixer.addEventListener( 'finished', function( e	) {
        if (e.action.name !== 'idle') {
            object.animations.idle.play()
        }
    });

    object.traverse(function (node) {
        if (node.isMesh) {
            node.castShadow = true; // Cast shadow
            node.receiveShadow = true; // Receive shadow
        }
    });
    object.position.set(position[0], position[1], position[2])
    object.rotation.set(rotation[0], rotation[1], rotation[2])
    object.scale.set(0.5,0.5,0.5)
    scene.add(object)
    const clock = new THREE.Clock()
    scene.tickCallbacks.push(() => {
        object.animationMixer.update(clock.getDelta())
    })
    return object
}