mod constants;
mod store;

mod types {
    mod direction;
    mod spell;
    mod category;
    mod class;
    mod element;
    mod monster;
    mod role;
    mod threat;
    mod slot;
    mod item;
}

mod elements {
    mod monsters {
        mod interface;
        mod goblin;
        mod skeleton;
        mod spider;
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
        mod buff_all;
        mod damage;
        mod damage_all;
        mod heal;
        mod heal_all;
        mod shield;
        mod shield_all;
        mod stun;
        mod stun_all;
    }
    mod items {
        mod interface;
        mod sword;
        mod staff;
        mod helmet;
    }
}

mod models {
    mod index;
    mod player;
    mod factory;
    mod dungeon;
    mod room;
    mod team;
    mod character;
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
    // mod test_move;
// mod test_attack;
}

