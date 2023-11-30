pub struct Submarine {
    latest_measurements: Vec<u32>,
    pub num_increments : u32,
    pub num_three_measurement_increments : u32,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            latest_measurements: Vec::new(),
            num_increments: 0,
            num_three_measurement_increments: 0,
        }
    }

    pub fn on_input(&mut self, result : &str) {
        let measurement = result.parse().unwrap();

        if let Some(last) = self.latest_measurements.last()
        {
            if measurement > *last {
                self.num_increments += 1;
            }
        }

        if self.latest_measurements.len() == 3 {
            let first = self.latest_measurements.remove(0);

            // The other two elements are common to both 3-measurement windows, so we don't need to do anything with them.

            if measurement > first {
                self.num_three_measurement_increments += 1;
            }
        }

        self.latest_measurements.push(measurement);
    }

    pub fn output(&self) {
        println!("Part 1: {}", self.num_increments);
        println!("Part 2: {}", self.num_three_measurement_increments);
    }
}