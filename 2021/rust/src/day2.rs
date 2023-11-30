pub struct Submarine {
    pub first_part_depth : u32,
    pub horizontal_position : u32,
    pub depth : u32,
    aim : u32,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            horizontal_position: 0,
            first_part_depth: 0,
            depth: 0,
            aim: 0,
        }
    }

    pub fn on_input(&mut self, result : &str) {
        let movement : Vec<&str> = result.split(" ").collect();
        let amount : u32 = movement[1].parse().unwrap();

        match movement[0] {
            "forward" => {
                self.horizontal_position += amount;
                self.depth += self.aim * amount;
            }
            "down" => {
                self.first_part_depth += amount;
                self.aim += amount;
            }
            "up" => {
                self.first_part_depth -= amount;
                self.aim -= amount;
            }
            _ => panic!("Unknown movement"),
        }
    }

    pub fn output(&self) {
        println!("Part 1: {}", self.horizontal_position * self.first_part_depth);
        println!("Part 2: {}", self.horizontal_position * self.depth);
    }
}