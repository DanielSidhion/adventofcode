use std::{iter, collections::{BinaryHeap, HashMap}};

const STEP_COST: [i32; 4] = [1, 10, 100, 1000];

fn character_to_val(c: char) -> i8 {
    if c == '.' {
        return -1;
    }

    c as i8 - 'A' as i8
}

fn _val_to_character(val: i8) -> char {
    match val {
        0 => 'A',
        1 => 'B',
        2 => 'C',
        3 => 'D',
        _ => '.',
    }
}

fn solved(burrow: &Burrow) -> bool {
    // We solved if every room is filled with the correct amphipod.
    burrow.rooms.iter().enumerate().all(|(i, r)| {
        r.iter().all(|a| *a == i as i8)
    })
}

fn estimated_cost_to_solve(burrow: &Burrow, mut curr_cost: i32) -> i32 {
    curr_cost += burrow.hallway.iter().enumerate().map(|(i, val)| {
        if *val < 0 {
            return 0;
        }

        let room_hallway_pos = 2 + *val * 2;

        // Always assume amphipod will end at the top of the room.
        let positions_moved = (i as i8 - room_hallway_pos).abs() + 1;
        positions_moved as i32 * STEP_COST[*val as usize]
    }).sum::<i32>();

    curr_cost += burrow.rooms.iter().enumerate().map(|(i, room)| {
        room.iter().enumerate().map(|(j, val)| {
            if *val < 0 || *val == i as i8 {
                return 0;
            }

            let positions_moved = ((i as i8 - *val) * 2 + 1) + (1) + (j as i8); // (cost to move in the hallway) + (cost to move into new room) + (cost to move out of current room).

            positions_moved as i32 * STEP_COST[*val as usize]
        }).sum::<i32>()
    }).sum::<i32>();

    curr_cost
}

#[derive(Clone, Eq, Hash, Ord, PartialEq, PartialOrd)]
struct Burrow {
    hallway: Vec<i8>,
    rooms: Vec<Vec<i8>>,
}

impl Burrow {
    pub fn new_small() -> Self {
        Self {
            hallway: vec![-1; 11],
            rooms: vec![vec![-1; 2]; 4],
        }
    }

    pub fn new_large() -> Self {
        Self {
            hallway: vec![-1; 11],
            rooms: vec![
                vec![-1, 3, 3, -1],
                vec![-1, 2, 1, -1],
                vec![-1, 1, 0, -1],
                vec![-1, 0, 2, -1],
            ],
        }
    }

    pub fn room_size(&self) -> usize {
        self.rooms[0].len()
    }

    fn _print(&self) {
        println!("#############");
        println!("#{}#", self.hallway.iter().map(|v| _val_to_character(*v)).collect::<String>());

        for j in 0..self.room_size() {
            let filler = if j == 0 { "##" } else { "  " };
            print!("{}", filler);
            for i in 0..4 {
                print!("#{}", _val_to_character(self.rooms[i][j]));
            }
            println!("#{}", filler);
        }

        println!("  #########  ");
    }
}

pub struct Submarine {
    curr_line_read: usize,
    starting_burrow_small: Burrow,
    starting_burrow_large: Burrow,
    configurations_to_explore: BinaryHeap<(i32, i32, Burrow)>,
    visited_configurations: HashMap<Burrow, i32>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            curr_line_read: 0,
            starting_burrow_small: Burrow::new_small(),
            starting_burrow_large: Burrow::new_large(),
            configurations_to_explore: BinaryHeap::new(),
            visited_configurations: HashMap::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        self.curr_line_read += 1;

        let amphipods: Vec<_> = result.split(&['#', ' '][..]).filter(|c| !c.is_empty()).collect();

