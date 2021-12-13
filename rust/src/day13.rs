enum InputReadState {
    ReadingDots,
    ReadingFoldInstructions,
}

pub struct Submarine {
    input_read_state: InputReadState,
    dots: Vec<(u32, u32)>,
    num_folds: u32,
    num_points_after_first_fold: usize,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            input_read_state: InputReadState::ReadingDots,
            dots: Vec::new(),
            num_folds: 0,
            num_points_after_first_fold: 0,
        }
    }

    pub fn on_input(&mut self, result: &str) {
        match self.input_read_state {
            InputReadState::ReadingDots => {
                if result == "" {
                    self.input_read_state = InputReadState::ReadingFoldInstructions;
                    return;
                }

                let mut coords = result.split(",").map(|x| x.parse().unwrap());
                let x: u32 = coords.next().unwrap();
                let y: u32 = coords.next().unwrap();

                self.dots.push((x, y));
            }
            InputReadState::ReadingFoldInstructions => {
                let mut instructions = result.strip_prefix("fold along ").unwrap().split("=");
                let axis = instructions.next().unwrap();
                let coord: u32 = instructions.next().unwrap().parse().unwrap();

                self.fold(axis, coord);
            }
        }
    }

    fn fold(&mut self, axis: &str, coord: u32) {
        self.num_folds += 1;

        match axis {
            "x" => {
                let points_beyond_fold_line = self.dots.iter().filter(|(x, _)| *x > coord);
                let mut folded_points: Vec<(u32, u32)> = points_beyond_fold_line.map(|(x, y)| (coord - (*x - coord), *y)).collect();
                self.dots.retain(|(x, _)| *x < coord); // Always guaranteed that the fold line won't have dots, so we can ignore cases where `*x == cord`.
                self.dots.append(&mut folded_points);
            }
            "y" => {
                let points_beyond_fold_line = self.dots.iter().filter(|(_, y)| *y > coord);
                let mut folded_points: Vec<(u32, u32)> = points_beyond_fold_line.map(|(x, y)| (*x, coord - (*y - coord))).collect();
                self.dots.retain(|(_, y)| *y < coord); // Always guaranteed that the fold line won't have dots, so we can ignore cases where `*y == cord`.
                self.dots.append(&mut folded_points);
            }
            _ => panic!("Got an invalid axis!")
        }

        // We always sort by y first because it'll be important later when we print the dots.
        self.dots.sort_unstable_by_key(|(x, y)| (*y, *x));
        self.dots.dedup();

        if self.num_folds == 1 {
            self.num_points_after_first_fold = self.dots.len();
        }
    }

    fn print_dots(&mut self) {
        let max_x = *self.dots.iter().map(|(x, _)| x).max().unwrap();
        let max_y = *self.dots.iter().map(|(_, y)| y).max().unwrap();

        let mut next_dot = self.dots.iter().peekable();

        for y in 0..=max_y {
            for x in 0..=max_x {
                if matches!(next_dot.peek(), Some(&&(nx, ny)) if nx == x && ny == y) {
                    print!("#");
                    next_dot.next();
                } else {
                    print!(".");
                }
            }
            println!("");
        }
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.num_points_after_first_fold);
        println!("Part 2:");
        self.print_dots();
    }
}