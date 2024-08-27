import { dojo_entity_update, dojo_move, dojo_signup, dojo_spawn, setDojoListeners } from "../utils/event.js"

let dojoData = {
    localPlayer: undefined,
    teams: {},
    rooms: {},
    mobs: {},
    challenges: {},
    getRoomInfo: function() {
        const player = this.localPlayer
        if (!player) {
            return
        }
        const team = this.teams[player.team_id.value]
        const allies = [this.mobs[player.team_id.value][0],this.mobs[player.team_id.value][1],this.mobs[player.team_id.value][2]]
        const enemies = [this.mobs[player.team_id.value][3],this.mobs[player.team_id.value][4],this.mobs[player.team_id.value][5]]
        team.allies = allies
        team.enemies = enemies
        if (this.rooms[player.team_id.value] && this.rooms[player.team_id.value][team.y.value]) {
            team.roomInfo = this.rooms[player.team_id.value][team.y.value][team.x.value]
        }
        return team
    }
}

let subscription

export async function initDojo() {
    await wasm_bindgen();
    const client = await wasm_bindgen.createClient({
        rpcUrl: "http://localhost:5050",
        toriiUrl: "http://localhost:8080",
        relayUrl: "/ip4/127.0.0.1/tcp/9090",
        worldAddress: "0x3b092891f7d869d9255225311da9ffd7a090c851b7ea5de92ea162e5b4dfcd6",
    });
    const actionAddress = '0x03022cd638babf65f15e26ebc9e85a2413bedd9b6580db12b8dd0a8516c4bcfa'

    const provider = wasm_bindgen.createProvider("http://localhost:5050");
    const masterAccount = await provider.createAccount("0x2bbf4f9fd0bbb2e60b0316c1fe0b76cf7a4d0198bd493ced9b8df2a3a24d68a", "0xb3ff441a68610b30fd5e2abbf3a1548eb6ba6f3559f2862bf2dc757e5828ca");

    const privateKey = wasm_bindgen.signingKeyNew();
    const burnerAccount = await masterAccount.deployBurner(privateKey);

    const entities = await client.getEntities({ limit: 1000, offset: 0 });
    Object.values(entities).forEach((models) => {
        for (const key in models) {
            const entity = models[key]
            if (key.endsWith('Room')) {
                dojoData.rooms[entity.dungeon_id.value] = dojoData.rooms[entity.dungeon_id.value] || {}
                dojoData.rooms[entity.dungeon_id.value][entity.y.value] = dojoData.rooms[entity.dungeon_id.value][entity.y.value] || {}
                dojoData.rooms[entity.dungeon_id.value][entity.y.value][entity.x.value] = entity
            }
        }
    })

    subscription = await client.onEntityUpdated([], (entityKey, models) => {
        for (const key in models) {
            const entity = models[key]
            if (key.endsWith('Player') && entity.id.value == burnerAccount.address()) {
                dojoData.localPlayer = entity
            }
            if (key.endsWith('Team')) {
                dojoData.teams[entity.id.value] = entity
            }
            if (key.endsWith('Room')) {
                dojoData.rooms[entity.dungeon_id.value] = dojoData.rooms[entity.dungeon_id.value] || {}
                dojoData.rooms[entity.dungeon_id.value][entity.y.value] = dojoData.rooms[entity.dungeon_id.value][entity.y.value] || {}
                dojoData.rooms[entity.dungeon_id.value][entity.y.value][entity.x.value] = entity
            }
            if (key.endsWith('Mob')) {
                dojoData.mobs[entity.team_id.value] = dojoData.mobs[entity.team_id.value] || {}
                dojoData.mobs[entity.team_id.value][entity.index.value] = entity
            }
            if (key.endsWith('Challenge')) {
                dojoData.challenges[entity.dungeon_id.value] = dojoData.challenges[entity.dungeon_id.value] || {}
                dojoData.challenges[entity.dungeon_id.value][entity.team_id.value] = dojoData.challenges[entity.dungeon_id.value][entity.team_id.value] || {}
                dojoData.challenges[entity.dungeon_id.value][entity.team_id.value][entity.y.value] = dojoData.challenges[entity.dungeon_id.value][entity.team_id.value][entity.y.value] || {}
                dojoData.challenges[entity.dungeon_id.value][entity.team_id.value][entity.y.value][entity.x.value] = entity
            }
        }
        dojo_entity_update(dojoData)
    });

    setDojoListeners({
        dojo_signup: (e) => [burnerAccount, actionAddress, 'signup', [`${Math.floor(e.name)}`]],
        dojo_spawn: () => [burnerAccount, actionAddress, 'spawn', []],
        dojo_attack: (e) => [burnerAccount, actionAddress, 'attack', [e.characterOrder, e.spellId, e.caster]],
        dojo_move: (e) => [burnerAccount, actionAddress, 'move', [`${Math.floor(e.direction)}`]]
    })

    setTimeout(() => {
        dojo_signup('0x484848')
        setTimeout(() => {
            dojo_spawn()
            setTimeout(() => {
                // dojo_move(2)
            }, 1000)
        }, 1000)
    }, 1000);
}