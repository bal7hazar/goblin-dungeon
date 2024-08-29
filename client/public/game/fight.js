import * as THREE from '../node_modules/three/build/three.module.js';
import { CLASSES, ELEMENTS, ELEMENTS_STRENGTH, ENEMY_CLASSES, SPELLS, SPELLS_EFFECTS } from '../utils/constants.js';
import { dojo_attack, on_click_character } from '../utils/event.js';
import { spellIconsChoices } from '../utils/ui.js';
import { addCharacter } from './character.js';

function setupFight(fight, scene, alliesInfo, enemiesInfo) {
    alliesInfo.forEach((character, i) => {
        if (!character || character.class.value === 0 || character.health.value === 0) return;
        const className = CLASSES[character.class.value]
        const object = addCharacter(scene, className, character.element.value, [-2, 0, -1.5 + (i * 1.5)], [0, Math.PI * 0.5, 0])
        object.setHP(character.health.value)
        object.info = character
        if (enemiesInfo[i] && enemiesInfo[i].health.value > 0) {
            object.enemyElement(enemiesInfo[i].element.value)
        } else {
            object.enemyElement()
        }
        object.isAlly = true
        object.baseId = i
        object.currentId = i
        fight.allies[i] = object
    })
        
    enemiesInfo.forEach((character, i) => {
        if (!character || character.class.value === 0 || character.health.value === 0) return;
        const className = "Skeleton_" + ENEMY_CLASSES[character.class.value]
        const object = addCharacter(scene, className, character.element.value, [2, 0, -1.5 + (i * 1.5)], [0, -Math.PI * 0.5, 0])
        object.info = character
        object.currentId = i
        if (alliesInfo[i] && alliesInfo[i].health.value > 0) {
            object.enemyElement(alliesInfo[i].element.value)
        } else {
            object.enemyElement()
        }
        object.isAlly = false
        object.setHP(character.health.value)
        fight.enemies[i] = object
    })
}

