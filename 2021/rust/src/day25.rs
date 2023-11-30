use core::str::FromStr;

#[derive(Clone)]
enum SeaCucumber {
    East,
    South,
    None,
}

impl FromStr for SeaCucumber {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            ">" => Ok(Self::East),
            "v" => Ok(Self::South),
            _ => Ok(Self::None),
        }
    }
}

impl SeaCucumber {
    pub fn print(&self) {
        match self {
            Self::East => print!(">"),
            Self::South => print!("v"),
            Self::None => print!("."),
        }
    }
}

pub struct Submarine {
    seafloor: Vec<Vec<SeaCucumber>>,
    steps: u32,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            seafloor: Vec::new(),
            steps: 0,
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let seafloor_line: Vec<SeaCucumber> = result.chars().map(|c| c.to_string().parse().unwrap()).collect();
        self.seafloor.push(seafloor_line);
    }

    fn run_step(&mut self) -> bool {
        self.steps += 1;

        let height = self.seafloor.len();
        let width = self.seafloor[0].len();

        let mut new_seafloor = self.seafloor.clone();

        let mut moved = false;

        for y in 0..height {
            for x in 0..width {
                if let SeaCucumber::East = self.seafloor[y][x] {
                    let next_x = (x + 1) % width;

                    if let SeaCucumber::None = self.seafloor[y][next_x] {
                        new_seafloor[y][next_x] = SeaCucumber::East;
                        new_seafloor[y][x] = SeaCucumber::None;
                        moved = true;
                    }
                }
            }
        }

        self.seafloor = new_seafloor;
        new_seafloor = self.seafloor.clone();

        for y in 0..height {
            for x in 0..width {
                if let SeaCucumber::South = self.seafloor[y][x] {
                    let next_y = (y + 1) % height;

                    if let SeaCucumber::None = self.seafloor[next_y][x] {
                        new_seafloor[next_y][x] = SeaCucumber::South;
                        new_seafloor[y][x] = SeaCucumber::None;
                        moved = true;
                    }
                }
            }
        }

        self.seafloor = new_seafloor;

        moved
    }

    fn print_seafloor(&self) {
        self.seafloor.iter().for_each(|row| {
            row.iter().for_each(|c| c.print());
            println!();
        });
        println!();
    }

    pub fn output(&mut self) {
        while self.run_step() {}

        println!("Part 1: {}", self.steps);
    }
}