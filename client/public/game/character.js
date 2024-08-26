import * as THREE from '../node_modules/three/build/three.module.js';
import { click_swap } from '../utils/event.js';
import { createFightInfoText, createStaticText } from '../utils/text.js';
import { iconToSpellPreview } from '../utils/ui.js';

export function addCharacter(scene, object, maxHp, _position, rotation) {
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
        console.log(anim.name)
    }
    object.animations = animationsList
    object.animations.Idle.play()
    object.animations.Idle.loop = THREE.LoopPingPong
    object.animationMixer.addEventListener( 'finished', function( e	) {
        if (e.action.name === 'Idle') {
            return
        }
        object.animations.Idle.play()
    });

    const clock = new THREE.Clock()
    scene.tickCallbacks.push(() => {
        object.animationMixer.update(clock.getDelta())
    })

    object.setPosition = function(newPosition) {
        position = newPosition
        object.position.set(position[0], position[1], position[2])
    }

    object.children[0].onClick = function() {
        if (object.position.z < 0) {
            click_swap(0)
        } else if (object.position.z === 0) {
            click_swap(1)
        } else if (object.position.z > 0) {
            click_swap(2)
        }
    }

    object.maxHp = maxHp
    object.hp = maxHp

    let textHP = createStaticText(scene, `${object.hp}/${object.maxHp}`, [position[0], 1.2, position[2]])
    object.textHP = textHP

    object.attack = function() {
        if (!object.animations.punch) {
            return
        }
        object.animations.Idle.stop()
        object.animations["1H_Melee_Attack_Slice_Horizontal"].reset()
        object.animations["1H_Melee_Attack_Slice_Horizontal"].play()
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
        if (object.animations.Hit_A) {
            object.animations.Idle.stop()
            object.animations.Hit_A.reset()
            object.animations.Hit_A.play()
        }
        textHP.updateText(`${object.hp}/${object.maxHp}`)
        createFightInfoText(scene, `-${damage} HP`, [position[0], 1.5, position[2]])
    }

    object.prepare = async function(spellId) {
        object.currentSpell = spellId
        const name = spellId == 2 ? "punch" : "stun";
        const icon = await iconToSpellPreview(name, scene, position)
    }

    return object
}