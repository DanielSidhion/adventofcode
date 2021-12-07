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

    fn min_required_fuel_for_calculation(&self, calculation: impl Fn(i32, (&i32, &i32)) -> i32) -> i32 {
        (self.min_crab_position..=self.max_crab_position)
            .map(|curr_pos| {
                self.crab_positions.iter().map(|entry| calculation(curr_pos, entry)).sum()
            })
            .min()
            .unwrap()
    }

    pub fn output(&mut self) {
        let min_assumed_fuel = self.min_required_fuel_for_calculation(assumed_fuel_for_crab_pos);
        let min_real_fuel = self.min_required_fuel_for_calculation(real_fuel_for_crab_pos);

        println!("Part 1: {}", min_assumed_fuel);
        println!("Part 2: {}", min_real_fuel);
    }
}

fn assumed_fuel_for_crab_pos(curr_pos: i32, (&crab_pos, &num_crabs): (&i32, &i32)) -> i32 {
    (curr_pos - crab_pos).abs() * num_crabs
}

fn real_fuel_for_crab_pos(curr_pos: i32, (&crab_pos, &num_crabs): (&i32, &i32)) -> i32 {
    let diff = (curr_pos - crab_pos).abs();

    num_crabs * (diff * (diff + 1)) / 2
}