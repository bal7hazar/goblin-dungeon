import * as THREE from '../node_modules/three/build/three.module.js';
// import Stats from '../node_modules/three/examples/jsm/libs/stats.module'
import { initDojo } from './dojo/dojo.js';
import { initScene } from './game/scene.js';
import { initMap } from './game/map.js';
import { loadFont } from './utils/text.js';
import { startFight } from './game/fight.js';
import { FBXLoader } from '../node_modules/three/examples/jsm/loaders/FBXLoader';
import { addHero } from './game/hero.js';
import { createStaticText } from './utils/text.js';
import { dojo_attack, on_entity_update } from './utils/event.js';

let timeoutUpdateFight
let scene
let roomTexts = {}
let room
let currentRoomPosition = { x: 0, y: 0 }
let dojoData = {}
let hero
let currentFight

on_entity_update(function(data) {
    dojoData = data
    console.log(data)
    room = data.currentRoom
    if (data.currentRoom && (currentRoomPosition.x !== data.currentRoom.x.value || currentRoomPosition.y !== data.currentRoom.y.value)) {
        const x = data.currentRoom.x.value;
        const y = data.currentRoom.y.value;
        currentRoomPosition = { x, y }
        roomTexts.current = roomTexts.current.updateText(`(${Math.floor(x)};${Math.floor(y)})`)
        roomTexts.east = roomTexts.east.updateText(`(${Math.floor(x + 1)};${Math.floor(y)})`)
        roomTexts.west = roomTexts.west.updateText(`(${Math.floor(x - 1)};${Math.floor(y)})`)
        roomTexts.north = roomTexts.north.updateText(`(${Math.floor(x)};${Math.floor(y + 1)})`)
        roomTexts.south = roomTexts.south.updateText(`(${Math.floor(x)};${Math.floor(y - 1)})`)

        console.log("new room")
        setTimeout(() => {
            if (hero) {
                hero.position.set([-4,0,0])
            }
            const fight = startFight(
                scene,
                room.allies,
                room.enemies
            )
            currentFight = fight
            setTimeout(() => {
                fight.startTurn(["fireball", "heal", "punch"], [room.enemies[0].spell.value,room.enemies[1].spell.value,room.enemies[2].spell.value])
                
                // setTimeout(() => { dojo_attack() }, 1000)
            }, 1000)
        }, 500)
    } else if (currentFight) {
        if (timeoutUpdateFight) { clearTimeout(timeoutUpdateFight) }
        timeoutUpdateFight = setTimeout(() => {
            currentFight.setTurnResult(data.currentRoom)
        }, 500)
    }
})

function activateHeroMovement() {
    const fbxLoader = new FBXLoader()
    fbxLoader.load(
        `assets/models/characters/adventurers/Characters/fbx/Knight.fbx`,
        (object) => {
            hero = addHero(scene, object, [0, 0, 0], [0, Math.PI * 0.5, 0])
        },
        undefined,
        (error) => {
            console.log(error)
        }
    )
}

function initRoomUI() {
    roomTexts.current = createStaticText(scene, `(0;0)`, [3, 1, -3])
    roomTexts.east = createStaticText(scene, `(1;0)`, [8, 0, 1.25])
    roomTexts.west = createStaticText(scene, `(-1;0)`, [1.25, 1, 6])
    roomTexts.south = createStaticText(scene, `(0;-1)`, [-7, 1, -2])
    roomTexts.north = createStaticText(scene, `(0;1)`, [-1.25, 0, -9])
}

loadFont(() => {
    setTimeout(() => {
        initDojo()   
    }, 1000)

    scene = initScene()
    initMap(scene)

    initRoomUI()
    activateHeroMovement() 
});

// const loader = new GLTFLoader();
// loader.load('assets/models/GLB format/character-human.glb', function (gltf) {
//     const copyModel = gltf.scene.clone();
//     copyModel.position.set(2,0,2); // Adjust the position for each copy
//     scene.add(copyModel);
// }, undefined, function (error) {
//     console.error(error);
// });
