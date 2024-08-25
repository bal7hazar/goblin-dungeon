import * as THREE from '../node_modules/three/build/three.module.js';

export function worldToScreenPosition(scene, position) {
    const screenPosition = new THREE.Vector3(...position).project(scene.camera);
    return [screenPosition.x, screenPosition.y, 0];    
}
