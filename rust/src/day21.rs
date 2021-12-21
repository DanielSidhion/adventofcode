pub struct Submarine {
    positions: (u32, u32),
    scores: (u32, u32),
    die_rolls: u32,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            positions: (0, 0),
            scores: (0, 0),
            die_rolls: 0,
        }
    }

    pub fn on_input(&mut self, result: &str) {
        if self.positions.0 == 0 {
            self.positions.0 = result.strip_prefix("Player 1 starting position: ").unwrap().parse::<u32>().unwrap() - 1;
        } else {
            self.positions.1 = result.strip_prefix("Player 2 starting position: ").unwrap().parse::<u32>().unwrap() - 1;
        }
    }

    fn roll_d100(&mut self) -> u32 {
        let res = 1 + (self.die_rolls % 100);
        self.die_rolls += 1;
        res
    }

    fn run_game(&mut self) {
        loop {
            let p1_dice = self.roll_d100() + self.roll_d100() + self.roll_d100();
            self.positions.0 = (self.positions.0 + p1_dice) % 10;
            self.scores.0 += 1 + self.positions.0;

            if self.scores.0 >= 1000 {
                return;
            }

            let p2_dice = self.roll_d100() + self.roll_d100() + self.roll_d100();
            self.positions.1 = (self.positions.1 + p2_dice) % 10;
            self.scores.1 += 1 + self.positions.1;

            if self.scores.1 >= 1000 {
                return;
            }
        }
    }

    pub fn output(&mut self) {
        self.run_game();

        let loser_score = self.scores.0.min(self.scores.1);

        println!("Part 1: {}", loser_score * self.die_rolls);
    }
}