pub struct Submarine {
    pub horizontal_position : i32,
    pub depth : i32,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            horizontal_position: 0,
            depth: 0,
        }
    }

    pub fn on_new_result(&mut self, result : &str) {
        let movement : Vec<&str> = result.split(" ").collect();
        let amount : i32 = movement[1].parse().unwrap();

        match movement[0] {
            "forward" => self.horizontal_position += amount,
            "down" => self.depth += amount,
            "up" => self.depth -= amount,
            _ => panic!("Unknown movement"),
        }
    }
}