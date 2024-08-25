import * as THREE from '../node_modules/three/build/three.module.js';
import { GLTFLoader } from '../node_modules/three/examples/jsm/loaders/GLTFLoader.js';
// import Stats from '../node_modules/three/examples/jsm/libs/stats.module'
import { initDojo } from './dojo/init.js';
import { initScene } from './game/scene.js';
import { initMap } from './game/map.js';
import { loadFont } from './utils/text.js';
import { startFight } from './game/fight.js';
import { FBXLoader } from '../node_modules/three/examples/jsm/loaders/FBXLoader';
import { addHero } from './game/hero.js';

// initDojo()
const scene = initScene()
initMap(scene)

function activateHeroMovement() {
    const fbxLoader = new FBXLoader()
    fbxLoader.load(
        `assets/models/hero_idle.fbx`,
        (object) => {
            object = addHero(scene, object, [0, 0, 0], [0, Math.PI * 0.5, 0])
        },
        (xhr) => {
            console.log((xhr.loaded / xhr.total) * 100 + '% loaded')
        },
        (error) => {
            console.log(error)
        }
    )
}

loadFont(() => {
    activateHeroMovement()
    // const fight = startFight(
    //     scene,
    //     [{ class: "knight" }, { class: "wizard" }, { class: "priest" }],
    //     [{ class: "goblin" }, { class: "spider" }, { class: "skeleton" }],
    // )
    // setTimeout(() => {
    //     fight.startTurn(["fireball", "heal", "punch"], ["punch", "stun", "punch"])
    // }, 1000)
});

// const loader = new GLTFLoader();
// loader.load('assets/models/GLB format/character-human.glb', function (gltf) {
//     const copyModel = gltf.scene.clone();
//     copyModel.position.set(2,0,2); // Adjust the position for each copy
//     scene.add(copyModel);
// }, undefined, function (error) {
//     console.error(error);
// });
