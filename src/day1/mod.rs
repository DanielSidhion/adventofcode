pub struct DepthIncrementScanner {
    first_measurement : bool,
    last_measurement : u32,
    pub num_increments : u32,
}

impl DepthIncrementScanner {
    pub fn new() -> Self {
        Self {
            first_measurement: true,
            last_measurement: 0,
            num_increments: 0,
        }
    }

    pub fn on_new_result(&mut self, result : &str) {
        let measurement = result.parse().unwrap();

        if !self.first_measurement && measurement > self.last_measurement {
            self.num_increments += 1;
        }

        self.last_measurement = measurement;
        self.first_measurement = false;
    }
}