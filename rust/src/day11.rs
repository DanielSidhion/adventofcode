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

    fn simulate_step(&mut self) {
        for x in 0..self.iwidth {
            for y in 0..self.iheight {
                self.increase_energy_level(x, y);
            }
        }

        // Resetting any place that flashed.
        for x in 0..self.width {
            for y in 0..self.height {
                if self.flashed[y][x] {
                    self.flashed[y][x] = false;
                    self.energy_levels[y][x] = 0;
                }
            }
        }
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

        for i in -1..=1 {
            for j in -1..=1 {
                self.increase_energy_level(x + i, y + j);
            }
        }
    }

    pub fn output(&mut self) {
        for _ in 0..100 {
            self.simulate_step();
        }

        println!("Part 1: {}", self.total_flashes);
    }
}