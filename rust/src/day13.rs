enum InputReadState {
    ReadingDots,
    ReadingFoldInstructions,
}

pub struct Submarine {
    input_read_state: InputReadState,
    dots: Vec<(u32, u32)>,
    num_folds: u32,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            input_read_state: InputReadState::ReadingDots,
            dots: Vec::new(),
            num_folds: 0,
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
                // Needed for part 1.
                if self.num_folds == 1 {
                    return;
                }

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

        self.dots.sort_unstable();
        self.dots.dedup();
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.dots.len());
    }
}