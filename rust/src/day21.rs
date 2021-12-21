use std::collections::HashMap;

#[derive(Clone, Eq, Hash, PartialEq)]
struct Universe {
    positions: [u8; 2],
    scores: [u16; 2],
    next_player: usize,
}

impl Universe {
    pub fn new(positions: [u8; 2], scores: [u16; 2]) -> Self {
        Universe { positions, scores, next_player: 0 }
    }
}

pub struct Submarine {
    starting_positions: [u8; 2],
    d100_rolls: u32,
    universe_scores: [u64; 2],
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            starting_positions: [0, 0],
            d100_rolls: 0,
            universe_scores: [0, 0],
        }
    }

    pub fn on_input(&mut self, result: &str) {
        if self.starting_positions[0] == 0 {
            self.starting_positions[0] = result.strip_prefix("Player 1 starting position: ").unwrap().parse::<u8>().unwrap() - 1;
        } else {
            self.starting_positions[1] = result.strip_prefix("Player 2 starting position: ").unwrap().parse::<u8>().unwrap() - 1;
        }
    }

    // Returns the number of positions to move forward after all the complete rotations around the board.
    fn roll_d100(&mut self) -> u8 {
        let res = 1 + (self.d100_rolls % 100);
        self.d100_rolls += 1;
        (res % 10) as u8
    }

    fn run_practice_game(&mut self) -> Universe {
        let mut universe = Universe::new(self.starting_positions.clone(), [0, 0]);

        loop {
            universe.positions[universe.next_player] += self.roll_d100() + self.roll_d100() + self.roll_d100();
            universe.positions[universe.next_player] %= 10;
            universe.scores[universe.next_player] += (1 + universe.positions[universe.next_player]) as u16;

            if universe.scores[universe.next_player] >= 1000 {
                return universe;
            }

            universe.next_player = (universe.next_player + 1) % 2;
        }
    }

    fn run_dirac_game(&mut self) {
        let dirac_possibilities = generate_dirac_universes(3);

        let mut universes: HashMap<Universe, u64> = HashMap::new();
        let starting_universe = Universe::new(self.starting_positions, [0, 0]);
        universes.insert(starting_universe, 1);

        loop {
            let mut new_universes: HashMap<Universe, u64> = HashMap::new();

            for (dice_sum, possibilities) in dirac_possibilities.iter().enumerate() {
                for (u, amount) in universes.iter() {
                    let new_position = (u.positions[u.next_player] + (dice_sum as u8) + 3) % 10;
                    let new_score = u.scores[u.next_player] + (new_position as u16) + 1;

                    if new_score >= 21 {
                        self.universe_scores[u.next_player] += amount * possibilities;
                        continue;
                    }

                    let mut new_universe = u.clone();
                    new_universe.positions[u.next_player] = new_position;
                    new_universe.scores[u.next_player] = new_score;
                    new_universe.next_player = (new_universe.next_player + 1) % 2;
                    *new_universes.entry(new_universe).or_default() += amount * possibilities;
                }
            }

            if new_universes.len() == 0 {
                return;
            }

            universes = new_universes;
        }
    }

    pub fn output(&mut self) {
        let practice_universe = self.run_practice_game();

        let loser_score = *practice_universe.scores.iter().min().unwrap() as u32;
        println!("Part 1: {}", loser_score * self.d100_rolls);

        self.run_dirac_game();

        let winner_universes = self.universe_scores.iter().max().unwrap();
        println!("Part 2: {}", winner_universes);
    }
}

fn generate_dirac_universes(num_rolls: usize) -> Vec<u64> {
    let total_sum_possibilities = num_rolls * 2 + 1;
    let mut result = vec![0; total_sum_possibilities];

    add_dirac_possibility(num_rolls as u64, 3, 0, &mut result);

    result
}

fn add_dirac_possibility(min_score: u64, rolls_remaining: usize, curr_score: u64, possibilities: &mut Vec<u64>) {
    if rolls_remaining == 0 {
        possibilities[(curr_score - min_score) as usize] += 1;
        return;
    }

    add_dirac_possibility(min_score, rolls_remaining - 1, curr_score + 1, possibilities);
    add_dirac_possibility(min_score, rolls_remaining - 1, curr_score + 2, possibilities);
    add_dirac_possibility(min_score, rolls_remaining - 1, curr_score + 3, possibilities);
}