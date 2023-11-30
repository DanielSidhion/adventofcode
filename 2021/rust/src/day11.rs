pub struct Submarine {
    energy_levels: Vec<Vec<u32>>,
    flashed: Vec<Vec<bool>>,
    total_flashes: u32,
    width: usize,
    iwidth: i32,
    height: usize,
    iheight: i32,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            energy_levels: Vec::new(),
            flashed: Vec::new(),
            total_flashes: 0,
            width: 0,
            iwidth: 0,
            height: 0,
            iheight: 0,
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let energies: Vec<u32> = result.chars().map(|c| c.to_digit(10).unwrap()).collect();

        if self.width == 0 {
            self.width = energies.len();
            self.iwidth = self.width as i32;
        }

        self.energy_levels.push(energies);
        self.flashed.push(vec![false; self.width]);

        self.height += 1;
        self.iheight += 1;
    }

    fn simulate_step(&mut self) -> bool {
        for y in 0..self.iheight {
            for x in 0..self.iwidth {
                self.increase_energy_level(x, y);
            }
        }

        let mut all_flashed_this_turn = true;

        // Resetting any place that flashed.
        for y in 0..self.height {
            for x in 0..self.width {
                if self.flashed[y][x] {
                    self.flashed[y][x] = false;
                    self.energy_levels[y][x] = 0;
                } else {
                    all_flashed_this_turn = false;
                }
            }
        }

        all_flashed_this_turn
    }

    fn increase_energy_level(&mut self, x: i32, y: i32) {
        if x < 0 || x >= self.iwidth || y < 0 || y >= self.iheight {
            return;
        }

        self.energy_levels[y as usize][x as usize] += 1;

        if self.energy_levels[y as usize][x as usize] > 9 {
            self.flash(x, y);
        }
    }

    fn flash(&mut self, x: i32, y: i32) {
        if self.flashed[y as usize][x as usize] {
            return;
        }

        self.flashed[y as usize][x as usize] = true;
        self.total_flashes += 1;

        for j in -1..=1 {
            for i in -1..=1 {
                self.increase_energy_level(x + i, y + j);
            }
        }
    }

    pub fn output(&mut self) {
        let mut i = 0;
        let mut total_flashes_after_100_steps = 0;
        let mut first_synchronized_flash = 0;

        while total_flashes_after_100_steps == 0 || first_synchronized_flash == 0 {
            i += 1;

            let all_flashed = self.simulate_step();

            if i == 100 {
                total_flashes_after_100_steps = self.total_flashes;
            }

            if all_flashed {
                first_synchronized_flash = i;
            }
        }

        println!("Part 1: {}", total_flashes_after_100_steps);
        println!("Part 2: {}", first_synchronized_flash);
    }
}