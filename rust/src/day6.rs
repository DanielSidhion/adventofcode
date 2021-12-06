pub struct Submarine {
    fish_timers: Vec<u64>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            fish_timers: vec![0; 9],
        }
    }

    pub fn on_input(&mut self, result: &str) {
        result.split(",").map(|x| x.parse().unwrap()).for_each(|x: usize| self.fish_timers[x] += 1);
    }

    fn simulate_one_day(&mut self) {
        let mut new_timers = vec![0; 9];

        // New lanternfish created have a timer of 8 initially.
        new_timers[8] = self.fish_timers[0];
        // The lanternfish that spawned the new ones go back to a timer of 6.
        new_timers[6] = self.fish_timers[0];

        for i in 1..self.fish_timers.len() {
            new_timers[i - 1] += self.fish_timers[i];
        }

        self.fish_timers = new_timers;
    }

    pub fn output(&mut self) {
        for _ in 0..80 {
            self.simulate_one_day();
        }

        let total_fish_after_80_days: u64 = self.fish_timers.iter().sum();

        for _ in 0..(256-80) {
            self.simulate_one_day();
        }

        let total_fish_after_256_days: u64 = self.fish_timers.iter().sum();

        println!("Part 1: {}", total_fish_after_80_days);
        println!("Part 2: {}", total_fish_after_256_days);
    }
}