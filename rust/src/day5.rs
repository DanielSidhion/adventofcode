const FIELD_SIZE: usize = 1000;

pub struct Submarine {
    vents_field_no_diagonal: Vec<i32>,
    vents_field: Vec<i32>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            vents_field_no_diagonal: vec![0; FIELD_SIZE * FIELD_SIZE],
            vents_field: vec![0; FIELD_SIZE * FIELD_SIZE],
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let vertices: Vec<i32> = result.split(" -> ").map(|x| x.split(",")).flatten().map(|x| x.parse().unwrap()).collect();
        let (x0, y0, x1, y1) = (vertices[0], vertices[1], vertices[2], vertices[3]);

        self.mark_vent(x0, y0, x1, y1);
    }

    fn mark_vent(&mut self, x0: i32, y0: i32, x1: i32, y1: i32) {
        if x0 == x1 {
            let range = build_inclusive_range(y0, y1);

            for y in range {
                self.mark_location(x0, y, false);
            }
        } else if y0 == y1 {
            let range = build_inclusive_range(x0, x1);

            for x in range {
                self.mark_location(x, y0, false);
            }
        } else {
            let xrange = build_inclusive_range(x0, x1);
            let yrange = build_inclusive_range(y0, y1);

            for (x, y) in xrange.into_iter().zip(yrange) {
                self.mark_location(x, y, true);
            }
        }
    }

    fn mark_location(&mut self, x: i32, y: i32, is_diagonal: bool) {
        let index: usize = (x + y * FIELD_SIZE as i32).try_into().unwrap();

        self.vents_field[index] += 1;

        if !is_diagonal {
            self.vents_field_no_diagonal[index] += 1;
        }
    }

    pub fn output(&self) {
        let dangerous_areas_no_diagonal = self.vents_field_no_diagonal.iter().filter(|&&x| x > 1).count();
        let dangerous_areas = self.vents_field.iter().filter(|&&x| x > 1).count();

        println!("Part 1: {}", dangerous_areas_no_diagonal);
        println!("Part 2: {}", dangerous_areas);
    }
}

// Output is a Vec<i32> to make both branches of the function body return the same type.
fn build_inclusive_range(a: i32, b: i32) -> Vec<i32> {
    if a > b {
        (b..(a + 1)).rev().collect()
    } else {
        (a..(b + 1)).collect()
    }
}