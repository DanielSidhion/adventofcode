pub struct Submarine {
    initialization_cubes: Vec<bool>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            initialization_cubes: vec![false; 101 * 101 * 101],
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let instructions: Vec<_> = result.split(" ").collect();

        let turn_on = instructions[0] == "on";
        let coords: Vec<Vec<i32>> = instructions[1].split(",").map(|d| d[2..].split("..").map(|n| n.parse().unwrap()).collect::<Vec<_>>()).collect();

        self.reboot(turn_on, coords);
    }

    fn reboot(&mut self, turn_on: bool, coords: Vec<Vec<i32>>) {
        if let [x_min, x_max] = coords[0][..] {
            if let [y_min, y_max] = coords[1][..] {
                if let [z_min, z_max] = coords[2][..] {
                    // Only doing action on intervals that fall entirely within -50 and 50.
                    if x_min < -50 || x_max > 50 || y_min < -50 || y_max > 50 || z_min < -50 || z_max > 50 {
                        return;
                    }

                    for x in x_min..=x_max {
                        for y in y_min..=y_max {
                            for z in z_min..=z_max {
                                let nx = x + 50;
                                let ny = y + 50;
                                let nz = z + 50;
                                let index = (nz + ny * 101 + nx * 101 * 101) as usize;

                                self.initialization_cubes[index] = turn_on;
                            }
                        }
                    }
                }
            }
        }
    }

    fn cubes_on(&self) -> u32 {
        self.initialization_cubes.iter().map(|c| *c as u32).sum()
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.cubes_on());
    }
}