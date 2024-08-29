import * as THREE from '../node_modules/three/build/three.module.js';
import { CHARACTERS_MAX_HP, ELEMENTS, ELEMENTS_STRENGTH, SPELLS } from '../utils/constants.js';
import { click_character } from '../utils/event.js';
import { createFightInfoText } from '../utils/text.js';
import { addHealthBar, getSpellIcon, iconToSpellPreview } from '../utils/ui.js';
import { getModel } from '../utils/assets.js';
import { worldToScreenPosition } from '../utils/utils.js';

export function addCharacter(scene, className, element, _position, rotation) {
    const object = getModel(className)
    object.maxHP = CHARACTERS_MAX_HP[className]
    object.hp = object.maxHP

    let position = _position
    object.traverse(function (node) {
        if (node.isMesh) {
            node.castShadow = true;
        }
    });
    object.position.set(position[0], position[1], position[2])
    object.rotation.set(rotation[0], rotation[1], rotation[2])
    object.scale.set(0.5,0.5,0.5)

    const hpBarPosition = [position[0], position[1] + 1.6, position[2]]
    const hpBar = addHealthBar(scene, hpBarPosition, 0.3, 0.08)
    hpBar.setHP(object.hp, object.maxHP)
    object.hpBar = hpBar

    if (element > 0) {
        getSpellIcon(ELEMENTS[element], 1, scene).then((elementIcon) => {
            object.elementIcon = elementIcon
            elementIcon.refresh = function() {
                elementIcon.position.set(position[0], 0.055, position[2])    
            }
            elementIcon.rotation.set(-Math.PI * 0.5, 0, 0)
            elementIcon.receiveShadow = true
            elementIcon.traverse((node) => {
                if (node.isMesh) {
                    node.receiveShadow = true
                }
            })
            elementIcon.layers.set(0);
            scene.tickCallbacks.push(() => {
                elementIcon.refresh()
            })
        })
    }

    object.enemyElement = (targetElement) => {
        const elementIcon = object.elementIcon
        if (!elementIcon) {
            setTimeout(() => {
                object.enemyElement(targetElement)
            }, 1000)
            return
        }
        if (targetElement === undefined) {
            elementIcon.scale.set(1, 1, 1)
            return
        }
        if (ELEMENTS_STRENGTH[element] === ELEMENTS[targetElement]) {
            elementIcon.scale.set(1.2,1.2,1.2)
        } else {
            elementIcon.scale.set(0.8,0.8,0.8)
        }
    }

    scene.add(object)

    // animations
    object.animationMixer = new THREE.AnimationMixer(object)
    const animationsList = {}
    for (const anim of object.animations) {
        animationsList[anim.name] = object.animationMixer.clipAction(anim)
    }
    object.animationsList = animationsList
    object.animationsList.Idle.play()
    object.animationsList.Idle.loop = THREE.LoopPingPong
    object.animationMixer.addEventListener('finished', function(e) {
        if (e.action._clip.name === 'Idle') {
            return
        }
        if (e.action._clip.name === 'Death_A') {
            setTimeout(() => {
                object.clean()
            }, 1000)
            return
        }
        object.animationsList.Idle.play()
    });

    const clock = new THREE.Clock()
    scene.tickCallbacks.push(() => {
        object.animationMixer.update(clock.getDelta())
    })

    object.setPosition = function(newPosition) {
        position = newPosition
        object.position.set(position[0], position[1], position[2])
    }

    for (const child of object.children) {
        child.onClick = function() {
            if (object.position.z < 0) {
                click_character(0)
            } else if (object.position.z === 0) {
                click_character(1)
            } else if (object.position.z > 0) {
                click_character(2)
            }
        }
    }

    object.setHP = function(newHP) {
        if (newHP > object.maxHP) {
            object.maxHP = newHP
        }
        object.hp = newHP
        object.hpBar.setHP(object.hp, object.maxHP)
    }

    object.stun = function(duration) {
        object.stunDuration = duration
    }

    object.hit = function(damage) {
        if (damage <= 0) {
            return
        }
        if (object.hp <= 0) {
            console.error("already dead")
            return;
        }
        object.hp -= damage
        if (object.hp <= 0) {
            object.hp = 0
        }
        object.hpBar.setHP(object.hp, object.maxHP)
        createFightInfoText(scene, `-${damage} HP`, [position[0], 1.9, position[2]])
        if (object.hp > 0 && object.animationsList.Hit_A) {
            object.animationsList.Idle.stop()
            object.animationsList.Hit_A.loop = THREE.LoopOnce
            object.animationsList.Hit_A.reset()
            object.animationsList.Hit_A.play()
        } else if (object.hp <= 0 && object.animationsList.Death_A) {
            object.animationsList.Idle.stop()
            object.animationsList.Death_A.loop = THREE.LoopOnce
            object.animationsList.Death_A.clampWhenFinished = true
            object.animationsList.Death_A.reset()
            object.animationsList.Death_A.play()
        }
    }

    object.heal = function(hp) {
        if (hp <= 0) {
            return
        }
        if (object.hp <= 0) {
            console.error("already dead")
            return;   
        }
        object.hp += hp
        if (object.hp > object.maxHP) {
            object.hp = object.maxHP
        }
        if (object.animationsList.Hit_B) {
            object.animationsList.Idle.stop()
            object.animationsList.Hit_B.loop = THREE.LoopOnce
            object.animationsList.Hit_B.reset()
            object.animationsList.Hit_B.play()
        }
        object.hpBar.setHP(object.hp, object.maxHP)
        createFightInfoText(scene, `+${hp} HP`, [position[0], 1.9, position[2]])
    }

    let prevIcon
    object.prepare = async function(spellId) {
        if (prevIcon) {
            scene.remove(prevIcon)
            prevIcon = undefined
        }
        if (spellId === undefined) {
            return
        }
        object.currentSpell = spellId
        let name = SPELLS[spellId]
        // const spellPosition = [position[0],position[1] - 1,position[2]]
        getSpellIcon(name, 1, scene).then((icon) => {
            prevIcon = icon
            prevIcon.refresh = function() {
                prevIcon.position.set(position[0] + (position[0] < 0 ? 1.2 : -1.2), 0.1, position[2])    
            }
            prevIcon.rotation.set(-Math.PI * 0.5, 0, 0)
            prevIcon.layers.set(0);
            prevIcon.onClick = () => {
                click_character(object.currentId)
            }
            prevIcon.refresh()
        })
        // scene.tickCallbacks.push(() => {
        //     elementIcon.refresh()
        // })

    }

    object.clean = function() {
        if (object.cleaned) {
            return
        }
        object.cleaned = true
        scene.remove(object)
        if (object.elementIcon) {
            scene.remove(object.elementIcon)
        }
        if (prevIcon) {
            scene.remove(prevIcon)
        }
        object.hpBar.clean()
    }

    return object
}