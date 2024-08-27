import * as THREE from '../node_modules/three/build/three.module.js';
import { CLASSES, ENEMY_CLASSES, SPELLS } from '../utils/constants.js';
import { dojo_attack, on_click_character } from '../utils/event.js';
import { spellIconsChoices } from '../utils/ui.js';
import { addCharacter } from './character.js';

function setupFight(fight, scene, charactersInfo, enemiesInfo) {
    charactersInfo.forEach((character, i) => {
        if (!character || character.class.value === 0 || character.health.value === 0) return;
        const className = CLASSES[character.class.value]
        const object = addCharacter(scene, className, [-2, 0, 1.5 - (i * 1.5)], [0, Math.PI * 0.5, 0])
        object.setHP(character.health.value)
        object.baseId = i
        object.currentId = i
        fight.allies[i] = object
    })
        
    enemiesInfo.forEach((character, i) => {
        if (!character || character.class.value === 0 || character.health.value === 0) return;
        const className = "Skeleton_" + ENEMY_CLASSES[character.class.value]
        const object = addCharacter(scene, className, [2, 0, 1.5 - (i * 1.5)], [0, -Math.PI * 0.5, 0])
        object.setHP(character.health.value)
        fight.enemies[i] = object
    })
}

export function startFight(scene, charactersInfo, enemiesInfo, spellsList) {
    const fight = {
        state: "started",
        setState: function(newState) {
            if (newState === "pickspell") {
                console.log("select a spell")
            } else if (newState === "pickcaster") {
                console.log("select a character to cast this spell")
            } else if (newState === "swap") {
                console.log("select a character to swap")
            } else if (newState === "attack") {
                this.spellsDeck.forEach((icon) => {
                    scene.remove(icon)
                })
                this.spellsDeck = []
                console.log("calling dojo attack with", "0x012", `0x${Math.floor(this.selectedSpell)}`, `0x${Math.floor(this.selectedCaster)}`)
                dojo_attack("0x012", `${Math.floor(this.selectedSpell)}`, `${Math.floor(this.selectedCaster)}`)
            }
            this.state = newState
        },
        allies: {},
        enemies: {},
        spellsList: spellsList,
        turn: 0,
        scene,
        spellsDeck: [],
        currentTurn: [],
        selectedSpell: -1,
        selectedCaster: -1,
        swap1: undefined,
        swap2: undefined
    }
    setupFight(fight, scene, charactersInfo, enemiesInfo)

    const swapCharacters = function(id1, id2) {
        const char1 = Object.values(fight.allies).filter((elem) => elem.currentId == id1)[0]
        const char2 = Object.values(fight.allies).filter((elem) => elem.currentId == id2)[0]
        char1.currentId = id2
        char2.currentId = id1

        const char1Position = [...char1.position]
        char1.setPosition([...char2.position])
        char2.setPosition(char1Position)
    }

    on_click_character((id) => {
        if (fight.state === "pickcaster") {
            fight.selectedCaster = id
            fight.allies[id].prepare(fight.spellsDeck[fight.selectedSpell].spellId)
            setTimeout(() => {
                fight.setState("attack")
            }, 1000)
            return
        }
        if (fight.state !== "swap") {
            return
        }
        if (fight.swap1 === undefined) {
            fight.swap1 = id
            console.log("selected character", id)
            return
        }
        if (id === -1 || id == fight.swap1) {
            fight.swap1 = undefined
            return
        }
        console.log("swaping character", fight.swap1, "and", id)
        swapCharacters(fight.swap1, id)
        fight.swap1 = undefined
    })

    fight.startTurn = async function(spells, enemiesActions) {
        this.turn++
        console.log("SPELLS", spells)
        const [icon1, icon2, icon3] = await spellIconsChoices(scene, [SPELLS[spells[0]], SPELLS[spells[1]], SPELLS[spells[2]]])
        icon1.spellId = spells[0]
        icon1.onClick = () => {
            fight.selectedSpell = 0
            fight.setState("pickcaster")
            console.log("select", spells[0], SPELLS[spells[0]])
        }
        icon2.spellId = spells[1]
        icon2.onClick = () => {
            fight.selectedSpell = 1
            fight.setState("pickcaster")
            console.log("select", spells[1], SPELLS[spells[1]])
        }
        icon3.spellId = spells[2]
        icon3.onClick = () => {
            fight.selectedSpell = 2
            fight.setState("pickcaster")
            console.log("select", spells[2], SPELLS[spells[2]])
        }
        fight.spellsDeck = [icon1, icon2, icon3]
        Object.values(this.allies).forEach((ally) => {
            ally.prepare(1)
        })
        enemiesActions.forEach((spellId, index) => {
            if (this.enemies[index]) {
                this.enemies[index].prepare(spellId)
            }
        })
        fight.setState("pickspell")
    }

    fight.setTurnResult = function(room) {
        fight.currentTurn = []
        if (this.enemies[0]) {
            fight.currentTurn.push({
                source: this.allies[0],
                targets: [ { object: this.enemies[0], dmg:  this.enemies[0].hp - room.enemies[0].health.value }],
                spell: this.allies[0].currentSpell,
                dmg: this.enemies[0].hp - room.enemies[0].health.value
            }) 
        } else {
            if (this.allies[0]) {
                this.allies[0].prepare()
            }
            fight.currentTurn.push(undefined)
        }
        if (this.enemies[1]) {
            fight.currentTurn.push({
                source: this.allies[1],
                targets: [ { object: this.enemies[1], dmg:  this.enemies[1].hp - room.enemies[1].health.value }],
                spell: this.allies[1].currentSpell,
                dmg: this.enemies[1].hp - room.enemies[1].health.value
            }) 
        } else {
            if (this.allies[1]) {
                this.allies[1].prepare()
            }
            fight.currentTurn.push(undefined)
        }
        if (this.enemies[2]) {
            fight.currentTurn.push({
                source: this.allies[2],
                targets: [ { object: this.enemies[2], dmg:  this.enemies[2].hp - room.enemies[2].health.value }],
                spell: this.allies[2].currentSpell,
            }) 
        } else {
            if (this.allies[2]) {
                this.allies[2].prepare()
            }
            fight.currentTurn.push(undefined)
        }
        if (this.enemies[0]) {
            fight.currentTurn.push({
                source: this.enemies[0],
                targets: [ { object: this.allies[0], dmg:  this.allies[0].hp - room.allies[0].health.value }],
                spell: this.enemies[0].currentSpell,
            })
        } else {
            if (this.enemies[0]) {
                this.enemies[0].prepare()
            }
            fight.currentTurn.push(undefined)
        }
        if (this.enemies[1]) {
            fight.currentTurn.push({
                targets: [ { object: this.allies[1], dmg: this.allies[1].hp - room.allies[1].health.value }],
                source: this.enemies[1],
                spell: this.enemies[1].currentSpell,
            })
        } else {
            if (this.enemies[1]) {
                this.enemies[1].prepare()
            }
            fight.currentTurn.push(undefined)
        }
        if (this.enemies[2]) {
            console.log(this.allies[2].hp, room.allies[2].health.value)
            fight.currentTurn.push({
                source: this.enemies[2],
                targets: [ { object: this.allies[2], dmg:  this.allies[2].hp - room.allies[2].health.value }],
                spell: this.enemies[2].currentSpell,
            })
        } else {
            if (this.enemies[2]) {
                this.enemies[2].prepare()
            }
            fight.currentTurn.push(undefined)
        }
        console.log(fight.currentTurn)
        this.executeTurn(0)
    }

    fight.executeTurn = function(step) {
        if (step >= 6) {
            fight.setState("pickspell")
            return
        }
        const turnAction = this.currentTurn[step]
        if (!turnAction) {
            this.executeTurn(step + 1)
            return
        }
        const spell = turnAction.spell
        if (spell > 0) {
            turnAction.source.attack()
            scene.addTween(turnAction.source, "position", (tween) => {
                tween.to({
                    x: turnAction.targets[0].object.position.x + (turnAction.source.position.x < turnAction.targets[0].object.position.x ? -1 : 1),
                }, 400)
                .start()
            })
            setTimeout(() => {
                turnAction.targets.forEach((t) => t.object.hit(t.dmg))
                scene.addTween(turnAction.source, "position", (tween) => {
                    tween.to({
                        x: -turnAction.targets[0].object.position.x,
                    }, 100)
                    .delay(300)
                    .start()
                })
            }, 900)
        } else {
            console.log("spell not handled id:", spell)
        }
        
        setTimeout(() => { this.executeTurn(step + 1) }, 1000)
    }

    fight.clean = function() {
        for (let i = 0; i < 3; i++) {
            if (fight.allies[i]) {
                fight.allies[i].clean()
            }
            if (fight.enemies[i]) {
                fight.enemies[i].clean()
            }
        }
    }

    return fight
}



    // const fbxLoader = new FBXLoader()
    // charactersInfo.forEach((character, i) => {
    //     let className = "Knight"
    //     switch (character.class.value) {
    //         case 1:
    //             className = "Knight"
    //             break;
    //         case 2:
    //             className = "Mage"
    //             break;
    //         case 3:
    //         default:
    //             className = "Rogue"
    //             break;
    //     }
    //     fbxLoader.load(
    //         `assets/models/characters/adventurers/Characters/fbx/${className}.fbx`,
    //         (object) => {
    //             object = addCharacter(scene, object, character.health.value, [-2, 0, -1.5 + (i * 1.5)], [0, Math.PI * 0.5, 0])
    //             object.baseId = i
    //             object.currentId = i
                
    //             // if (character.class.value === 1) {
    //             //     object.children[0].material.color.set('red');
    //             // }
    //             // if (character.class.value === 2) {
    //             //     object.children[0].material.color.set('beige');
    //             // }
    //             // if (character.class.value === 3) {
    //             //     object.children[0].material.color.set('blue');
    //             // }
    //             fight.allies[i] = object
    //         },
    //         undefined,
    //         (error) => {
    //             console.log(error)
    //         }
    //     )

    //     // setTimeout(() => {
    //     //     const fbxLoader = new FBXLoader()
    //     //     fbxLoader.load(
    //     //         `assets/models/model_taking_punch.fbx`,
    //     //         (object) => {
    //     //             const animation = fight.allies[i].animationMixer.clipAction(object.animations[0])
    //     //             fight.allies[i].animations.take_punch = animation
    //     //             animation.loop = THREE.LoopOnce
    //     //             animation.name = "take_punch"
    //     //         },
    //     //         undefined,
    //     //         (error) => {
    //     //             console.log(error)
    //     //         }
    //     //     )
    //     //     fbxLoader.load(
    //     //         `assets/models/model_punch.fbx`,
    //     //         (object) => {
    //     //             const animation = fight.allies[i].animationMixer.clipAction(object.animations[0])
    //     //             fight.allies[i].animations.punch = animation
    //     //             animation.loop = THREE.LoopOnce
    //     //             animation.name = "punch"
    //     //         },
    //     //         undefined,
    //     //         (error) => {
    //     //             console.log(error)
    //     //         }
    //     //     )
    //     // }, 1000)
    // })