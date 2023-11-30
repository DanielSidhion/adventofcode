pub struct Submarine {
    heightmap: Vec<Vec<u32>>,
    visited: Vec<Vec<bool>>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            heightmap: Vec::new(),
            visited: Vec::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        self.heightmap.push(result.chars().map(|c| c.to_digit(10).unwrap()).collect());
        self.visited.push(vec![false; self.heightmap[0].len()]);
    }

    fn low_points(&self) -> Vec<(usize, usize, u32)> {
        let mut result = Vec::new();

        for i in 0..self.heightmap.len() {
            let row = &self.heightmap[i];

            for j in 0..row.len() {
                let height = row[j];

                // If any of the conditions below are true, the point is not a low point, and we won't get to the sum below.
                if j > 0 && row[j - 1] <= height {
                    continue;
                }
                if j < row.len() - 1 && row[j + 1] <= height {
                    continue;
                }
                if i > 0 && self.heightmap[i - 1][j] <= height {
                    continue;
                }
                if i < self.heightmap.len() - 1 && self.heightmap[i + 1][j] <= height {
                    continue;
                }

                result.push((i, j, height));
            }
        }

        result
    }

    fn find_basin_size(&mut self, (y, x): (usize, usize)) -> u32 {
        if self.visited[y][x] {
            return 0;
        }

        if self.heightmap[y][x] == 9 {
            return 0;
        }

        self.visited[y][x] = true;

        let left = if x == 0 {
            0
        } else {
            self.find_basin_size((y, x - 1))
        };

        let up = if y == 0 {
            0
        } else {
            self.find_basin_size((y - 1, x))
        };

        let right = if x >= self.heightmap[0].len() - 1 {
            0
        } else {
            self.find_basin_size((y, x + 1))
        };

        let down = if y >= self.heightmap.len() - 1 {
            0
        } else {
            self.find_basin_size((y + 1, x))
        };

        1 + left + right + up + down
    }

    pub fn output(&mut self) {
        let low_points = self.low_points();

        println!("Part 1: {}", low_points.iter().map(|x| x.2 + 1).sum::<u32>());

        let mut basin_sizes: Vec<u32> = self.low_points().iter().map(|x| self.find_basin_size((x.0, x.1))).collect();
        basin_sizes.sort_unstable_by(|a, b| b.cmp(a));

        println!("Part 2: {}", basin_sizes.iter().take(3).product::<u32>());
    }
}