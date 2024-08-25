import * as THREE from '../node_modules/three/build/three.module.js';
import { OrbitControls } from '../node_modules/three/examples/jsm/controls/OrbitControls'

let objectToInteract

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
    const directionalLight = new THREE.DirectionalLight( 0xffffff, 1 );
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
    
    function onPointerMove(event) {
        pointer.x = ( event.clientX / window.innerWidth ) * 2 - 1;
        pointer.y = - ( event.clientY / window.innerHeight ) * 2 + 1;
    }

    scene.tickCallbacks = []
    
    function render() {
        requestAnimationFrame(render)
    
        raycaster.setFromCamera(pointer, camera);
        const intersects = raycaster.intersectObjects(scene.children);
    
        objectToInteract = undefined
        for ( let i = 0; i < intersects.length; i ++ ) {
            if (intersects[i].object.onClick) {
                objectToInteract = intersects[i].object
            }
        }
    
        scene.tickCallbacks.forEach(callback => callback())

        renderer.clear();      
        renderer.render(scene, camera);
        // renderer.clearDepth(); 
        renderer.render(scene, uiCamera);
    }

    document.body.addEventListener("clickDoor", function(e) {
        const doorDir = event.doorDir
        console.log("go to ", doorDir)
    })

    window.addEventListener('click', (e) => {
        if (objectToInteract) objectToInteract.onClick()
    })
  
    
    window.addEventListener( 'pointermove', onPointerMove );
    
    render()

    // scene.tickCallbacks.push(() => {
    //     cameraPivot.rotation.y += 0.001
    // })

    return scene
}