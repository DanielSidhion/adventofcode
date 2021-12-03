pub struct Submarine {
    diagnostic_report: Vec<u32>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            diagnostic_report: Vec::new(),
        }
    }

    pub fn on_new_result(&mut self, result : &str) {
        self.diagnostic_report.push(u32::from_str_radix(result, 2).unwrap());
    }

    pub fn compute_report(&self) -> (u32, u32)
    {
        let mut gamma = 0;

        let gamma_nums = self.diagnostic_report.iter();
        let mut oxygen_nums = self.diagnostic_report.clone();
        let mut co2_nums = self.diagnostic_report.clone();
        let mut curr_digit = 11;

        while curr_digit >= 0 {
            if oxygen_nums.len() != 1 {
                let oxygen_digit = most_popular_digit(oxygen_nums.iter(), curr_digit);
                oxygen_nums = oxygen_nums.into_iter().filter(|x| x & (1 << curr_digit) == oxygen_digit << curr_digit).collect();
            }

            if co2_nums.len() != 1 {
                let co2_digit = 1 ^ most_popular_digit(co2_nums.iter(), curr_digit);
                co2_nums = co2_nums.into_iter().filter(|x| x & (1 << curr_digit) == co2_digit << curr_digit).collect();
            }

            let gamma_digit = most_popular_digit(gamma_nums.clone(), curr_digit);
            gamma += gamma_digit << curr_digit;

            curr_digit -= 1;
        }

        let epsilon = !gamma & 0b111111111111;
        let oxygen_generator = oxygen_nums[0];
        let co2_scrubber = co2_nums[0];

        return (gamma * epsilon, oxygen_generator * co2_scrubber);
    }
}

fn most_popular_digit<'a, T: Iterator<Item = &'a u32>>(it: T, digit_position: i32) -> u32 {
    (it.fold(0i32, |tot, val| tot + ((*val as i32 & (1 << digit_position)) >> digit_position) * 2 - 1) >= 0) as u32
}