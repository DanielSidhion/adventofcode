use std::collections::HashMap;

#[derive(Eq, Hash, PartialEq)]
struct Universe {
    positions: (u8, u8),
    scores: (u8, u8),
}

impl Universe {
    pub fn new(positions: (u8, u8), scores: (u8, u8)) -> Self {
        Universe { positions, scores }
    }
}

pub struct Submarine {
    positions: (u8, u8),
    scores: (u32, u32),
    die_rolls: u32,
    universe_scores: (u64, u64),
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            positions: (0, 0),
            scores: (0, 0),
            die_rolls: 0,
            universe_scores: (0, 0),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        if self.positions.0 == 0 {
            self.positions.0 = result.strip_prefix("Player 1 starting position: ").unwrap().parse::<u8>().unwrap() - 1;
        } else {
            self.positions.1 = result.strip_prefix("Player 2 starting position: ").unwrap().parse::<u8>().unwrap() - 1;
        }
    }

    // Returns the number of positions to move forward after all the complete rotations around the board.
    fn roll_d100(&mut self) -> u8 {
        let res = 1 + (self.die_rolls % 100);
        self.die_rolls += 1;
        (res % 10) as u8
    }

    fn run_practice_game(&mut self) {
        let mut game_positions = self.positions;

        loop {
            let p1_dice = self.roll_d100() + self.roll_d100() + self.roll_d100();
            game_positions.0 = (game_positions.0 + p1_dice) % 10;
            self.scores.0 += (1 + game_positions.0) as u32;

            if self.scores.0 >= 1000 {
                return;
            }

            let p2_dice = self.roll_d100() + self.roll_d100() + self.roll_d100();
            game_positions.1 = (game_positions.1 + p2_dice) % 10;
            self.scores.1 += (1 + game_positions.1) as u32;

            if self.scores.1 >= 1000 {
                return;
            }
        }
    }

    fn run_dirac_game(&mut self) {
        let dirac_possibilities = generate_dirac_universes(3);

        let mut universes: HashMap<Universe, u64> = HashMap::new();
        let starting_universe = Universe::new(self.positions, (0, 0));
        universes.insert(starting_universe, 1);

        loop {
            if universes.len() > 500_000 {
                println!("WARNING");
                return;
            }

            let mut new_universes: HashMap<Universe, u64> = HashMap::new();

            for (dice_sum, possibilities) in dirac_possibilities.iter().enumerate() {
                for (universe, amount) in universes.iter() {
                    let p1_location = (universe.positions.0 + (dice_sum as u8) + 3) % 10;
                    let p1_score = universe.scores.0 + p1_location + 1;

                    if p1_score >= 21 {
                        self.universe_scores.0 += amount * possibilities;
                        continue;
                    }

                    let new_universe = Universe::new((p1_location, universe.positions.1), (p1_score, universe.scores.1));
                    *new_universes.entry(new_universe).or_default() += amount * possibilities;
                }
            }

            if new_universes.len() == 0 {
                return;
            }

            universes = new_universes;

            new_universes = HashMap::new();

            for (dice_sum, possibilities) in dirac_possibilities.iter().enumerate() {
                for (universe, amount) in universes.iter() {
                    let p2_location = (universe.positions.1 + (dice_sum as u8) + 3) % 10;
                    let p2_score = universe.scores.1 + p2_location + 1;

                    if p2_score >= 21 {
                        self.universe_scores.1 += amount * possibilities;
                        continue;
                    }

                    let new_universe = Universe::new((universe.positions.0, p2_location), (universe.scores.0, p2_score));
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
        self.run_practice_game();

        let loser_score = self.scores.0.min(self.scores.1);

        println!("Part 1: {}", loser_score * self.die_rolls);

        self.run_dirac_game();

        let winner_universes = self.universe_scores.0.max(self.universe_scores.1);

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