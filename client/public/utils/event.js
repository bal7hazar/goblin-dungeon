import { play_sfx } from "../game/scene.js";

export function setDojoListeners(list) {
    for (const eventName in list) {
        document.body.addEventListener(eventName, function(e) {
            const [burnerAccount, to, selector, calldata] = list[eventName](e)
            burnerAccount.executeRaw([{
                to,
                selector,
                calldata
            }]);
        })
    }
}

export function dojo_signup(name) {
    const e = new Event("dojo_signup")
    e.name = name
    document.body.dispatchEvent(e)
}

export function dojo_spawn() {
    document.body.dispatchEvent(new Event("dojo_spawn"))
}

export function dojo_attack(characterOrder, spellId, caster) {
    const event = new Event("dojo_attack")
    event.characterOrder = characterOrder
    event.spellId = spellId
    event.caster = caster
    document.body.dispatchEvent(event)
}

export function dojo_move(direction) {
    const e = new Event("dojo_move")
    e.direction = direction
    if (e.direction === -1) {
        console.log("invalid direction", direction)
        return
    }
    document.body.dispatchEvent(e)
}

export function dojo_heal() {
    const event = new Event("dojo_heal")
    document.body.dispatchEvent(event)
}

export function dojo_pickup() {
    const event = new Event("dojo_pickup")
    document.body.dispatchEvent(event)
}

export function dojo_hire(adventurerId, teamId) {
    const event = new Event("dojo_hire")
    event.adventurerId = adventurerId
    event.teamId = teamId
    document.body.dispatchEvent(event)
}

export function dojo_burn(spellId) {
    const event = new Event("dojo_burn")
    event.spellId = spellId
    document.body.dispatchEvent(event)
}

const DIRECTIONS = ["None", "North", "East", "South", "West"]
export function clickDoor(direction) {
    play_sfx("door_open")
    dojo_move(DIRECTIONS.indexOf(direction))
}

export function dojo_entity_update(dojoData) {
    const event = new Event("entityUpdate")
    event.data = dojoData
    event.data.currentRoom = dojoData.getRoomInfo()
    document.body.dispatchEvent(event)
}

export function on_entity_update(callback) {
    document.body.addEventListener("entityUpdate", function(event) {
        callback(event.data)
    })
}

// Swap characters

export function click_character(id) {
    const event = new Event("clickCharacter")
    event.id = id
    document.body.dispatchEvent(event)    
}

export function on_click_character(callback) {
    document.body.addEventListener("clickCharacter", function(event) {
        callback(event.id)
    })
}
