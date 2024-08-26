import * as THREE from '../node_modules/three/build/three.module.js';
import { getIcon } from "./assets.js";
import { worldToScreenPosition } from './utils.js';

export function iconToSpellPreview(name, scene, position) {
    return new Promise(async (resolve, reject) =>{
        try {
            const texture = new THREE.CanvasTexture(await getIcon(name));
            const material = new THREE.MeshBasicMaterial({ map: texture });
            const geometry = new THREE.PlaneGeometry(0.1, 0.1);
            const icon = new THREE.Mesh(geometry, material);
            icon.layers.set(2);
            scene.add(icon);
            icon.refresh = function() {
                const screenPos = worldToScreenPosition(scene, [position[0], 1.5, position[2]])
                screenPos[0] -= 0.1
                icon.position.set(...screenPos)    
            }
            scene.tickCallbacks.push(() => {
                icon.refresh()
            })
            return resolve(icon)
        } catch(err) {
            return reject(err)
        }
    })
}