import * as THREE from '../node_modules/three/build/three.module.js';
import { FBXLoader } from '../node_modules/three/examples/jsm/loaders/FBXLoader';
import { addCharacter } from './character.js';

export function startFight(scene, charactersInfo, enemiesInfo) {
    const fight = {
        allies: {},
        enemies: {},
        turn: 0,
        currentTurn: [],
    }
    // place characters
    const fbxLoader = new FBXLoader()
    charactersInfo.forEach((character, i) => {
        fbxLoader.load(
            `assets/models/model.fbx`,
            (object) => {
                object = addCharacter(scene, object, 100, [-2, 0, -1.5 + (i * 1.5)], [0, Math.PI * 0.5, 0])

                if (character.class.value === 1) {
                    object.children[0].material.color.set('red');
                }
                if (character.class.value === 2) {
                    object.children[0].material.color.set('beige');
                }
                if (character.class.value === 3) {
                    object.children[0].material.color.set('blue');
                }
                fight.allies[i] = object
            },
            undefined,
            (error) => {
                console.log(error)
            }
        )

        setTimeout(() => {
            const fbxLoader = new FBXLoader()
            fbxLoader.load(
                `assets/models/model_taking_punch.fbx`,
                (object) => {
                    const animation = fight.allies[i].animationMixer.clipAction(object.animations[0])
                    fight.allies[i].animations.take_punch = animation
                    animation.loop = THREE.LoopOnce
                    animation.name = "take_punch"
                },
                undefined,
                (error) => {
                    console.log(error)
                }
            )
            fbxLoader.load(
                `assets/models/model_punch.fbx`,
                (object) => {
                    const animation = fight.allies[i].animationMixer.clipAction(object.animations[0])
                    fight.allies[i].animations.punch = animation
                    animation.loop = THREE.LoopOnce
                    animation.name = "punch"
                },
                undefined,
                (error) => {
                    console.log(error)
                }
            )
        }, 1000)
    })
        
    // place enemies
    enemiesInfo.forEach((enemy, i) => {
        if (!enemy) return;
        fbxLoader.load(
            'assets/models/model.fbx',
            (object) => {
                object = addCharacter(scene, object, 100, [2, 0, -1.5 + (i * 1.5)], [0, -Math.PI * 0.5, 0])

                if (enemy.class.value === 4) {
                    object.children[0].material.color.set('green');
                }
                if (enemy.class.value === 5) {
                    object.children[0].material.color.set('white');
                }
                if (enemy.class.value === 6) {
                    object.children[0].material.color.set('black');
                    object.scale.set(0.25,0.25,0.25)
                }
                fight.enemies[i] = object
            },
            undefined,
            (error) => {
                console.log(error)
            }
        )

        setTimeout(() => {
            const fbxLoader = new FBXLoader()
            fbxLoader.load(
                `assets/models/model_taking_punch.fbx`,
                (object) => {
                    const animation = fight.enemies[i].animationMixer.clipAction(object.animations[0])
                    fight.enemies[i].animations.take_punch = animation
                    animation.loop = THREE.LoopOnce
                    animation.name = "take_punch"
                },
                undefined,
                (error) => {
                    console.log(error)
                }
            )
            fbxLoader.load(
                `assets/models/model_punch.fbx`,
                (object) => {
                    const animation = fight.enemies[i].animationMixer.clipAction(object.animations[0])
                    fight.enemies[i].animations.punch = animation
                    animation.loop = THREE.LoopOnce
                    animation.name = "punch"
                },
                undefined,
                (error) => {
                    console.log(error)
                }
            )
        }, 1000)
    })

    fight.startTurn = function(spells, enemiesActions) {
        this.turn++
        Object.values(this.allies).forEach((ally) => {
            ally.prepare(2) // punch
        })
        enemiesActions.forEach((spellId, index) => {
            this.enemies[index].prepare(spellId)
        })
    }

    fight.setTurnResult = function(room) {
        console.log(this.enemies[0].hp - room.enemies[0].health.value, room.enemies[0].health.value)
        console.log(this.allies[2].hp - room.allies[2].health.value, room.allies[2].health.value)
        fight.currentTurn = []
        fight.currentTurn.push({
            id: 0,
            source: this.allies[0],
            target: this.enemies[0],
            dmg: this.enemies[0].hp - room.enemies[0].health.value
        },
        {
            id: 1,
            source: this.allies[1],
            target: this.enemies[1],
            dmg: this.enemies[1].hp - room.enemies[1].health.value
        },
        {
            id: 2,
            source: this.allies[2],
            target: this.enemies[2],
            dmg: this.enemies[2].hp - room.enemies[2].health.value
        },
        {
            id: 3,
            source: this.enemies[0],
            target: this.allies[0],
            dmg: this.allies[0].hp - room.allies[0].health.value
        },
        {
            id: 4,
            source: this.enemies[1],
            target: this.allies[1],
            dmg: this.allies[1].hp - room.allies[1].health.value
        },
        {
            id: 5,
            source: this.enemies[2],
            target: this.allies[2],
            dmg: this.allies[2].hp - room.allies[2].health.value
        })
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
        const spell = turnAction.source.currentSpell
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
        } else if (spell === 5) {
            console.log(spell)
        } else {
            console.log("spell not handled id:", spell)
        }
        
        setTimeout(() => { this.executeTurn(step + 1) }, 1000)
    }
    return fight
}
