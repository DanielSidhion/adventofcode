use std::iter;

fn step_cost(amphipod: char) -> usize {
    match amphipod {
        'A' => 1,
        'B' => 10,
        'C' => 100,
        'D' => 1000,
        _ => usize::MAX,
    }
}

fn room(amphipod: char) -> usize {
    if amphipod == '.' {
        return usize::MAX;
    }

    amphipod as usize - 'A' as usize
}

fn solved(hallway: &Vec<char>, rooms: &Vec<Vec<char>>) -> bool {
    let empty_hallway = hallway.iter().all(|c| *c == '.');
    let rooms_filled = rooms.iter().enumerate().all(|(i, r)| {
        r.iter().all(|a| room(*a) == i )
    });

    empty_hallway && rooms_filled
}

fn min_cost_to_solve(hallway: &Vec<char>, rooms: &Vec<Vec<char>>, mut curr_cost: usize) -> usize {
    for i in 0..11 {
        if let amphipod @ 'A'..='D' = hallway[i] {
            let amphipod_room = room(amphipod);
            let room_hallway_pos = 2 + amphipod_room * 2;

            // Always assume amphipod will end at the top of the room.
            let positions_moved = if i < room_hallway_pos {
                (room_hallway_pos - i) + 1
            } else {
                (i - room_hallway_pos) + 1
            };

            curr_cost += positions_moved * step_cost(amphipod);
        }
    }

    for i in 0..4 {
        for j in 0..4 {
            if let amphipod @ 'A'..='D' = rooms[i][j] {
                let amphipod_room = room(amphipod);

                if amphipod_room == i {
                    continue;
                }

                let positions_moved = if i < amphipod_room {
                    (amphipod_room - i) * 2 + 1 + 1 + 3 - j
                } else {
                    (i - amphipod_room) * 2 + 1 + 1 + 3 - j
                };

                curr_cost += positions_moved * step_cost(amphipod);
            }
        }
    }

    curr_cost
}

pub struct Submarine {
    curr_line_read: usize,
    hallway: Vec<char>,
    rooms: Vec<Vec<char>>,
}

impl Submarine {
    pub fn new() -> Self {
        let mut result = Self {
            curr_line_read: 0,
            hallway: vec!['.'; 11],
            rooms: vec![vec!['.', '.', '.', '.']; 4],
        };

        result.rooms[0][1] = 'D';
        result.rooms[1][1] = 'B';
        result.rooms[2][1] = 'A';
        result.rooms[3][1] = 'C';
        result.rooms[0][2] = 'D';
        result.rooms[1][2] = 'C';
        result.rooms[2][2] = 'B';
        result.rooms[3][2] = 'A';

        result
    }

    pub fn on_input(&mut self, result: &str) {
        self.curr_line_read += 1;

        let amphipods: Vec<_> = result.split(&['#', ' '][..]).filter(|c| !c.is_empty()).collect();

        if self.curr_line_read == 3 {
            for i in 0..4 {
                self.rooms[i][3] = amphipods[i].chars().next().unwrap();
            }
        } else if self.curr_line_read == 4 {
            for i in 0..4 {
                self.rooms[i][0] = amphipods[i].chars().next().unwrap();
            }
        }
    }