        if self.curr_line_read == 3 {
            for i in 0..4 {
                let amphipod_val = character_to_val(amphipods[i].chars().next().unwrap());
                self.starting_burrow_small.rooms[i][0] = amphipod_val;
                self.starting_burrow_large.rooms[i][0] = amphipod_val;
            }
        } else if self.curr_line_read == 4 {
            for i in 0..4 {
                let amphipod_val = character_to_val(amphipods[i].chars().next().unwrap());
                self.starting_burrow_small.rooms[i][1] = amphipod_val;
                self.starting_burrow_large.rooms[i][3] = amphipod_val;
            }
        }
    }

    fn add_burrow_to_explore(&mut self, burrow: Burrow, burrow_cost: i32) {
        // Only add the burrow to explore if we either haven't visited it yet, or we visited it, but when we visited our cost was higher.
        if burrow_cost < *self.visited_configurations.get(&burrow).unwrap_or(&i32::MAX) {
            let estimated_final_cost = estimated_cost_to_solve(&burrow, burrow_cost);

            self.configurations_to_explore.push((-estimated_final_cost, -burrow_cost, burrow.clone()));
            self.visited_configurations.insert(burrow, burrow_cost);
        }
    }

    fn explore_moving_amphipod_to_hallway_positions(
        &mut self,
        burrow: &Burrow,
        curr_cost: i32,
        (room, room_height): (usize, usize),
        hallway_positions: impl Iterator<Item = usize>
    ) {
        for hallway_pos in hallway_positions {
            if burrow.hallway[hallway_pos] >= 0 {
                // We found an amphipod along the way. Stop trying positions now because we can't go past this amphipod.
                return;
            }

            let mut new_burrow = burrow.clone();
            let Burrow { hallway, rooms } = &mut new_burrow;

            let amphipod = rooms[room][room_height];

            rooms[room][room_height] = -1;
            hallway[hallway_pos] = amphipod;

            let room_hallway_pos = 2 + room * 2;

            let positions_moved = (room_hallway_pos as i32 - hallway_pos as i32).abs() + (room_height as i32 + 1); // (cost to move along hallway) + (cost to go from room to hallway).
            let new_cost = curr_cost + positions_moved * STEP_COST[amphipod as usize];

            self.add_burrow_to_explore(new_burrow, new_cost);
        }
    }

    fn explore_moving_room_to_hallway(&mut self, burrow: &Burrow, curr_cost: i32) {
        for room_val in 0..4 {
            let room = &burrow.rooms[room_val];

            for j in 0..burrow.room_size() {
                let val = room[j];

                if val < 0 {
                    continue;
                }

                // Found an amphipod in the room, let's check if it should be moved.
                let in_correct_room = val == room_val as i8;
                // Neighbors are considered as amphipods below the current one.
                let neighbors_in_correct_room = (j + 1..burrow.room_size()).all(|k| room[k] == room_val as i8);

                if in_correct_room && neighbors_in_correct_room {
                    // All amphipods belong here. No need to move this room.
                    break;
                }

                let curr_hallway_pos = 2 + room_val * 2;

                // It can be moved, so let's try all possibilities where it moves to all places in the hallway.
                // From current hallway position to the end.
                self.explore_moving_amphipod_to_hallway_positions(
                    burrow,
                    curr_cost,
                    (room_val, j),
            (curr_hallway_pos + 1..=9).step_by(2).chain(iter::once(10))
                );

                // From current hallway position to the beginning.
                self.explore_moving_amphipod_to_hallway_positions(
                    burrow,
                    curr_cost,
                    (room_val, j),
            iter::once(0).chain((1..curr_hallway_pos).step_by(2)).rev()
                );

                // We already moved an amphipod from this room, so don't move the other one in this run.
                break;
            }
        }
    }

    fn explore_moving_hallway_to_room(&mut self, burrow: &Burrow, curr_cost: i32) {
        for i in 0..11 {
            if burrow.hallway[i] < 0 {
                continue;
            }

            let Burrow { hallway, rooms } = burrow;
            let val = hallway[i];

            let room_has_same_amphipods = (0..burrow.room_size()).all(|j| rooms[val as usize][j] < 0 || rooms[val as usize][j] == val);

            if !room_has_same_amphipods {
                // Can't move to the room yet.
                continue;
            }

            let room_pos = (0..burrow.room_size()).filter(|j| rooms[val as usize][*j] < 0).max();

            if room_pos == None {
                // There's no space in the room.
                continue;
            }

            // Check if path on hallway is available.
            let room_hallway_pos = 2 + val as usize * 2;
            let mut path = if i < room_hallway_pos {
                // Need to go to the right.
                i + 1..=room_hallway_pos
            } else {
                // Need to go to the left. Order doesn't matter here because all positions will need to be empty anyway.
                room_hallway_pos..=i - 1
            };

            if !path.all(|p| hallway[p] < 0) {
                // Path in the hallway not clear, so we can't move the amphipod.
                continue;
            }

            let room_pos = room_pos.unwrap();
            let positions_moved = (room_hallway_pos as i32 - i as i32).abs() + 1 + room_pos as i32;

            let new_cost = curr_cost + (positions_moved as i32) * STEP_COST[val as usize];

            let mut new_burrow = burrow.clone();
            new_burrow.hallway[i] = -1;
            new_burrow.rooms[val as usize][room_pos] = val;

            self.add_burrow_to_explore(new_burrow, new_cost);
        }
    }

    fn smallest_organization_energy(&mut self, starting_burrow: Burrow) -> i32 {
        self.configurations_to_explore.clear();
        self.visited_configurations.clear();
        self.configurations_to_explore.push((0, 0, starting_burrow.clone()));
        self.visited_configurations.insert(starting_burrow, 0);

        while self.configurations_to_explore.len() > 0 {
            let (_, mut cost, burrow) = self.configurations_to_explore.pop().unwrap();
            cost *= -1;

            if matches!(self.visited_configurations.get(&burrow), Some(&c) if cost > c) {
                // The burrow we're trying to explore has a bigger cost than what we already found, so let's just skip it.
                continue;
            }

            if solved(&burrow) {
                return cost;
            }

            self.explore_moving_room_to_hallway(&burrow, cost);
            self.explore_moving_hallway_to_room(&burrow, cost);
        }

        unreachable!()
    }

    fn smallest_organization_energy_small(&mut self) -> i32 {
        self.smallest_organization_energy(self.starting_burrow_small.clone())
    }

    fn smallest_organization_energy_large(&mut self) -> i32 {
        self.smallest_organization_energy(self.starting_burrow_large.clone())
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.smallest_organization_energy_small());
        println!("Part 2: {}", self.smallest_organization_energy_large());
    }
}