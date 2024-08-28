import * as THREE from '../node_modules/three/build/three.module.js';
import { getIcon } from "./assets.js";
import { worldToScreenPosition } from './utils.js';

export function getSpellIcon(name, size, scene) {
    return new Promise(async (resolve, reject) =>{
        try {
            const texture = new THREE.CanvasTexture(await getIcon(name));
            const material = new THREE.MeshBasicMaterial({ map: texture, transparent: true });
            const geometry = new THREE.PlaneGeometry(size, size);
            const icon = new THREE.Mesh(geometry, material);
            icon.layers.set(2);
            scene.add(icon);
            return resolve(icon)
        } catch(err) {
            console.log(err)
            return reject(err)
        }
    })
}

export function iconToSpellPreview(name, scene, position) {
    return new Promise(async (resolve, reject) => {
        console.log(name)
        const icon = await getSpellIcon(name, 0.2, scene)
        icon.refresh = function() {
            const screenPos = worldToScreenPosition(scene, [position[0], 1.5, position[2]])
            screenPos[0] -= 0.15
            icon.position.set(...screenPos)    
        }
        scene.tickCallbacks.push(() => {
            icon.refresh()
        })
        resolve(icon)
    })
}

export function spellIconsChoices(scene, list) {
    return new Promise(async (resolve, reject) =>{
        console.log(list)
        const icon1 = await getSpellIcon(list[0], 0.2, scene)
        const icon2 = await getSpellIcon(list[1], 0.2, scene)
        const icon3 = await getSpellIcon(list[2], 0.2, scene)

        const swapAB = await getSpellIcon("SwapAB", 0.2, scene)
        const swapBC = await getSpellIcon("SwapBC", 0.2, scene)

        icon1.position.set(-1,0.25,0)
        icon2.position.set(-1,0,0)
        icon3.position.set(-1,-0.25,0)
        swapAB.position.set(-1, -0.5, 0)
        swapBC.position.set(-0.7, -0.5, 0)
        resolve([icon1, icon2, icon3, swapAB, swapBC])
    })
}