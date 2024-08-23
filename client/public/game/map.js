import { GLTFLoader } from '../node_modules/three/examples/jsm/loaders/GLTFLoader.js';

export function initMap(scene) {
    const loader = new GLTFLoader();
    
    // Floor
    const randomDetails = []
    for (let i = 0; i < 10; i++) {
        randomDetails.push([Math.floor(Math.random() * 7), Math.floor(Math.random() * 7)])
    }

    loader.load('assets/models/GLB format/floor.glb', function (gltf) {
        for (let j = 0; j < 7; j++) {
            for (let i = 0; i < 7; i++) {
                if (!randomDetails.includes((elem) => elem[0] == i && elem[1] == j)) {
                    const copyModel = gltf.scene.clone();
                    copyModel.position.set((i - 3), 0, (j - 3)); // Adjust the position for each copy
                    scene.add(copyModel);   
                }
           }
        }
        let copyModel = gltf.scene.clone();
        copyModel.position.set(0, 0, -4); // Adjust the position for each copy
        scene.add(copyModel);
        copyModel = gltf.scene.clone();
        copyModel.position.set(0, 0, 4); // Adjust the position for each copy
        scene.add(copyModel);
        copyModel = gltf.scene.clone();
        copyModel.position.set(4, 0, 0); // Adjust the position for each copy
        scene.add(copyModel);
        copyModel = gltf.scene.clone();
        copyModel.position.set(-4, 0, 0); // Adjust the position for each copy
        scene.add(copyModel);
    }, undefined, function (error) {
        console.error(error);
    });
    loader.load('assets/models/GLB format/floor-detail.glb', function (gltf) {
        randomDetails.forEach(([i, j]) => {
            const copyModel = gltf.scene.clone();
            copyModel.position.set((i - 3), 0, (j - 3)); // Adjust the position for each copy
            scene.add(copyModel);
        })
    }, undefined, function (error) {
        console.error(error);
    });

    // Wall
    loader.load('assets/models/GLB format/wall.glb', function (gltf) {
        for (let i = 0; i < 9; i++) {
            if (i !== 4) {
                const copyModel = gltf.scene.clone();
                copyModel.position.set((i - 4), 0, -4); // Adjust the position for each copy
                scene.add(copyModel);
            }
        }
        for (let i = 0; i < 9; i++) {
            if (i !== 4) {
                const copyModel = gltf.scene.clone();
                copyModel.position.set((i - 4), 0, 4); // Adjust the position for each copy
                scene.add(copyModel);
            }
        }
        for (let i = 0; i < 9; i++) {
            if (i !== 4) {
                const copyModel = gltf.scene.clone();
                copyModel.position.set(-4, 0, (i - 4)); // Adjust the position for each copy
                scene.add(copyModel);
            }
        }
        for (let i = 0; i < 9; i++) {
            if (i !== 4) {
                const copyModel = gltf.scene.clone();
                copyModel.position.set(4, 0, (i - 4)); // Adjust the position for each copy
                scene.add(copyModel);
            }
        }
    }, undefined, function (error) {
        console.error(error);
    });

    // Doors
    loader.load('assets/models/GLB format/gate.glb', function (gltf) {
        let door = gltf.scene.clone();
        door.position.set(0, 0, -3.75); // Adjust the position for each copy
        scene.add(door);
        door = gltf.scene.clone();
        door.position.set(0, 0, 3.75); // Adjust the position for each copy
        scene.add(door);
        door = gltf.scene.clone();
        door.position.set(-3.75, 0, 0); // Adjust the position for each copy
        door.rotation.set(0,Math.PI * 0.5, 0)
        scene.add(door);
        door = gltf.scene.clone();
        door.position.set(3.75, 0, 0); // Adjust the position for each copy
        door.rotation.set(0,Math.PI * 0.5, 0)
        scene.add(door);
    }, undefined, function (error) {
        console.error(error);
    });
    loader.load('assets/models/GLB format/wall-opening.glb', function (gltf) {
        let opening = gltf.scene.clone();
        opening.position.set(0, 0, -4); // Adjust the position for each copy
        scene.add(opening);
        opening = gltf.scene.clone();
        opening.position.set(0, 0, 4); // Adjust the position for each copy
        scene.add(opening);
        opening = gltf.scene.clone();
        opening.position.set(-4, 0, 0); // Adjust the position for each copy
        opening.rotation.set(0,Math.PI * 0.5, 0)
        scene.add(opening);
        opening = gltf.scene.clone();
        opening.position.set(4, 0, 0); // Adjust the position for each copy
        opening.rotation.set(0,Math.PI * 0.5, 0)
        scene.add(opening);
    }, undefined, function (error) {
        console.error(error);
    });
}