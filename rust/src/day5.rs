const FIELD_SIZE: usize = 1000;

pub struct Submarine {
    vents_field: Vec<i32>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            vents_field: vec![0; FIELD_SIZE * FIELD_SIZE],
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let vertices: Vec<i32> = result.split(" -> ").map(|x| x.split(",")).flatten().map(|x| x.parse().unwrap()).collect();
        let (x0, y0, x1, y1) = (vertices[0], vertices[1], vertices[2], vertices[3]);

        self.mark_vent(x0, y0, x1, y1);
    }

    fn mark_vent(&mut self, x0: i32, y0: i32, x1: i32, y1: i32) {
        // In case x0 != x1 and y0 != y1 we'll ignore, since part 1 doesn't care about those.

        if x0 == x1 {
            let range = if y0 > y1 {
                y1..(y0 + 1)
            } else {
                y0..(y1 + 1)
            };

            for y in range {
                self.mark_location(x0, y);
            }
        } else if y0 == y1 {
            let range = if x0 > x1 {
                x1..(x0 + 1)
            } else {
                x0..(x1 + 1)
            };

            for x in range {
                self.mark_location(x, y0);
            }
        }
    }

    fn mark_location(&mut self, x: i32, y: i32) {
        let index: usize = (x + y * FIELD_SIZE as i32).try_into().unwrap();

        self.vents_field[index] += 1;
    }

    pub fn output(&self) {
        let dangerous_areas = self.vents_field.iter().filter(|&&x| x > 1).count();

        println!("Part 1: {}", dangerous_areas);
    }
}