import * as THREE from '../node_modules/three/build/three.module.js';
import { FBXLoader } from '../node_modules/three/examples/jsm/loaders/FBXLoader';
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
const fbxLoader = new FBXLoader()
export async function loadModels() {
    return new Promise(async (resolve, reject) => {
        const list = MODELS_TO_LOAD.map((name) => {
            return new Promise((resolve, reject) => {
                fbxLoader.load(
                    `assets/models/${name}.fbx`,
                    function (object) {
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