    fn smallest_organization_energy(&self) -> usize {
        let mut result = usize::MAX;

        let mut possible_configurations = Vec::new();
        possible_configurations.push((self.hallway.clone(), self.rooms.clone(), 0usize));

        while possible_configurations.len() > 0 {
            let (mut hallway, mut rooms, cost) = possible_configurations.pop().unwrap();

            if cost > result || min_cost_to_solve(&hallway, &rooms, cost) > result {
                // Not worth exploring this path anymore, it's going to be more expensive than our best solution so far.
                continue;
            }

            if solved(&hallway, &rooms) {
                if cost < result {
                    println!("Current best solution: {}", result);
                }
                result = result.min(cost);

                continue;
            }

            // First we attempt moving amphipods out of their rooms if they should be moved.
            for i in 0..4 {
                for j in (0..4).rev() {
                    if let amphipod @ 'A'..='D' = rooms[i][j] {
                        // There's an amphipod in the room, let's check if it should be moved.
                        let is_in_room = room(amphipod) == i;
                        let are_neighbors_in_room = (0..j).all(|k| room(rooms[i][k]) == i); // Neighbors are always on the bottom of current one.

                        if is_in_room && are_neighbors_in_room {
                            // No need to move this room.
                            break;
                        }

                        // It can be moved, so let's try all possibilities where it moves to all places in the hallway.
                        let curr_hallway_pos = 2 + i * 2;

                        rooms[i][j] = '.';

                        // From current hallway position to the end.
                        for k in (curr_hallway_pos + 1..=9).step_by(2).chain(iter::once(10)) {
                            if hallway[k] != '.' {
                                // We found an amphipod along the way. Stop trying positions now because we can't go past this amphipod.
                                break;
                            }

                            // Temporarily add this amphipod so we can clone the hallway and push it to a configuration to try.
                            hallway[k] = amphipod;

                            let positions_moved = (k - curr_hallway_pos) + (4 - j); // (cost to move along hallway) + (cost to go from room to hallway).
                            let new_cost = cost + positions_moved * step_cost(amphipod);

                            possible_configurations.push((hallway.clone(), rooms.clone(), new_cost));

                            // Restore the hallway.
                            hallway[k] = '.';
                        }

                        // From current hallway position to the beginning.
                        for k in iter::once(0).chain((1..curr_hallway_pos).step_by(2)).rev() {
                            if hallway[k] != '.' {
                                // We found an amphipod along the way. Stop trying positions now because we can't go past this amphipod.
                                break;
                            }

                            // Temporarily add this amphipod so we can clone the hallway and push it to a configuration to try.
                            hallway[k] = amphipod;

                            let positions_moved = (curr_hallway_pos - k) + (4 - j); // (cost to move along hallway) + (cost to go from room to hallway).
                            let new_cost = cost + positions_moved * step_cost(amphipod);

                            possible_configurations.push((hallway.clone(), rooms.clone(), new_cost));

                            // Restore the hallway.
                            hallway[k] = '.';
                        }

                        rooms[i][j] = amphipod;

                        // We already moved an amphipod from the room, so don't move the other one in this run.
                        break;
                    }
                }
            }

            // Then we attempt moving amphipods from the hallway back to their rooms if they can.
            for i in 0..11 {
                if let amphipod @ 'A'..='D' = hallway[i] {
                    let amphipod_room = room(amphipod);

                    let room_has_same_amphipods = (0..4).all(|j| rooms[amphipod_room][j] == '.' || rooms[amphipod_room][j] == amphipod);

                    if rooms[amphipod_room][3] == '.' && room_has_same_amphipods {
                        // Amphipod can move into the room, check if path on hallway is available too.
                        let room_hallway_pos = 2 + amphipod_room * 2;
                        let mut path = if i < room_hallway_pos {
                            // Need to go to the right.
                            i + 1..=room_hallway_pos
                        } else {
                            // Need to go to the left. Order doesn't matter here because all positions will need to be empty.
                            room_hallway_pos..=i - 1
                        };

                        if !path.all(|p| hallway[p] == '.') {
                            // Path not clear, let's keep sweeping the hallway for possibilities.
                            continue;
                        }

                        let room_pos = (0..4).filter(|j| rooms[amphipod_room][*j] == '.').min().unwrap();
                        let positions_moved = if i < room_hallway_pos {
                            (room_hallway_pos - i) + (4 - room_pos)
                        } else {
                            (i - room_hallway_pos) + (4 - room_pos)
                        };

                        let new_cost = cost + positions_moved * step_cost(amphipod);

                        hallway[i] = '.';
                        rooms[amphipod_room][room_pos] = amphipod;

                        possible_configurations.push((hallway.clone(), rooms.clone(), new_cost));

                        rooms[amphipod_room][room_pos] = '.';
                        hallway[i] = amphipod;
                    }
                }
            }

            // Naturally, every impossible case will be dropped.
        }

        result
    }

    fn print_room(&self) {
        println!("#############");
        println!("#{}#", self.hallway.iter().collect::<String>());
        println!("###{}#{}#{}#{}###", self.rooms[0][3], self.rooms[1][3], self.rooms[2][3], self.rooms[3][3]);
        println!("  #{}#{}#{}#{}#  ", self.rooms[0][2], self.rooms[1][2], self.rooms[2][2], self.rooms[3][2]);
        println!("  #{}#{}#{}#{}#  ", self.rooms[0][1], self.rooms[1][1], self.rooms[2][1], self.rooms[3][1]);
        println!("  #{}#{}#{}#{}#  ", self.rooms[0][0], self.rooms[1][0], self.rooms[2][0], self.rooms[3][0]);
        println!("  #########  ");
    }

    pub fn output(&mut self) {
        self.print_room();

        println!("Part 2: {}", self.smallest_organization_energy());
        println!("{}", usize::MAX);
    }
}