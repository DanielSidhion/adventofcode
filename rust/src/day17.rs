pub struct Submarine {
    target_area_x: (i32, i32),
    target_area_y: (i32, i32),
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            target_area_x: (0, 0),
            target_area_y: (0, 0),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let mut target_area = result.strip_prefix("target area: x=").unwrap().split(", y=");
        let x_area: Vec<i32> = target_area.next().unwrap().split("..").map(|n| n.parse().unwrap()).collect();
        let y_area: Vec<i32> = target_area.next().unwrap().split("..").map(|n| n.parse().unwrap()).collect();

        // The entire solution assumes that `0 <= x_area[0] <= x_area[1]` and that `y_area[0] <= y_area[1] <= 0`.
        self.target_area_x = (x_area[0], x_area[1]);
        self.target_area_y = (y_area[0], y_area[1]);
    }

    fn highest_y(&self) -> i32 {
        let vy_max = self.target_area_y.0.abs().max(self.target_area_y.1.abs());
        (vy_max * (vy_max - 1)) / 2
    }

    fn within_bounds(&self, mut vx: i32, mut vy: i32) -> bool {
        let mut x_pos = 0;
        let mut y_pos = 0;

        while x_pos < self.target_area_x.1 && y_pos > self.target_area_y.0 {
            x_pos += vx;
            y_pos += vy;

            if x_pos >= self.target_area_x.0 && x_pos <= self.target_area_x.1 && y_pos >= self.target_area_y.0 && y_pos <= self.target_area_y.1 {
                return true;
            }

            vx -= 1;
            vx = vx.max(0);
            vy -= 1;
        }

        return false;
    }

    fn distinct_velocity_values(&self) -> i32 {
        let vx_max = self.target_area_x.1;
        let vy_max = self.target_area_y.0.abs().max(self.target_area_y.1.abs());
        let vy_min = self.target_area_y.0;

        let mut possibilities = 0;

        for vx in 0..=vx_max {
            for vy in vy_min..=vy_max {
                if self.within_bounds(vx, vy) {
                    possibilities += 1
                }
            }
        }

        possibilities
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.highest_y());
        println!("Part 2: {}", self.distinct_velocity_values());
    }
}