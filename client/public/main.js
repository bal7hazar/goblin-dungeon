import * as THREE from '../node_modules/three/build/three.module.js';
import { initDojo } from './dojo/dojo.js';
import { initScene } from './game/scene.js';
import { initMap } from './game/map.js';
import { loadFont } from './utils/text.js';
import { startFight } from './game/fight.js';
import { addHero } from './game/hero.js';
import { createStaticText } from './utils/text.js';
import { on_entity_update } from './utils/event.js';
import { getModel, loadModels } from './utils/assets.js';
import { ROOM_TYPES } from './utils/constants.js';

let timeoutUpdateFight
let scene
let roomTexts = {}
let room
let currentRoomPosition = { x: 0, y: 0 }
let dojoData = {}
let hero
let currentFight

on_entity_update((data) => {
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
        if (currentFight) {
            currentFight.clean()
        }
        setTimeout(() => {
            const roomInfo = data.rooms[data.currentRoom.dungeon_id.value][data.currentRoom.y.value][data.currentRoom.x.value]
            const roomType = ROOM_TYPES[roomInfo.category.value]
            if (roomType === "Monster") {
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
                    const spells = [parseInt(room.deck.value.slice(2,3),16), parseInt(room.deck.value.slice(3,4),16),parseInt(room.deck.value.slice(4,5),16)]
                    fight.startTurn(spells, [room.enemies[0] ? room.enemies[0].spell.value : undefined,room.enemies[1] ? room.enemies[1].spell.value : undefined,room.enemies[2] ? room.enemies[2].spell.value : undefined])
                }, 1000)
            } else {
                console.log("Just entered", roomType)
            }
        }, 500)
    } else if (currentFight) {
        if (timeoutUpdateFight) { clearTimeout(timeoutUpdateFight) }
        timeoutUpdateFight = setTimeout(() => {
            currentFight.setTurnResult(data.currentRoom)
            setTimeout(() => {
                const spells = [parseInt(room.deck.value.slice(2,3),16), parseInt(room.deck.value.slice(3,4),16),parseInt(room.deck.value.slice(4,5),16)]
                currentFight.startTurn(spells, [room.enemies[0] ? room.enemies[0].spell.value : undefined,room.enemies[1] ? room.enemies[1].spell.value : undefined,room.enemies[2] ? room.enemies[2].spell.value : undefined])
            }, 6000)
        }, 500)
    }
})

function activateHeroMovement() {
    hero = addHero(scene, getModel("Knight"), [0, 0, 0], [0, Math.PI * 0.5, 0])
}

function initRoomUI() {
    roomTexts.current = createStaticText(scene, `(0;0)`, [3, 1, -3])
    roomTexts.east = createStaticText(scene, `(1;0)`, [8, 0, 1.25])
    roomTexts.west = createStaticText(scene, `(-1;0)`, [1.25, 1, 6])
    roomTexts.south = createStaticText(scene, `(0;-1)`, [-7, 1, -2])
    roomTexts.north = createStaticText(scene, `(0;1)`, [-1.25, 0, -9])
}

loadFont(async () => {
    initDojo()
    scene = initScene()
    initMap(scene)
    loadModels().then(() => {
        initRoomUI()
        activateHeroMovement()    
    })
});

// const loader = new GLTFLoader();
// loader.load('assets/models/GLB format/character-human.glb', function (gltf) {
//     const copyModel = gltf.scene.clone();
//     copyModel.position.set(2,0,2); // Adjust the position for each copy
//     scene.add(copyModel);
// }, undefined, function (error) {
//     console.error(error);
// });
