const EASY_LENGTHS: [usize; 4] = [2, 3, 4, 7];

pub struct Submarine {
    easy_digits: usize,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            easy_digits: 0,
        }
    }

    pub fn on_input(&mut self, result: &str) {
        self.easy_digits += result.split(" | ").last().unwrap().split(" ").map(str::len).filter(|x| EASY_LENGTHS.contains(x)).count();
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.easy_digits);
    }
}