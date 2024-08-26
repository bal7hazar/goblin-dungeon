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
        mod knight;
        mod ranger;
        mod priest;
    }
    mod elements {
        mod interface;
        mod fire;
        mod water;
        mod air;
    }
    mod spells {
        mod interface;
        mod buff;
        mod buff_other;
        mod buff_all;
        mod damage;
        mod damage_other;
        mod damage_all;
        mod heal;
        mod heal_other;
        mod heal_all;
        mod shield;
        mod shield_other;
        mod shield_all;
        mod stun;
        mod stun_other;
        mod stun_all;
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

