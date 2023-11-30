pub struct Submarine {
    enhacement_algorithm: Vec<bool>,
    input_image: Vec<Vec<bool>>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            enhacement_algorithm: Vec::new(),
            input_image: Vec::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        if self.enhacement_algorithm.len() == 0 {
            self.enhacement_algorithm = result.chars().map(|c| c == '#').collect();
            return;
        }

        if result.is_empty() {
            return;
        }

        let mut curr_line: Vec<bool> = vec![false, false].into_iter().chain(result.chars().map(|c| c == '#')).collect();
        curr_line.extend([false, false]);

        if self.input_image.len() == 0 {
            self.input_image.push(vec![false; curr_line.len()]);
            self.input_image.push(vec![false; curr_line.len()]);
        }

        self.input_image.push(curr_line);
    }

    fn finish_padding(&mut self) {
        self.input_image.push(vec![false; self.input_image[0].len()]);
        self.input_image.push(vec![false; self.input_image[0].len()]);
    }

    fn extend_padding(&mut self) {
        let padding_value = self.input_image[0][0];

        self.input_image.iter_mut().for_each(|row| {
            row.insert(0, padding_value);
            row.push(padding_value);
        });

        let width = self.input_image[0].len();

        self.input_image.insert(0, vec![padding_value; width]);
        self.input_image.push(vec![padding_value; width]);
    }

    fn enhance(&mut self) {
        // We skip the outer layer of padding because it will always have the same value, but we need to go through the inner layer of padding. If it changes, we must expand the padding.
        let height = self.input_image.len() - 2;
        let width = self.input_image[0].len() - 2;

        // Figuring out the padding value.
        let padding_value = if self.input_image[0][0] {
            self.enhacement_algorithm[511]
        } else {
            self.enhacement_algorithm[0]
        };

        let mut result = vec![vec![padding_value; width + 2]; height + 2];
        let mut padding_changed = false;

        for y in 1..=height {
            for x in 1..=width {
                let num =
                    (self.input_image[y - 1][x - 1] as usize) << 8 |
                    (self.input_image[y - 1][x] as usize) << 7 |
                    (self.input_image[y - 1][x + 1] as usize) << 6 |
                    (self.input_image[y][x - 1] as usize) << 5 |
                    (self.input_image[y][x] as usize) << 4 |
                    (self.input_image[y][x + 1] as usize) << 3 |
                    (self.input_image[y + 1][x - 1] as usize) << 2 |
                    (self.input_image[y + 1][x] as usize) << 1 |
                    (self.input_image[y + 1][x + 1] as usize);

                result[y][x] = self.enhacement_algorithm[num];

                // If padding changed value, mark the flag so we can expand the padding.
                if x == 1 || x == width || y == 1 || y == height {
                    padding_changed = padding_changed || result[y][x] != padding_value;
                }
            }
        }

        self.input_image = result;

        if padding_changed {
            self.extend_padding();
        }
    }

    fn lit_pixels(&self) -> u32 {
        self.input_image.iter().map(|row| row.iter().fold(0, |s, p| s + (*p as u32))).sum()
    }

    fn _print_image(&self) {
        self.input_image.iter().for_each(|row| {
            row.iter().for_each(|p| {
                print!("{}", if *p { "#" } else { "." });
            });
            println!()
        });
    }

    pub fn output(&mut self) {
        self.finish_padding();

        for _ in 0..2 {
            self.enhance();
        }

        println!("Part 1: {}", self.lit_pixels());

        for _ in 0..48 {
            self.enhance();
        }

        println!("Part 2: {}", self.lit_pixels());
    }
}