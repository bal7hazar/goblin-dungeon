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

export function dojo_attack() {
    document.body.dispatchEvent(new Event("dojo_attack"))
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

const DIRECTIONS = ["None", "North", "East", "South", "West"]
export function clickDoor(direction) {
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

export function click_swap(id) {
    const event = new Event("clickSwap")
    event.id = id
    document.body.dispatchEvent(event)    
}

export function on_click_swap(callback) {
    document.body.addEventListener("clickSwap", function(event) {
        callback(event.id)
    })
}