export function startFight(scene, alliesInfo, enemiesInfo, spellsList) {
    const fight = {
        state: "started",
        allies: {},
        enemies: {},
        spellsList: spellsList,
        turn: 0,
        scene,
        spellsDeck: [],
        currentTurn: [],
        selectedSpell: -1,
        selectedCaster: -1,
        startNextTurn: undefined
    }

    fight.getCharacterOrder = function() {
        const baseIdA = Object.values(this.allies).filter((elem) => elem.currentId === 0)[0].baseId
        const baseIdB = Object.values(this.allies).filter((elem) => elem.currentId === 1)[0].baseId
        const baseIdC = Object.values(this.allies).filter((elem) => elem.currentId === 2)[0].baseId
        return '0x' + (baseIdC * 256 + baseIdB * 16 + baseIdA).toString(16)
    }

    fight.setState = (newState) => {
        if (newState === "pickspellandswap") {
            if (fight.startNextTurn) {
                fight.startNextTurn()
                fight.startNextTurn = undefined
            }
            console.log("select a spell or swap")
        } else if (newState === "pickcaster") {
            console.log("select a character to cast this spell")
        } else if (newState === "attack") {
            fight.prepareCurrentFight()
            fight.playCurrentFight()
            fight.spellsDeck.forEach((icon) => {
                scene.remove(icon)
            })
            fight.spellsDeck = []
            console.log("calling dojo attack with", fight.getCharacterOrder(), `0x${Math.floor(fight.selectedSpell)}`, `0x${Math.floor(fight.selectedCaster)}`)
            dojo_attack(fight.getCharacterOrder(), `${Math.floor(fight.selectedSpell)}`, `${Math.floor(fight.selectedCaster)}`)
        }
        fight.state = newState
    },

    setupFight(fight, scene, alliesInfo, enemiesInfo)

    const swapCharacters = function(id1, id2) {
        console.log("before swap")
        console.log(fight.allies[0].currentId, fight.allies[0].baseId, '<baseid')
        console.log(fight.allies[1].currentId, fight.allies[1].baseId, '<baseid')
        console.log(fight.allies[2].currentId, fight.allies[2].baseId, '<baseid')

        const char1 = fight.allies[id1]
        const char2 = fight.allies[id2]

        fight.allies[id1] = char2
        fight.allies[id2] = char1

        char1.currentId = id2
        char2.currentId = id1

        const char1Position = [...char1.position]
        char1.setPosition([...char2.position])
        char2.setPosition(char1Position)

        if (fight.enemies[id1] && fight.enemies[id1].info && fight.enemies[id1].info.health.value > 0) {
            fight.allies[id1].enemyElement(fight.enemies[id1].info.element.value)
        } else {
            fight.allies[id1].enemyElement()
        }
        if (fight.enemies[id2] && fight.enemies[id2].info && fight.enemies[id2].info.health.value > 0) {
            fight.allies[id2].enemyElement(fight.enemies[id2].info.element.value)
        } else {
            fight.allies[id2].enemyElement()
        }
        console.log("after swap")
        console.log(fight.allies[0].currentId, fight.allies[0].baseId, '<baseid')
        console.log(fight.allies[1].currentId, fight.allies[1].baseId, '<baseid')
        console.log(fight.allies[2].currentId, fight.allies[2].baseId, '<baseid')
        refreshTurnOrder()
    }

    on_click_character((id) => {
        if (fight.state === "pickcaster") {
            fight.selectedCaster = fight.allies[id].currentId
            console.log(fight.selectedCaster)
            const ally = fight.allies[id]//Object.values(fight.allies).filter((obj) => obj.baseId == fight.selectedCaster)[0]
            ally.info.spell.value = fight.spellsDeck[fight.selectedSpell].spellId
            console.log("SPELL SELECTED FOR ALLY", ally.info.spell.value)
            ally.prepare(fight.spellsDeck[fight.selectedSpell].spellId)
            fight.setState("attack")
            return
        }
    })

    fight.startTurn = async function(room, spells, enemiesActions) {
        this.turn++
        console.log("SPELLS", spells)
        fight.spellSelectionsIcons = await spellIconsChoices(scene, [SPELLS[spells[0]], SPELLS[spells[1]], SPELLS[spells[2]]])
        const [icon1, icon2, icon3, swapAB, swapBC] = fight.spellSelectionsIcons
        swapAB.onClick = () => {
            if (fight.state !== "pickspellandswap" && fight.state !== "pickcaster") {
                return
            }
            swapCharacters(0, 1)
        }
        swapBC.onClick = () => {
            if (fight.state !== "pickspellandswap" && fight.state !== "pickcaster") {
                return
            }
            swapCharacters(1, 2)
        }
        fight.swapAB = swapAB
        fight.swapBC = swapBC
        icon1.spellId = spells[0]
        icon1.onClick = () => {
            fight.selectedSpell = 0
            fight.setState("pickcaster")
            console.log("select", spells[0], SPELLS[spells[0]])
        }
        icon2.spellId = spells[1]
        icon2.onClick = () => {
            fight.selectedSpell = 1
            fight.setState("pickcaster")
            console.log("select", spells[1], SPELLS[spells[1]])
        }
        icon3.spellId = spells[2]
        icon3.onClick = () => {
            fight.selectedSpell = 2
            fight.setState("pickcaster")
            console.log("select", spells[2], SPELLS[spells[2]])
        }
        fight.spellsDeck = [icon1, icon2, icon3]
        Object.values(this.allies).forEach((ally, i) => {
            ally.baseId = i
            ally.currentId = i
            if (ally.hp !== room.allies[i].health.value) {
                console.error("OUT OF SYNC ally", i, ally.hp, room.allies[i].health.value)
                return
            }
            ally.info = room.allies[i]
            if (ally.hp > 0 && ally.info.stun.value <= 0) {
                console.log("Ally", i, "prepare", SPELLS[ally.info.spell.value])
                ally.prepare(ally.info.spell.value)
            }
        })
        enemiesActions.forEach((spellId, index) => {
            const enemy = this.enemies[index]
            if (!enemy) {
                return
            }
            if (enemy.hp !== room.enemies[index].health.value) {
                console.error("OUT OF SYNC enemy", index, enemy.hp, room.enemies[index].health.value)
                return
            }
            enemy.info = room.enemies[index]
            if (enemy && enemy.hp > 0 && enemy.info.stun.value <= 0) {
                console.log("Enemy", index, "prepare", SPELLS[spellId])
                enemy.prepare(spellId)
            }
        })
        fight.setState("pickspellandswap")
        refreshTurnOrder()
    }

    function refreshTurnOrder() {
        let isFirstCharacterStarting =  fight.allies[0] && fight.allies[0].info.health.value > 0 && (!fight.enemies[0] || elementHasAdvantage(fight.allies[0].info.element.value, fight.enemies[0].info.element.value))
        let isSecondCharacterStarting = fight.allies[1] && fight.allies[1].info.health.value > 0 && (!fight.enemies[1] || elementHasAdvantage(fight.allies[1].info.element.value, fight.enemies[1].info.element.value))
        let isThirdCharacterStarting = fight.allies[2] && fight.allies[2].info.health.value > 0 && (!fight.enemies[2] || elementHasAdvantage(fight.allies[2].info.element.value, fight.enemies[2].info.element.value))

        const turnOrder = {
            0: { source: isFirstCharacterStarting ? fight.allies[0] : fight.enemies[0],
                mainTarget: isFirstCharacterStarting ? fight.enemies[0] : fight.allies[0] },
            1: { source: isSecondCharacterStarting ? fight.allies[1] : fight.enemies[1],
                mainTarget: isSecondCharacterStarting ? fight.enemies[1] : fight.allies[1] },
            2: { source: isThirdCharacterStarting ? fight.allies[2] : fight.enemies[2],
                mainTarget: isThirdCharacterStarting ? fight.enemies[2] : fight.allies[2] },
            3: { source: isFirstCharacterStarting ? fight.enemies[0] : fight.allies[0],
                mainTarget: isFirstCharacterStarting ? fight.allies[0] : fight.enemies[0] },
            4: { source: isSecondCharacterStarting ? fight.enemies[1] : fight.allies[1],
                mainTarget: isSecondCharacterStarting ? fight.allies[1] : fight.enemies[1] },
            5: { source: isThirdCharacterStarting ? fight.enemies[2] : fight.allies[2],
                mainTarget: isThirdCharacterStarting ? fight.allies[2] : fight.enemies[2] },
        }
        let turn = 1
        Object.values(fight.allies).forEach((obj) => obj.setTurnInfo())
        Object.values(fight.enemies).forEach((obj) => obj.setTurnInfo())
        Object.values(turnOrder)
            .forEach((obj) => {
                if (obj.source && obj.mainTarget && obj.mainTarget.info.health.value >= 0 && obj.source.info.stun.value <= 0) {
                    obj.source.setTurnInfo(turn++)
                }
            })
    }

    function elementHasAdvantage(elem1, elem2) {
        return ELEMENTS_STRENGTH[elem1] === ELEMENTS[elem2]
    }

    fight.playCurrentFight = function() {
        this.playFightStep(0)
    }

    function computeSpellEffect(fightDetails, source, effect, mainTarget) {
        const myTeam = source.isAlly ? fightDetails.allies : fightDetails.enemies
        const otherTeam = source.isAlly ? fightDetails.enemies : fightDetails.allies
        if (effect.type === "meleeHitSelf") {
            const damage = effect.dmg
            const currentHP = myTeam[source.currentId].hp
            const lastHit = currentHP < damage
            const dmg = (lastHit ? currentHP : damage)
            myTeam[source.currentId].hp -= dmg;
            return {
                changes: [
                    { target: source, type: "hit", dmg, justKilled: lastHit }
                ],
                cast: function() {
                    return 0
                },
            }
        } else if (effect.type === "meleeHitSingle" || effect.type == "spellHitSingle") {
            const damage = effect.dmg
            const currentHP = otherTeam[mainTarget.currentId].hp
            const lastHit = currentHP < damage
            const dmg = (lastHit ? currentHP : damage)
            otherTeam[mainTarget.currentId].hp -= dmg;
            return {
                changes: [
                    { target: mainTarget, type: "hit", dmg, justKilled: lastHit }
                ],
                cast: function() {
                    source.prepare()
                    source.animationsList.Idle.stop()
                    source.animationsList["1H_Melee_Attack_Slice_Horizontal"].reset()
                    source.animationsList["1H_Melee_Attack_Slice_Horizontal"].loop = THREE.LoopOnce
                    source.animationsList["1H_Melee_Attack_Slice_Horizontal"].play()
                    if (effect.type === "meleeHitSingle") {
                        scene.addTween(source, "position", (tween) => {
                            tween.to({
                                x: mainTarget.position.x + (source.position.x < mainTarget.position.x ? -1 : 1),
                            }, 400)
                            .start()
                        })
                        setTimeout(() => {
                            scene.addTween(source, "position", (tween) => {
                                tween.to({
                                    x: -mainTarget.position.x,
                                }, 100)
                                .delay(300)
                                .start()
                            })
                        }, 900)
                    }
                    return 900
                },
            }
        } else if (effect.type === "healSelf") {
            const hp = effect.hp
            const currentHP = myTeam[source.currentId].hp
            const maxHP = myTeam[source.currentId].maxHP
            const reachMax =  currentHP + hp > maxHP
            const hpHealed = (reachMax ? maxHP - currentHP : hp)
            console.log("HP healed", hpHealed)
            myTeam[source.currentId].hp = currentHP + hpHealed
            return {
                changes: [
                    { target: source, type: "heal", hp: hpHealed }
                ],
                cast: function() {
                    source.prepare()
                    source.animationsList.Idle.stop()
                    console.log("heal animation")
                    // source.animationsList["1H_Melee_Attack_Slice_Horizontal"].reset()
                    // source.animationsList["1H_Melee_Attack_Slice_Horizontal"].loop = THREE.LoopOnce
                    // source.animationsList["1H_Melee_Attack_Slice_Horizontal"].play()
                    // scene.addTween(source, "position", (tween) => {
                    //     tween.to({
                    //         x: mainTarget.position.x + (source.position.x < mainTarget.position.x ? -1 : 1),
                    //     }, 400)
                    //     .start()
                    // })
                    setTimeout(() => {
                        // scene.addTween(source, "position", (tween) => {
                        //     tween.to({
                        //         x: -mainTarget.position.x,
                        //     }, 100)
                        //     .delay(300)
                        //     .start()
                        // })
                    }, 900)
                    return 500
                },
            }
        } else if (effect.type === "stunSingle") {
            const duration = effect.duration
            otherTeam[mainTarget.currentId].stunned = true
            // const currentHP = myTeam[source.currentId].hp
            // const maxHP = myTeam[source.currentId].maxHP
            // const reachMax =  currentHP + hp > maxHP
            // const hpHealed = (reachMax ? maxHP - currentHP : hp)
            // console.log("HP healed", hpHealed)
            // myTeam[source.currentId].hp = currentHP + hpHealed
            return {
                changes: [
                    { target: mainTarget, type: "stun", duration }
                ],
                cast: function() {
                    // source.prepare()
                    // source.animationsList.Idle.stop()
                    // console.log("heal animation")
                    // source.animationsList["1H_Melee_Attack_Slice_Horizontal"].reset()
                    // source.animationsList["1H_Melee_Attack_Slice_Horizontal"].loop = THREE.LoopOnce
                    // source.animationsList["1H_Melee_Attack_Slice_Horizontal"].play()
                    // scene.addTween(source, "position", (tween) => {
                    //     tween.to({
                    //         x: mainTarget.position.x + (source.position.x < mainTarget.position.x ? -1 : 1),
                    //     }, 400)
                    //     .start()
                    // })
                    // setTimeout(() => {
                        // scene.addTween(source, "position", (tween) => {
                        //     tween.to({
                        //         x: -mainTarget.position.x,
                        //     }, 100)
                        //     .delay(300)
                        //     .start()
                        // })
                    // }, 900)
                    return 500
                },
            }
        } else if (effect.type === "stunAll" || effect.type === "stunOthers") {
            const duration = effect.duration
            const changes = Object.values(otherTeam).map((enemy) => {
                if (enemy === undefined) {
                    return undefined
                }
                if (effect.type === "stunOthers" && enemy.obj === mainTarget) {
                    return undefined
                }
                otherTeam[enemy.obj.currentId].stunned = true
                return {
                    target: enemy.obj,
                    type: "stun",
                    duration,
                }
            })
            return {
                changes,
                cast: function() {
                    // source.prepare()
                    // source.animationsList.Idle.stop()
                    // console.log("heal animation")
                    return 0
                },
            }
        } else if (effect.type === "healAll" || effect.type === "healOthers") {
            const hp = effect.hp
            const changes = Object.values(myTeam).map((ally) => {
                if (ally === undefined) {
                    return undefined
                }
                if (effect.type === "healOthers" && ally.obj == source) {
                    return undefined
                }
                const currentHP = ally.hp
                const maxHP = ally.maxHP
                const reachMax =  currentHP + hp > maxHP
                const hpHealed = (reachMax ? maxHP - currentHP : hp)
                if (hpHealed === 0) {
                    return undefined
                }
                ally.hp += hpHealed;
                console.log("HP healed", hpHealed)
                return {
                    target: ally.obj,
                    type: "heal",
                    hp: hpHealed,
                }
            })
            return {
                changes,
                cast: function() {
                    source.prepare()
                    source.animationsList.Idle.stop()
                    console.log("heal animation")
                    return 500
                },
            }
        } else if (effect.type === "meleeHitAll" || effect.type === "meleeHitOther" ||
            effect.type === "spellHitAll" || effect.type === "spellHitOthers") {
            const damage = effect.dmg
            return {
                changes: Object.values(otherTeam).map((enemy) => {
                    if (enemy === undefined) {
                        return
                    }
                    if (effect.type.endsWith("Others") && enemy.obj == mainTarget) {
                        return undefined
                    }
                    const currentHP = enemy.hp
                    const lastHit = currentHP < damage
                    const dmg = (lastHit ? currentHP : damage)
                    enemy.hp -= dmg;
                    return {
                        target: enemy.obj,
                        type: "hit",
                        dmg,
                        justKilled: lastHit
                    }
                }),
                cast: function() {
                    source.prepare()
                    source.animationsList.Idle.stop()
                    source.animationsList["1H_Melee_Attack_Slice_Horizontal"].reset()
                    source.animationsList["1H_Melee_Attack_Slice_Horizontal"].loop = THREE.LoopOnce
                    source.animationsList["1H_Melee_Attack_Slice_Horizontal"].play()
                    if (effect.type === "meleeHitAll" || effect.type === "meleeHitOthers") {
                        scene.addTween(source, "position", (tween) => {
                            tween.to({
                                x: mainTarget.position.x + (source.position.x < mainTarget.position.x ? -1 : 1),
                            }, 400)
                            .start()
                        })
                        setTimeout(() => {
                            scene.addTween(source, "position", (tween) => {
                                tween.to({
                                    x: -mainTarget.position.x,
                                }, 100)
                                .delay(300)
                                .start()
                            })
                        }, 900)
                    }
                    return 900
                },
            }
        }
    }

    function computeSpellDetails(fightDetails, source, spellId, mainTarget) {
        if (source.hp <= 0) {
            return
        }
        // console.log("COMPUTING", source, spellId, mainTarget)
        const spellEffects = SPELLS_EFFECTS[spellId]
        const [effect, effect2] = spellEffects
        const spellDetails = computeSpellEffect(fightDetails, source, effect, mainTarget)
        if (effect2) {
            const spellDetails2 = computeSpellEffect(fightDetails, source, effect2, mainTarget)
            if (spellDetails2.changes) {
                spellDetails.changes = spellDetails.changes.concat(spellDetails2.changes)
                // console.log("EXTRA EFFECT", spellDetails2.changes)    
            }
        }
        return spellDetails || {
            changes: [],
            cast: function() {
                console.log(SPELLS[spellId], "not handled")
                return 0
            }
        }
    }

    fight.prepareCurrentFight = function() {
        let isFirstCharacterStarting =  fight.allies[0] && fight.allies[0].info.health.value > 0 && (!fight.enemies[0] || elementHasAdvantage(fight.allies[0].info.element.value, fight.enemies[0].info.element.value))
        let isSecondCharacterStarting = fight.allies[1] && fight.allies[1].info.health.value > 0 && (!fight.enemies[1] || elementHasAdvantage(fight.allies[1].info.element.value, fight.enemies[1].info.element.value))
        let isThirdCharacterStarting = fight.allies[2] && fight.allies[2].info.health.value > 0 && (!fight.enemies[2] || elementHasAdvantage(fight.allies[2].info.element.value, fight.enemies[2].info.element.value))

        const currentTurn = {
            0: { source: isFirstCharacterStarting ? fight.allies[0] : fight.enemies[0],
                mainTarget: isFirstCharacterStarting ? fight.enemies[0] : fight.allies[0] },
            1: { source: isSecondCharacterStarting ? fight.allies[1] : fight.enemies[1],
                mainTarget: isSecondCharacterStarting ? fight.enemies[1] : fight.allies[1] },
            2: { source: isThirdCharacterStarting ? fight.allies[2] : fight.enemies[2],
                mainTarget: isThirdCharacterStarting ? fight.enemies[2] : fight.allies[2] },
            3: { source: isFirstCharacterStarting ? fight.enemies[0] : fight.allies[0],
                mainTarget: isFirstCharacterStarting ? fight.allies[0] : fight.enemies[0] },
            4: { source: isSecondCharacterStarting ? fight.enemies[1] : fight.allies[1],
                mainTarget: isSecondCharacterStarting ? fight.allies[1] : fight.enemies[1] },
            5: { source: isThirdCharacterStarting ? fight.enemies[2] : fight.allies[2],
                mainTarget: isThirdCharacterStarting ? fight.allies[2] : fight.enemies[2] },
        }

        const fightStatus = {
            allies: [
                fight.allies[0] && { obj: fight.allies[0], hp: fight.allies[0].info.health.value, maxHP: fight.allies[0].maxHP, stunned: false },
                fight.allies[1] && { obj: fight.allies[1], hp: fight.allies[1].info.health.value, maxHP: fight.allies[1].maxHP, stunned: false },
                fight.allies[2] && { obj: fight.allies[2], hp: fight.allies[2].info.health.value, maxHP: fight.allies[2].maxHP, stunned: false },
            ],
            enemies: [
                fight.enemies[0] && { obj: fight.enemies[0], hp: fight.enemies[0].info.health.value, maxHP: fight.enemies[0].maxHP, stunned: false },
                fight.enemies[1] && { obj: fight.enemies[1], hp: fight.enemies[1].info.health.value, maxHP: fight.enemies[1].maxHP, stunned: false },
                fight.enemies[2] && { obj: fight.enemies[2], hp: fight.enemies[2].info.health.value, maxHP: fight.enemies[2].maxHP, stunned: false },
            ],
        }
        fight.currentTurn = Object.values(currentTurn).map((info, index) => {
            if (!info.source || !info.mainTarget || info.source.info.health.value <= 0 ||
                info.source.info.stun.value > 0
            ) {
                if (info.source) {
                    info.source.prepare()
                }
                return undefined
            }
            console.log("current turn", index, "spell:", info.source.info.spell.value)
            info.spell = info.source.info.spell.value
            // is character dead (avoid Volley as it can hit other people)
            if (info.spell !== 13 && (info.source.isAlly && (fightStatus.allies[info.source.currentId].hp <= 0 || fightStatus.allies[info.source.currentId].stunned)) ||
                (!info.source.isAlly && (fightStatus.enemies[info.source.currentId].hp <= 0 || fightStatus.enemies[info.source.currentId].stunned))) {
                info.source.prepare()
                return undefined
            }
            info.spellDetails = computeSpellDetails(fightStatus, info.source, info.spell, info.mainTarget)
            if (info.spellDetails === undefined || info.spellDetails.changes.length === 0) {
                info.source.prepare()
                return undefined
            }
            return info
        })
    }

    fight.playFightStep = function(step) {
        if (step >= 6) {
            fight.setState("pickspellandswap")
            return
        }
        const turnAction = this.currentTurn[step]
        if (!turnAction) {
            return this.playFightStep(step + 1)
        }
        const duration = turnAction.spellDetails.cast()
        setTimeout(() => {
            turnAction.spellDetails.changes.forEach((change) => {
                if (!change) {
                    return
                }
                if (change.type === "hit") {
                    change.target.hit(change.dmg)
                } else if (change.type === "heal") {
                    change.target.heal(change.hp)
                } else if (change.type === "stun") {
                    change.target.stun(change.duration)
                }
            })    
        }, duration)
        setTimeout(() => { this.playFightStep(step + 1) }, 1000)
    }

    fight.clean = function() {
        for (let i = 0; i < 3; i++) {
            if (fight.allies[i]) {
                fight.allies[i].clean()
            }
            if (fight.enemies[i]) {
                fight.enemies[i].clean()
            }
        }
        fight.spellSelectionsIcons.forEach((node) => {
            scene.remove(node)
        })
        scene.remove(fight.swapAB)
        scene.remove(fight.swapBC)
    }

    return fight
}



    // const fbxLoader = new FBXLoader()
    // charactersInfo.forEach((character, i) => {
    //     let className = "Knight"
    //     switch (character.class.value) {
    //         case 1:
    //             className = "Knight"
    //             break;
    //         case 2:
    //             className = "Mage"
    //             break;
    //         case 3:
    //         default:
    //             className = "Rogue"
    //             break;
    //     }
    //     fbxLoader.load(
    //         `assets/models/characters/adventurers/Characters/fbx/${className}.fbx`,
    //         (object) => {
    //             object = addCharacter(scene, object, character.health.value, [-2, 0, -1.5 + (i * 1.5)], [0, Math.PI * 0.5, 0])
    //             object.baseId = i
    //             object.currentId = i
                
    //             // if (character.class.value === 1) {
    //             //     object.children[0].material.color.set('red');
    //             // }
    //             // if (character.class.value === 2) {
    //             //     object.children[0].material.color.set('beige');
    //             // }
    //             // if (character.class.value === 3) {
    //             //     object.children[0].material.color.set('blue');
    //             // }
    //             fight.allies[i] = object
    //         },
    //         undefined,
    //         (error) => {
    //             console.log(error)
    //         }
    //     )

    //     // setTimeout(() => {
    //     //     const fbxLoader = new FBXLoader()
    //     //     fbxLoader.load(
    //     //         `assets/models/model_taking_punch.fbx`,
    //     //         (object) => {
    //     //             const animation = fight.allies[i].animationMixer.clipAction(object.animations[0])
    //     //             fight.allies[i].animations.take_punch = animation
    //     //             animation.loop = THREE.LoopOnce
    //     //             animation.name = "take_punch"
    //     //         },
    //     //         undefined,
    //     //         (error) => {
    //     //             console.log(error)
    //     //         }
    //     //     )
    //     //     fbxLoader.load(
    //     //         `assets/models/model_punch.fbx`,
    //     //         (object) => {
    //     //             const animation = fight.allies[i].animationMixer.clipAction(object.animations[0])
    //     //             fight.allies[i].animations.punch = animation
    //     //             animation.loop = THREE.LoopOnce
    //     //             animation.name = "punch"
    //     //         },
    //     //         undefined,
    //     //         (error) => {
    //     //             console.log(error)
    //     //         }
    //     //     )
    //     // }, 1000)
    // })