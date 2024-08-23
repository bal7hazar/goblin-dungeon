import * as THREE from '../node_modules/three/build/three.module.js';
import { OrbitControls } from '../node_modules/three/examples/jsm/controls/OrbitControls'

export function initScene() {
    // Scene setup
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(renderer.domElement);

    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap; // Optional: set shadow map type

    const directionalLight = new THREE.DirectionalLight( 0xffffff, 1 );
    directionalLight.position.set(10, 200, 10); // Adjust light position as needed
    directionalLight.castShadow = true; // Enable shadows for this light
    scene.add( directionalLight );
    
    // Camera positioning
    camera.position.set(-2.5, 6, 2.5)
    // Assuming you have a camera defined
    camera.rotation.x = -Math.PI * 0.35; // Rotate 45° along the X axis
    camera.rotateOnWorldAxis(new THREE.Vector3(0,1,0), 0.25 * -Math.PI)
 
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
    
        for ( let i = 0; i < intersects.length; i ++ ) {
            //console.log(intersects[0].object)
            // intersects[ i ].object.material.color.set( 0xff0000 );
        }
    
        scene.tickCallbacks.forEach(callback => callback())
    
        renderer.render( scene, camera );
    }
    
    window.addEventListener( 'pointermove', onPointerMove );
    
    render()

    return scene
}