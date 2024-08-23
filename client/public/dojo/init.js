export async function initDojo() {
    await wasm_bindgen();
    const client = await wasm_bindgen.createClient({
        rpcUrl: "https://api.cartridge.gg/x/diamond-pit/katana",
        toriiUrl: "https://api.cartridge.gg/x/diamond-pit/torii",
        relayUrl: "/ip4/127.0.0.1/tcp/9090",
        worldAddress: "0x5c1d201209938c1ac8340c7caeec489060b04dff85399605e58ebc2cdc149f4",
    });

    const provider = wasm_bindgen.createProvider("https://api.cartridge.gg/x/diamond-pit/katana");
    const masterAccount = await provider.createAccount("0xcd93de85d43988b9492bfaaff930c129fc3edbc513bb0c2b81577291848007", "0x657e5f424dc6dee0c5a305361ea21e93781fea133d83efa410b771b7f92b");

    const privateKey = wasm_bindgen.signingKeyNew();
    const burnerAccount = await masterAccount.deployBurner(privateKey);

    const entities = await client.getEntities({ limit: 100, offset: 0 });
    console.log("Entities", entities);

    await client.onEntityUpdated([], (key, entities) => {
        console.log("entity update", key, entities);
    });
    console.log("started subscription");

    const pos = {
        x: Math.floor(Math.random() * 9).toString(),
        y: Math.floor(Math.random() * 9).toString(),
        z: Math.floor(Math.random() * 9).toString()
    };
    console.log("hit block", pos);
    // setTimeout(() => {
    //     burnerAccount.executeRaw([{
    //         to: '0x02c24de1c529a154eac885b0b34e8bf1b04f4ce0845b91d1a4fc9aea8c9d71ed',
    //         selector: 'hit_block',
    //         calldata: [
    //             pos.x, pos.y, pos.z, '1000004', '1000004', '1000004'
    //         ]
    //     }]);
    // }, 1000);
}