mod constants;
mod store;

mod types {
    mod direction;
    mod spell;
    mod category;
    mod element;
    mod monster;
    mod role;
    mod threat;
}

mod elements {
    mod monsters {
        mod interface;
        mod mage;
        mod minion;
        mod rogue;
        mod warrior;
    }
    mod roles {
        mod interface;
        mod barbarian;
        mod knight;
        mod mage;
        mod rogue;
    }
    mod elements {
        mod interface;
        mod fire;
        mod water;
        mod air;
    }
    mod spells {
        mod interface;
        mod punch;
        mod kick;
        mod heal;
        mod blizzard;
        mod burst;
        mod fireblade;
        mod fireball;
        mod holywater;
        mod sacrifice;
        mod smash;
        mod stomp;
        mod tornado;
        mod volley;
        mod waterfall;
        mod zephyr;
    }
}

mod models {
    mod index;
    mod player;
    mod factory;
    mod dungeon;
    mod room;
    mod team;
    mod mob;
    mod challenge;
}

mod components {
    mod signable;
    mod playable;
}

mod systems {
    mod actions;
}

mod helpers {
    mod bitmap;
    mod deck;
    mod dice;
    mod math;
    mod battler;
    mod packer;
    mod seeder;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod test_setup;
    mod test_move;
    mod test_attack;
}

