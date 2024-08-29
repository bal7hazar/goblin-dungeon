import * as THREE from '../node_modules/three/build/three.module.js';
import { FBXLoader } from '../node_modules/three/examples/jsm/loaders/FBXLoader.js';
import * as SkeletonUtils from '../node_modules/three/examples/jsm/utils/SkeletonUtils.js';

const loader = new THREE.ImageBitmapLoader();
loader.setOptions( { imageOrientation: 'flipY' } );
export async function getIcon(name) {
    return new Promise((resolve, reject) => {
        loader.load(
            `assets/icons/${name}.png`,
            function (imageBitmap) {
                resolve(imageBitmap)
            },
            undefined,
            function (err) {
                reject(undefined, 'An error happened', err); 
            }
        );
    })
}

const models = {}
const MODELS_TO_LOAD = [
    "characters/adventurers/Characters/fbx/Knight",
    "characters/adventurers/Characters/fbx/Rogue",
    "characters/adventurers/Characters/fbx/Barbarian",
    "characters/adventurers/Characters/fbx/Mage",
    "characters/monsters/Characters/fbx/Skeleton_Mage",
    "characters/monsters/Characters/fbx/Skeleton_Minion",
    "characters/monsters/Characters/fbx/Skeleton_Rogue",
    "characters/monsters/Characters/fbx/Skeleton_Warrior",
]

const CHILDREN_TO_HIDE = [
    // Knight
    "1H_Sword_Offhand",
    "2H_Sword",
    "Badge_Shield",
    "Rectangle_Shield",
    "Round_Shield",
    // Rogue
    "1H_Crossbow",
    "Knife",
    "Knife_Offhand",
    "Throwable",
    // Barbarian
    "2H_Axe",
    "Barbarian_Round_Shield",
    "Mug",
    // Mage
    "1H_Wand",
    "Spellbook",
    "Spellbook_open",
    // Skeleton_Mage
    // Skeleton_Minion
    // Skeleton_Rogue
    // Skeleton_Warrior
]

const fbxLoader = new FBXLoader()
export async function loadModels() {
    return new Promise(async (resolve, reject) => {
        const list = MODELS_TO_LOAD.map((name) => {
            return new Promise((resolve, reject) => {
                fbxLoader.load(
                    `assets/models/${name}.fbx`,
                    function (object) {
                        // Hide children with the flag isGroup at true
                        object.traverse((child) => {
                            if (CHILDREN_TO_HIDE.includes(child.name)) {
                                child.visible = false
                            }
                        })

                        models[name.split('/')[name.split('/').length - 1]] = object
                        resolve()
                    },
                    undefined,
                    function (err) {
                        reject(undefined, 'An error happened', err); 
                    }
                );
            })
        })
        resolve(await Promise.all(list))
    })
}

export function getModel(name) {
    return SkeletonUtils.clone(models[name])
}