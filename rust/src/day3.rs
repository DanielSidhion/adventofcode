pub struct Submarine {
    popularity : Vec<i32>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            popularity: vec![0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        }
    }

    pub fn on_new_result(&mut self, result : &str) {
        result.chars().map(|x| x.to_digit(10).unwrap() as i32).enumerate().for_each(|(i, val)| self.popularity[i] += val * 2 - 1);
    }

    pub fn power_consumption(&self) -> u32 {
        let (_, gamma) = self.popularity.iter().map(|x| if *x > 0 {1u32} else {0u32}).fold((11, 0), |(i, tot), val| (i - 1, tot + (val << i)));
        let epsilon = !gamma & 0b111111111111;

        return gamma * epsilon;
    }
}