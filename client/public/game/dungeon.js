import * as THREE from '../node_modules/three/build/three.module.js';
import { getIcon } from "../utils/assets.js";

const UI_LAYER = 2;
const DUNGEON_LAYER = 3;

let circle = undefined;

export function setupDungeon(scene, rooms, team) {
    console.log(team);
    const data = rooms;
    setupToggle(scene, UI_LAYER, 0.95, 0.8, 0);
    setupToggle(scene, DUNGEON_LAYER, 0.95, 0.8, 0);
    setupPointer(scene, DUNGEON_LAYER, team.x.value / 9, team.y.value / 9, 0);
    Object.keys(data).forEach((dungeonId) => {
        const room = data[dungeonId];
        Object.keys(room).forEach((y) => {
            Object.keys(room[y]).forEach((x) => {
                const roomInfo = room[y][x];
                const roomType = roomInfo.category.value;
                console.log('roomType', roomType, x, y)
                const icon = getIconName(roomType);
                getRoomIcon(icon, 0.1, scene, DUNGEON_LAYER, x / 9, y / 9, 0);
            });
        });
    });
    return data;
}

export function setupToggle(scene, layer, x, y, z) {
    return new Promise(async (resolve, reject) =>{
        try {
            const texture = new THREE.CanvasTexture(await getIcon("Map"));
            const material = new THREE.MeshBasicMaterial({ map: texture, transparent: true });
            const geometry = new THREE.PlaneGeometry(0.2, 0.2);
            const icon = new THREE.Mesh(geometry, material);
            icon.onClick = scene.toggleCamera
            icon.layers.set(layer);
            icon.position.set(x, y, z)
            scene.add(icon);
            return resolve(icon)
        } catch(err) {
            return reject(err)
        }
    })
}

export function setupPointer(scene, layer, x, y, z) {
    // Remove previous pointer
    if (circle) {
        scene.remove(circle);
    };
    // Add new pointer
    const color = 0xff0000;
    const material = new THREE.MeshBasicMaterial({ color });
    const geometry = new THREE.SphereGeometry(0.02, 32, 32);
    circle = new THREE.Mesh(geometry, material);
    circle.layers.set(layer);
    circle.position.set(x, y, z)
    scene.add(circle);
}

export function getRoomIcon(name, size, scene, layer, x, y, z) {
    return new Promise(async (resolve, reject) =>{
        try {
            const texture = new THREE.CanvasTexture(await getIcon(name));
            const material = new THREE.MeshBasicMaterial({ map: texture, transparent: true });
            const geometry = new THREE.PlaneGeometry(size, size);
            const icon = new THREE.Mesh(geometry, material);
            icon.layers.set(layer);
            icon.position.set(x, y, z)
            scene.add(icon);
            return resolve(icon)
        } catch(err) {
            return reject(err)
        }
    })
}

function getIconName(category) {
    switch (category) {
        case 0:
            return "Vortex"
        case 1:
            return "Monster"
        case 2:
            return "Fountain"
        case 3:
            return "Spell"
        case 4:
            return "Adventurer"
        case 5:
            return "Burn"
        case 6:
            return "Exit"
    }
}