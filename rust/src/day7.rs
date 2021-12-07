use std::collections::HashMap;

pub struct Submarine {
    crab_positions: HashMap<i32, i32>,
    min_crab_position: i32,
    max_crab_position: i32,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            crab_positions: HashMap::new(),
            min_crab_position: i32::MAX,
            max_crab_position: 0,
        }
    }

    pub fn on_input(&mut self, result: &str) {
        result.split(",")
            .map(|x| x.parse().unwrap())
            .for_each(|x: i32| {
                if x < self.min_crab_position {
                    self.min_crab_position = x;
                }

                if x > self.max_crab_position {
                    self.max_crab_position = x;
                }

                *self.crab_positions.entry(x).or_default() += 1;
            });
    }

    fn min_assumed_fuel_for_positioning(&self) -> i32 {
        (self.min_crab_position..=self.max_crab_position)
            .map(|currpos| {
                self.crab_positions.iter().fold(0, |fuel, (pos, num_crabs)| fuel + (currpos - pos).abs() * num_crabs)
            })
            .min()
            .unwrap()
    }

    fn min_real_fuel_for_positioning(&self) -> i32 {
        (self.min_crab_position..=self.max_crab_position)
            .map(|currpos| {
                self.crab_positions.iter().fold(0, |fuel, (pos, num_crabs)| fuel + fuel_for_pos_difference(currpos - pos) * num_crabs)
            })
            .min()
            .unwrap()
    }

    pub fn output(&mut self) {
        let min_assumed_fuel = self.min_assumed_fuel_for_positioning();
        let min_real_fuel = self.min_real_fuel_for_positioning();

        println!("Part 1: {}", min_assumed_fuel);
        println!("Part 2: {}", min_real_fuel);
    }
}

fn fuel_for_pos_difference(mut pos_difference: i32) -> i32 {
    pos_difference = pos_difference.abs();

    (pos_difference * (pos_difference + 1)) / 2
}