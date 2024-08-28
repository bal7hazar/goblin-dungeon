import * as THREE from '../node_modules/three/build/three.module.js';
import { FontLoader } from '../node_modules/three/examples/jsm/loaders/FontLoader.js';
import { TextGeometry } from '../node_modules/three/examples/jsm/geometries/TextGeometry.js';
import { worldToScreenPosition } from './utils.js';

const textInfos = {}
let fontLoaded = false

let font,
    textGeo,
    materials

export function loadFont(callback) {
    const loader = new FontLoader();
    loader.load('../node_modules/three/examples/fonts/helvetiker_regular.typeface.json', function (response) {
        font = response;
        fontLoaded = true
        if (callback) {
            callback()
        }
    });
}

export function createStaticText(scene, text, position, needRefresh) {
    if (!fontLoaded) return;
    const depth = 0.01,
        size = 0.04,
        curveSegments = 10,
        bevelThickness = 0.04,
        bevelSize = 0.;
    textGeo = new TextGeometry(text, {
        font: font,
        size: size,
        depth: depth,
        curveSegments: curveSegments,

        bevelThickness: bevelThickness,
        bevelSize: bevelSize,
        bevelEnabled: true

    } );

    textGeo.computeBoundingBox();

    materials = [
        new THREE.MeshBasicMaterial({ color: 0xffffff }),
        new THREE.MeshBasicMaterial({ color: 0xffffff }),
    ];
    
    const textMesh = new THREE.Mesh(textGeo, materials);
    textMesh.geometry.center()
    scene.add(textMesh);

    textMesh.refresh = function() {
        const screenPos = worldToScreenPosition(scene, position)
        textMesh.position.set(...screenPos)
    }
    textMesh.layers.set(2);

    textMesh.updateText = function(newText) {
        scene.remove(textMesh)
        textMesh.removed = true
        return createStaticText(scene, newText, position)
    }
    scene.tickCallbacks.push(() => {
        if (textMesh.removed) return false;
        textMesh.refresh()
    })    
    return textMesh
}

export function createFightInfoText(scene, text, position) {
    if (!fontLoaded) return;
    const textMesh = createStaticText(scene, text, position, false)
    const textId = Math.floor(Math.random() * 10000).toString()
    textInfos[textId] = textMesh
    let tick = 0
    textMesh.refresh = function() {
        if (!textInfos[textId]) return
        const screenPos = worldToScreenPosition(scene, position)
        screenPos[1] += 0.0001 * tick
        textMesh.position.set(...screenPos)
        tick++
        if (tick > 200) {
            scene.remove(textMesh)
            textInfos[textId] = undefined
        }
    }
    return textMesh;
}