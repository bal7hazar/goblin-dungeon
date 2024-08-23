import * as THREE from '../node_modules/three/build/three.module.js';
import { FBXLoader } from '../node_modules/three/examples/jsm/loaders/FBXLoader';
import { GLTFLoader } from '../node_modules/three/examples/jsm/loaders/GLTFLoader.js';
// import Stats from '../node_modules/three/examples/jsm/libs/stats.module'
import { initDojo } from './dojo/init.js';
import { initScene } from './game/scene.js';
import { initMap } from './game/map.js';

initDojo()
const scene = initScene()
initMap(scene)

function startFight() {
    // load map

    // place hero

    // place characters

    // place enemies

}
startFight()

// const loader = new GLTFLoader();
// loader.load('assets/models/GLB format/character-human.glb', function (gltf) {
//     const copyModel = gltf.scene.clone();
//     copyModel.position.set(2,0,2); // Adjust the position for each copy
//     scene.add(copyModel);
// }, undefined, function (error) {
//     console.error(error);
// });

function addCharacter(object, position, rotation) {
    const mixer = new THREE.AnimationMixer(object)
    mixer.clipAction(object.animations[0]).play()

    object.traverse(function (node) {
        if (node.isMesh) {
            node.castShadow = true; // Cast shadow
            // node.receiveShadow = true; // Receive shadow
        }
    });
    object.position.set(position[0], position[1], position[2])
    object.rotation.set(rotation[0], rotation[1], rotation[2])
    object.scale.set(0.5,0.5,0.5)
    scene.add(object)
    const clock = new THREE.Clock()
    scene.tickCallbacks.push(() => {
        mixer.update(clock.getDelta())
    })
}

const fbxLoader = new FBXLoader()
for (let i = 0; i < 3; i++) {
    fbxLoader.load(
        'assets/models/model.fbx',
        (object) => {
            addCharacter(object, [-2, 0, -1.5 + (i * 1.5)], [0, Math.PI * 0.5, 0])
        },
        (xhr) => {
            console.log((xhr.loaded / xhr.total) * 100 + '% loaded')
        },
        (error) => {
            console.log(error)
        }
    )    
}

for (let i = 0; i < 3; i++) {
    fbxLoader.load(
        'assets/models/model.fbx',
        (object) => {
            addCharacter(object, [2, 0, -1.5 + (i * 1.5)], [0, -Math.PI * 0.5, 0])
        },
        (xhr) => {
            console.log((xhr.loaded / xhr.total) * 100 + '% loaded')
        },
        (error) => {
            console.log(error)
        }
    )    
}
