import * as THREE from '../node_modules/three/build/three.module.js';
import { FBXLoader } from '../node_modules/three/examples/jsm/loaders/FBXLoader';
import { getModel } from '../utils/assets.js';
import { dojo_attack, on_click_swap } from '../utils/event.js';
import { addCharacter } from './character.js';

function setupFight(fight, scene, charactersInfo, enemiesInfo) {
    // place characters
    charactersInfo.forEach((character, i) => {
        let className = "Knight"
        switch (character.class.value) {
            case 1:
                className = "Knight"
                break;
            case 2:
                className = "RogueHooded"
                break;
            case 3:
            default:
                className = "Mage"
                break;
        }
        const object = addCharacter(scene, getModel(className), character.health.value, [-2, 0, -1.5 + (i * 1.5)], [0, Math.PI * 0.5, 0])
        object.baseId = i
        object.currentId = i
        fight.allies[i] = object
    })
        
    // place enemies
    enemiesInfo.forEach((enemy, i) => {
        if (!enemy || enemy.class.value === 0) return;
        const className = enemy.class.value == 1 ? "Skeleton_Warrior" : (enemy.class.value == 2 ? "Skeleton_Mage" :  (enemy.class.value == 3 ? "Skeleton_Rogue" : "Skeleton_Minion"))
        const object = addCharacter(scene, getModel(className), enemy.health.value, [2, 0, -1.5 + (i * 1.5)], [0, -Math.PI * 0.5, 0])
        fight.enemies[i] = object
    })
}

export function startFight(scene, charactersInfo, enemiesInfo, spellsList) {
    const fight = {
        state: "started",
        setState: function(newState) {
            if (newState === "swap") {
                console.log("select a character to swap")
            } else if (newState === "pickspells") {
                
            } else if (newState === "attack") {
                
            }
            this.state = newState
        },
        allies: {},
        enemies: {},
        spellsList: spellsList,
        turn: 0,
        scene,
        currentTurn: [],
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

    on_click_swap((id) => {
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

    fight.startTurn = function(spells, enemiesActions) {
        this.turn++
        console.log("SPELLS", spells)
        Object.values(this.allies).forEach((ally) => {
            ally.prepare(2) // punch
        })
        enemiesActions.forEach((spellId, index) => {
            if (this.enemies[index]) {
                this.enemies[index].prepare(spellId)
            }
        })
    }

    fight.setTurnResult = function(room) {
        fight.currentTurn = []
        if (this.enemies[0]) {
            fight.currentTurn.push({
                source: this.allies[0],
                target: this.enemies[0],
                spell: this.allies[0].currentSpell,
                dmg: this.enemies[0].hp - room.enemies[0].health.value
            }) 
        } else {
            fight.currentTurn.push(undefined)
        }
        if (this.enemies[1]) {
            fight.currentTurn.push({
                source: this.allies[1],
                target: this.enemies[1],
                spell: this.allies[1].currentSpell,
                dmg: this.enemies[1].hp - room.enemies[1].health.value
            }) 
        } else {
            fight.currentTurn.push(undefined)
        }
        if (this.enemies[2]) {
            fight.currentTurn.push({
                source: this.allies[2],
                target: this.enemies[2],
                spell: this.allies[2].currentSpell,
                dmg: this.enemies[2].hp - room.enemies[2].health.value
            }) 
        } else {
            fight.currentTurn.push(undefined)
        }
        if (this.enemies[0]) {
            fight.currentTurn.push({
                source: this.enemies[0],
                target: this.allies[0],
                spell: this.enemies[0].currentSpell,
                dmg: this.allies[0].hp - room.allies[0].health.value
            })
        } else {
            fight.currentTurn.push(undefined)
        }
        if (this.enemies[1]) {
            fight.currentTurn.push({
                target: this.allies[1],
                source: this.enemies[1],
                spell: this.enemies[1].currentSpell,
                dmg: this.allies[1].hp - room.allies[1].health.value
            })
        } else {
            fight.currentTurn.push(undefined)
        }
        if (this.enemies[2]) {
            console.log(this.allies[2].hp, room.allies[2].health.value)
            fight.currentTurn.push({
                source: this.enemies[2],
                target: this.allies[2],
                spell: this.enemies[2].currentSpell,
                dmg: this.allies[2].hp - room.allies[2].health.value
            })
        } else {
            fight.currentTurn.push(undefined)
        }
        console.log(fight.currentTurn)
        this.executeTurn(0)
    }

    fight.executeTurn = function(step) {
        if (step >= 6) {
            return
        }
        const turnAction = this.currentTurn[step]
        if (!turnAction) {
            this.executeTurn(step + 1)
            return
        }
        const spell = turnAction.spell
        if (spell === 2) {
            turnAction.source.attack()
            scene.addTween(turnAction.source, "position", (tween) => {
                tween.to({
                    x: turnAction.target.position.x + (turnAction.source.position.x < turnAction.target.position.x ? -1 : 1),
                }, 400)
                .start()
            })
            setTimeout(() => {
                turnAction.target.hit(turnAction.dmg)
                scene.addTween(turnAction.source, "position", (tween) => {
                    tween.to({
                        x: -turnAction.target.position.x,
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

    fight.setState("swap")

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