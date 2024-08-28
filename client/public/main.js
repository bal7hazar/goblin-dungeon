import * as THREE from '../node_modules/three/build/three.module.js';
import { initDojo } from './dojo/dojo.js';
import { initScene } from './game/scene.js';
import { initMap } from './game/map.js';
import { loadFont } from './utils/text.js';
import { startFight } from './game/fight.js';
import { setupDungeon } from './game/dungeon.js';
import { addHero } from './game/hero.js';
import { createStaticText } from './utils/text.js';
import { dojo_burn, dojo_heal, dojo_hire, dojo_pickup, on_entity_update } from './utils/event.js';
import { getModel, loadModels } from './utils/assets.js';
import { CLASSES, ROOM_TYPES, SPELLS } from './utils/constants.js';
import { getSpellIcon } from './utils/ui.js';
import { worldToScreenPosition } from './utils/utils.js';
import { addCharacter } from './game/character.js';

let timeoutUpdateFight
let scene
let roomTexts = {}
let room
let currentRoomPosition = { x: 0, y: 0 }
let dojoData = {}
let hero
let currentFight
let dungeon

on_entity_update((data) => {
    dojoData = data
    const team = data.teams[data.localPlayer.team_id.value];
    dungeon = setupDungeon(scene, data.rooms, team);
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

        if (currentFight) {
            currentFight.clean()
        }

        setTimeout(() => {
            console.log(dojoData.currentRoom)
            const roomInfo = data.rooms[data.currentRoom.dungeon_id.value][data.currentRoom.y.value][data.currentRoom.x.value]
            const roomType = ROOM_TYPES[roomInfo.category.value]
            if (roomType === "Monster") {
                enterRoom(roomType, {
                    start: () => {
                        const fight = startFight(
                            scene,
                            room.allies,
                            room.enemies
                        )
                        currentFight = fight
                        setTimeout(() => {
                            const spellHex = '0x' + room.spells.value.toString(16)
                            const spells = [parseInt(spellHex.slice(4,5),16), parseInt(spellHex.slice(3,4),16),parseInt(spellHex.slice(2,3),16)]
                            fight.startTurn(dojoData.currentRoom, spells, [room.enemies[0] ? room.enemies[0].spell.value : undefined,room.enemies[1] ? room.enemies[1].spell.value : undefined,room.enemies[2] ? room.enemies[2].spell.value : undefined])
                        }, 1000)        
                    }
                })
            } else if (roomType === "Spell") {
                enterRoom(roomType, {
                    spellId: dojoData.rooms[dojoData.currentRoom.dungeon_id.value][dojoData.currentRoom.y.value][dojoData.currentRoom.x.value].spellId
                })
            } else if (roomType === "Adventurer") {
                enterRoom(roomType, {
                    adventurers: dojoData.rooms[dojoData.currentRoom.dungeon_id.value][dojoData.currentRoom.y.value][dojoData.currentRoom.x.value].adventurers
                })
            } else {
                enterRoom(roomType)
            }
        }, 500)
    } else if (currentFight) {
        if (timeoutUpdateFight) { clearTimeout(timeoutUpdateFight) }
        timeoutUpdateFight = setTimeout(() => {
            setTimeout(() => {
                if (room.spells.value === 0) {
                    currentFight.clean()
                    currentFight = undefined
                    enterRoom("afterfight")
                    return
                }
                const spellHex = '0x' + room.spells.value.toString(16)
                const spells = [parseInt(spellHex.slice(4,5),16), parseInt(spellHex.slice(3,4),16),parseInt(spellHex.slice(2,3),16)]
                currentFight.startTurn(dojoData.currentRoom, spells, [room.enemies[0] ? room.enemies[0].spell.value : undefined,room.enemies[1] ? room.enemies[1].spell.value : undefined,room.enemies[2] ? room.enemies[2].spell.value : undefined])
                console.log(dojoData.currentRoom)
            }, 6000)
        }, 500)
    }
})

