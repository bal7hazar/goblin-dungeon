import * as THREE from '../node_modules/three/build/three.module.js';
import { FBXLoader } from '../node_modules/three/examples/jsm/loaders/FBXLoader';
import { addCharacter } from './character.js';

export function startFight(scene, charactersInfo, enemiesInfo) {
    const fight = {
        allies: {},
        enemies: {},
        turn: 0
    }
    // place characters
    const fbxLoader = new FBXLoader()
    charactersInfo.forEach((character, i) => {
        fbxLoader.load(
            `assets/models/characters/${character.class}.fbx`,
            (object) => {
                object = addCharacter(scene, object, [-2, 0, -1.5 + (i * 1.5)], [0, Math.PI * 0.5, 0])

                if (character.class === "knight") {
                    object.children[0].material.color.set('red');
                }
                if (character.class === "priest") {
                    object.children[0].material.color.set('blue');
                }
                if (character.class === "wizard") {
                    object.children[0].material.color.set('purple');
                }
                fight.allies[i] = object
            },
            (xhr) => {
                console.log((xhr.loaded / xhr.total) * 100 + '% loaded')
            },
            (error) => {
                console.log(error)
            }
        )

        setTimeout(() => {
            const fbxLoader = new FBXLoader()
            fbxLoader.load(
                `assets/models/characters/${character.class}_taking_punch.fbx`,
                (object) => {
                    const animation = fight.allies[i].animationMixer.clipAction(object.animations[0])
                    fight.allies[i].animations.take_punch = animation
                    animation.loop = THREE.LoopOnce
                    animation.name = "take_punch"
                },
                (xhr) => {
                    console.log((xhr.loaded / xhr.total) * 100 + '% loaded')
                },
                (error) => {
                    console.log(error)
                }
            )
        }, 1000)
    })
        
    // place enemies
    enemiesInfo.forEach((enemy, i) => {
        fbxLoader.load(
            'assets/models/model.fbx',
            (object) => {
                object = addCharacter(scene, object, [2, 0, -1.5 + (i * 1.5)], [0, -Math.PI * 0.5, 0])

                if (enemy.class === "spider") {
                    object.children[0].material.color.set('black');
                    object.scale.set(0.25,0.25,0.25)
                }
                if (enemy.class === "skeleton") {
                    object.children[0].material.color.set('white');
                }
                if (enemy.class === "goblin") {
                    object.children[0].material.color.set('green');
                }
                fight.enemies[i] = object
            },
            (xhr) => {
                console.log((xhr.loaded / xhr.total) * 100 + '% loaded')
            },
            (error) => {
                console.log(error)
            }
        )  
    })

    fight.startTurn = function(spells, enemiesActions) {
        this.turn++
        Object.values(this.allies).forEach((ally) => {
            ally.prepare("punch")
        })
        enemiesActions.forEach((name, index) => {
            this.enemies[index].prepare(name)
        })
        setTimeout(() => { this.executeTurn(0) }, 2000)
    }

    fight.executeTurn = function(step) {
        if (step >= 6) {
            return
        }
        if (step < 3) {
            this.allies[step].hit(Math.floor(Math.random() * 3) + 2)
        } else {
            this.enemies[step - 3].hit(Math.floor(Math.random() * 3) + 2)
        }
        setTimeout(() => { this.executeTurn(step + 1) }, 1000)
    }
    return fight
}
