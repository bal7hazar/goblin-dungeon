import * as THREE from '../node_modules/three/build/three.module.js';
import { OrbitControls } from '../node_modules/three/examples/jsm/controls/OrbitControls'
import TWEEN from '../node_modules/@tweenjs/tween.js'

let objectToInteract, uiObjectToInteract
const tweens = []

export function initScene() {
    // Scene setup
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.autoClear = false
    document.body.appendChild(renderer.domElement);

    scene.camera = camera
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap; // Optional: set shadow map type

    const light = new THREE.AmbientLight(0x999999); // soft white light
    scene.add(light);
    const directionalLight = new THREE.DirectionalLight( 0xaaaaaa, 1 );
    directionalLight.position.set(10, 200, 10); // Adjust light position as needed
    directionalLight.castShadow = true; // Enable shadows for this light
    scene.add(directionalLight);
        
    // Camera positioning
    const cameraPivot = new THREE.Group()
    scene.add(cameraPivot)
    camera.position.set(-2.5, 6, 2.5)
    cameraPivot.add(camera)
    // Assuming you have a camera defined
    camera.rotation.x = -Math.PI * 0.35; // Rotate 45° along the X axis
    camera.rotateOnWorldAxis(new THREE.Vector3(0,1,0), 0.25 * -Math.PI)

    const aspect = window.innerWidth / window.innerHeight;
    const uiCamera = new THREE.OrthographicCamera(-aspect, aspect, 1, -1, 1, 1000 );
    uiCamera.position.set(0,0,5);
    uiCamera.layers.set(2); // Layer 1 for orthographic camera
    scene.uiCamera = uiCamera

    const raycaster = new THREE.Raycaster();
    const pointer = new THREE.Vector2();
    
    const controls = new OrbitControls(camera, renderer.domElement);

    function onPointerMove(event) {
        pointer.x = ( event.clientX / window.innerWidth ) * 2 - 1;
        pointer.y = - ( event.clientY / window.innerHeight ) * 2 + 1;
    }

    scene.tickCallbacks = []
    
    function gameLoop() {
        requestAnimationFrame(gameLoop)
        controls.update();

        // Scene raycast
        raycaster.setFromCamera(pointer, camera);
        raycaster.layers.enableAll();
        let intersects = raycaster.intersectObjects(scene.children);
    
        objectToInteract = undefined
        for ( let i = 0; i < intersects.length; i ++ ) {
            if (intersects[i].object.onClick) {
                objectToInteract = intersects[i].object
            }
        }

        // UI Raycast
        raycaster.setFromCamera(pointer, uiCamera);
        raycaster.layers.set(2);
        intersects = raycaster.intersectObjects(scene.children);
    
        uiObjectToInteract = undefined
        for ( let i = 0; i < intersects.length; i ++ ) {
            if (intersects[i].object.onClick) {
                uiObjectToInteract = intersects[i].object
            }
        }
    
        for (let i = scene.tickCallbacks.length - 1; i >= 0; --i) {
            const callbackResult = scene.tickCallbacks[i]()
            // if (callbackResult === false) {
            //     scene.tickCallbacks.splice(i, 1)
            // }
        }

        render();
        tweens.forEach((t) => t.update())
    }

    function render() {
        renderer.clear();      
        renderer.render(scene, camera);
        renderer.clearDepth(); 
        renderer.render(scene, uiCamera);
    }

    scene.addTween = function(object, name, callback) {
        const tween = new TWEEN.Tween(object[name])
        tween.onComplete(() => {
            const index = tweens.indexOf(tween)
            tweens.splice(index, 1)
        })
        tweens.push(tween)
        callback(tween)
    }

    window.addEventListener('click', (e) => {
        if (uiObjectToInteract) {
            uiObjectToInteract.onClick()
            return
        }

        if (objectToInteract) {
            objectToInteract.onClick()
        }
    })
    
    window.addEventListener('pointermove', onPointerMove);
    
    gameLoop()

    // scene.tickCallbacks.push(() => {
    //     cameraPivot.rotation.y += 0.001
    // })

    return scene
}