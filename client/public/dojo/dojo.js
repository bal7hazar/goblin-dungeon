import { dojo_entity_update, dojo_move, dojo_signup, dojo_spawn, setDojoListeners } from "../utils/event.js"

import { config } from './env.js';

const {
    NODE_URL,
    TORII_URL,
    RELAY_URL,
    WORLD_ADDRESS,
    SYSTEM_ADDRESS,
    MASTER_ADDRESS,
    MASTER_PRIVATE_KEY,
} = config;

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
        rpcUrl: NODE_URL,
        toriiUrl: TORII_URL,
        relayUrl: RELAY_URL,
        worldAddress: WORLD_ADDRESS,
    });
    const actionAddress = SYSTEM_ADDRESS;

    const provider = wasm_bindgen.createProvider(NODE_URL);
    const masterAccount = await provider.createAccount(
        MASTER_PRIVATE_KEY,
        MASTER_ADDRESS,
    );

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