import * as THREE from '../node_modules/three/build/three.module.js';

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