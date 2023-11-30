pub struct Submarine {
    crab_positions: Vec<i32>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            crab_positions: Vec::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        self.crab_positions = result.split(",").map(|x| x.parse().unwrap()).collect();
        // Needed for part 1.
        self.crab_positions.sort_unstable();
    }

    fn min_assumed_fuel(&self) -> i32 {
        let optimal_position = self.crab_positions[self.crab_positions.len() / 2];

        self.crab_positions.iter().map(|entry| (optimal_position - entry).abs()).sum()
    }

    fn min_real_fuel(&self) -> i32 {
        let mean = self.crab_positions.iter().sum::<i32>() / self.crab_positions.len() as i32;

        // The optimal position is guaranteed to be within (-0.5, 0.5) of the mean, so to be safe we'll check the 3 values around the mean.
        ((mean - 1)..=(mean + 1)).map(|pos| self.real_fuel_for_pos(pos)).min().unwrap()
    }

    fn real_fuel_for_pos(&self, pos: i32) -> i32 {
        self.crab_positions.iter().map(|entry| {
            let diff = (entry - pos).abs();
            (diff * (diff + 1)) / 2
        }).sum()
    }

    pub fn output(&mut self) {
        let min_assumed_fuel = self.min_assumed_fuel();
        let min_real_fuel = self.min_real_fuel();

        println!("Part 1: {}", min_assumed_fuel);
        println!("Part 2: {}", min_real_fuel);
    }
}