function activateHeroMovement() {
    hero = addHero(scene, getModel("Knight"), [0, 0, 0], [0, 0, 0])
}

function initRoomUI() {
    roomTexts.current = createStaticText(scene, `(0;0)`, [3, 1, -3])
    roomTexts.east = createStaticText(scene, `(1;0)`, [8, 0, 1.25])
    roomTexts.west = createStaticText(scene, `(-1;0)`, [1.25, 1, 6])
    roomTexts.south = createStaticText(scene, `(0;-1)`, [-7, 1, -2])
    roomTexts.north = createStaticText(scene, `(0;1)`, [-1.25, 0, -9])
}

let prevRoom
let pickedAdventurerIndex = -1
let pickedTeamIndex = -1
async function enterRoom(name, data) {
    if (prevRoom) {
        prevRoom.exit()
        scene.remove(hero)
    }
    const roomData = {
        name,
        nodes: [],
        exit: function() {
            this.nodes.forEach((node) => {
                if (node.clean) {
                    node.clean()
                } else {
                    scene.remove(node)
                }
            })
        }
    }
    activateHeroMovement()
    if (name === "Fountain") {
        roomData.nodes.push(createStaticText(scene, `Healing potions everywhere...\nAll your characters are fully healed, you can move on.`, [0,0,0]))
        //SFX: heal
        dojo_heal()
    } else if (name === "Monster") {
        scene.remove(hero)
        data.start()
//        room.nodes.push(createStaticText(scene, `Click on one of the 4 doors to explore`, [0,0,0]))
    } else if (name === "afterfight") {
        // nothing
    } else if (name === "Spell") {
        //SFX: magic
        roomData.nodes.push(createStaticText(scene, `Click on the spell to add it to your deck\nor move to another room`, [0,0,0]))
        const spell = await getSpellIcon(SPELLS[parseInt(data.spellId)], 0.2, scene)
        roomData.nodes.push(spell)
        spell.position.set(...worldToScreenPosition(scene, [-1,0,1]))
        spell.onClick = function() {
            scene.remove(roomData.nodes[0])
            scene.remove(roomData.nodes[1])
            roomData.nodes = []
            roomData.nodes.push(createStaticText(scene, `New spell added!`, [0,0,0]))
            dojo_pickup()
        }
    } else if (name === "Hire") {
        roomData.nodes.push(createStaticText(scene, `You can replace one ally.\nClick on the one to fire, then the one to hire,\nthen Recruit button.`, [0,2,0]))
        const character0 = parseInt(data.adventurers.slice(5,6))
        const character0Element = parseInt(data.adventurers.slice(4,5))
        const character1 = parseInt(data.adventurers.slice(3,4))
        const character1Element = parseInt(data.adventurers.slice(2,3))
        const object = addCharacter(scene, CLASSES[character0], character0Element, [2, 0, -1], [0, -Math.PI * 0.5, 0])
        scene.remove(object.textHP)
        roomData.nodes.push(object)
        object.traverse((node) => {
            node.onClick = function() {
                if (pickedAdventurerIndex === 0) {
                    object.scale.set(0.5,0.5,0.5)
                    pickedAdventurerIndex = -1
                } else {
                    object2.scale.set(0.5,0.5,0.5)
                    object.scale.set(0.7,0.7,0.7)
                    pickedAdventurerIndex = 0    
                }
            }
        })
        const object2 = addCharacter(scene, CLASSES[character1], character1Element, [2, 0, 1], [0, -Math.PI * 0.5, 0])
        scene.remove(object2.textHP)
        object2.traverse((node) => {
            node.onClick = function() {
                if (pickedAdventurerIndex === 1) {
                    object2.scale.set(0.5,0.5,0.5)
                    pickedAdventurerIndex = -1
                } else {
                    object.scale.set(0.5,0.5,0.5)
                    object2.scale.set(0.7,0.7,0.7)
                    pickedAdventurerIndex = 1
                }
            }
        })
        roomData.nodes.push(object2)
        const allies = [
            addCharacter(scene, CLASSES[room.allies[0].class.value], room.allies[0].element.value, [-2, 0, -1.5], [0, Math.PI * 0.5, 0]),
            addCharacter(scene, CLASSES[room.allies[1].class.value], room.allies[1].element.value, [-2, 0, 0], [0, Math.PI * 0.5, 0]),
            addCharacter(scene, CLASSES[room.allies[2].class.value], room.allies[2].element.value, [-2, 0, 1.5], [0, Math.PI * 0.5, 0]),
        ]
        allies.forEach((ally, index) => {
            scene.remove(ally.textHP)
            ally.traverse((node) => {
                node.onClick = function() {
                    if (pickedTeamIndex === index) {
                        ally.scale.set(0.5,0.5,0.5)
                        pickedTeamIndex = -1
                    } else {
                        allies.forEach((ally) => {
                            ally.scale.set(0.5,0.5,0.5)
                        })
                        ally.scale.set(0.7,0.7,0.7)
                        pickedTeamIndex = index
                    }
                }
            })
        })
        roomData.nodes.push(...allies)

        const hireIcon = await getSpellIcon("Hire", 0.2, scene)
        roomData.nodes.push(hireIcon)
        hireIcon.position.set(...worldToScreenPosition(scene, [0,0,1.5]))
        hireIcon.onClick = function() {
            if (pickedAdventurerIndex >= 0 && pickedTeamIndex >= 0) {
                dojo_hire(pickedAdventurerIndex, pickedTeamIndex)
                enterRoom("HireDone")
            } else {
                scene.remove(roomData.nodes[0])
                roomData.nodes[0] = createStaticText(scene, `Click on both characters first.`, [0,0,0])
                setTimeout(() => {
                    scene.remove(roomData.nodes[0])
                    roomData.nodes[0] = createStaticText(scene, `You can replace one ally.\nClick on the one to fire, then the one to hire,\nthen Recruit button.`, [0,2,0])    
                }, 2000)
            }
        }
    } else if (name === "Burn") {
        roomData.nodes.push(createStaticText(scene, `These are the spells in your deck. Click on a spell to remove it.`, [0,2,0]))
        const deck = room.deck.value
        for (let i = 2; i < deck.length; i++) {
            const spellId = parseInt('0x' + deck[i])
            const spell = await getSpellIcon(SPELLS[spellId], 0.2, scene)
            roomData.nodes.push(spell)
            spell.onClick = function() {
                const spellIndex = (deck.length - 1) - i
                dojo_burn(spellIndex)
                enterRoom("BurnDone", { spellId })
            }
            spell.position.set(-0.75 + ((i - 2) % 4) * 0.5, -Math.floor((i - 2) / 4) * 0.25, 0)
        }
    } else if (name === "BurnDone") {
        roomData.nodes.push(createStaticText(scene, `You burned the spell ${SPELLS[data.spellId]}.`, [0,0,0]))
    } else if (name === "HireDone") {
        roomData.nodes.push(createStaticText(scene, `You left Bob behind but you have a new member!`, [0,0,0]))
    } else if (name === "Boss") {
        roomData.nodes.push(createStaticText(scene, `GG! You found the exit.\nThanks for playing!`, [0,0,0]))
    } else if (name === "spawn") {
        roomData.nodes.push(createStaticText(scene, `Click on one of the 4 doors to explore`, [0,0,0]))
    } else {
        roomData.nodes.push(createStaticText(scene, `Unknown room`, [0,0,0]))
    }
    prevRoom = roomData
}

loadFont(async () => {
    initDojo()
    scene = initScene()
    initMap(scene)
    loadModels().then(() => {
        initRoomUI()
        enterRoom("spawn")
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
