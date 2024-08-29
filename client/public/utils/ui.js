import * as THREE from '../node_modules/three/build/three.module.js';
import { getIcon } from "./assets.js";
import { createStaticTextHPBar } from './text.js';
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
            const screenPos = worldToScreenPosition(scene, [position[0], position[1], position[2]])
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

export function addHealthBar(scene, position, width, height) {
    // Black background plane
    const backgroundGeometry = new THREE.PlaneGeometry(width, height);
    const backgroundMaterial = new THREE.MeshBasicMaterial({ color: 0x000000 });
    const background = new THREE.Mesh(backgroundGeometry, backgroundMaterial);
    background.layers.set(2)
    background.refresh = () => {
        background.position.set(...worldToScreenPosition(scene, position))
    }
    scene.tickCallbacks.push(() => {
        if (background.removed) {
            return false
        }
        background.refresh()
    })
    scene.add(background);

    // Red progress bar
    const barGeometry = new THREE.PlaneGeometry(width, height);
    const barMaterial = new THREE.MeshBasicMaterial({ color: 0xff0000 });
    const bar = new THREE.Mesh(barGeometry, barMaterial);
    bar.layers.set(2)
    bar.refresh = () => {
        const screenPos = worldToScreenPosition(scene, position)
        const progress = bar.progress || 1
        screenPos[0] += (-width * 0.5) + progress * width * 0.5
        screenPos[2] += 0.01
        bar.position.set(...screenPos)
    }
    scene.tickCallbacks.push(() => {
        if (bar.removed) {
            return false
        }
        bar.refresh()
    })
    scene.add(bar);

    let textHP = createStaticTextHPBar(scene, `200/200`, position)
    // textHP.refresh = () => {
    //     textHP.position.set(x, y, z + 0.2)
    // }

    return {
        background,
        bar,
        setHP: (hp, maxHP) => {
            bar.progress = hp / maxHP 
            bar.scale.x = bar.progress; // Scale the bar based on progress (0 to 1)
            textHP = textHP.updateText(`${hp}/${maxHP}`)
        },
        clean: () => {
            background.removed = true
            bar.removed = true
            textHP.removed = true
            scene.remove(background)
            scene.remove(bar)
            scene.remove(textHP)
        }
    }
}