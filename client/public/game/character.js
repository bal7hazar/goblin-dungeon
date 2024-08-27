import * as THREE from '../node_modules/three/build/three.module.js';
import { CHARACTERS_MAX_HP, SPELLS } from '../utils/constants.js';
import { click_character } from '../utils/event.js';
import { createFightInfoText, createStaticText } from '../utils/text.js';
import { iconToSpellPreview } from '../utils/ui.js';
import { getModel } from '../utils/assets.js';

export function addCharacter(scene, className, _position, rotation) {
    const object = getModel(className)

    let position = _position
    object.traverse(function (node) {
        if (node.isMesh) {
            node.castShadow = true; // Cast shadow
        }
    });
    object.position.set(position[0], position[1], position[2])
    object.rotation.set(rotation[0], rotation[1], rotation[2])
    object.scale.set(0.5,0.5,0.5)
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
    object.animationMixer.addEventListener( 'finished', function( e	) {
        if (e.action.name === 'Idle') {
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
            if (object.position.z > 0) {
                click_character(0)
            } else if (object.position.z === 0) {
                click_character(1)
            } else if (object.position.z < 0) {
                click_character(2)
            }
        }
    }

    object.maxHp = CHARACTERS_MAX_HP[className]
    object.hp = object.maxHp

    let textHP = createStaticText(scene, `${object.hp}/${object.maxHp}`, [position[0], 1.2, position[2]])
    object.textHP = textHP

    object.setHP = function(newHP) {
        object.hp = newHP
        textHP = textHP.updateText(`${object.hp}/${object.maxHp}`)
    }

    object.attack = function() {
        if (!object.animationsList["1H_Melee_Attack_Slice_Horizontal"]) {
            return
        }
        object.animationsList.Idle.stop()
        object.animationsList["1H_Melee_Attack_Slice_Horizontal"].reset()
        object.animationsList["1H_Melee_Attack_Slice_Horizontal"].loop = THREE.LoopOnce
        object.animationsList["1H_Melee_Attack_Slice_Horizontal"].play()
        scene.remove(prevIcon)
        prevIcon = undefined
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
        if (object.animationsList.Hit_A) {
            object.animationsList.Idle.stop()
            object.animationsList.Hit_A.loop = THREE.LoopOnce
            object.animationsList.Hit_A.reset()
            object.animationsList.Hit_A.play()
        }
        textHP = textHP.updateText(`${object.hp}/${object.maxHp}`)
        createFightInfoText(scene, `-${damage} HP`, [position[0], 1.5, position[2]])
    }

    let prevIcon
    object.prepare = async function(spellId) {
        if (prevIcon) {
            scene.remove(prevIcon)
        }
        if (spellId === undefined) {
            return
        }
        console.log("prepare", spellId)
        object.currentSpell = spellId
        let name = SPELLS[spellId]
        prevIcon = await iconToSpellPreview(name, scene, position)
    }

    object.clean = function() {
        scene.remove(object)
        scene.remove(prevIcon)
        scene.remove(textHP)
    }

    return object
}