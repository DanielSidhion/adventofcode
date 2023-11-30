#[derive(Clone, Eq, PartialEq)]
struct Cuboid {
    x: (i64, i64),
    y: (i64, i64),
    z: (i64, i64),
}

// Clamp `coords` to always be inside `clamp`.
fn clamped(coords: (i64, i64), clamp: (i64, i64)) -> (i64, i64) {
    (coords.0.max(clamp.0), coords.1.min(clamp.1))
}

impl Cuboid {
    pub fn from_coords(coords: Vec<Vec<i64>>) -> Self {
        Self {
            x: (coords[0][0], coords[0][1]),
            y: (coords[1][0], coords[1][1]),
            z: (coords[2][0], coords[2][1]),
        }
    }

    pub fn in_initialization_area(&self) -> bool {
        self.x.0 >= -50 && self.x.1 <= 50 && self.y.0 >= -50 && self.y.1 <= 50 && self.z.0 >= -50 && self.z.1 <= 50
    }

    // We may build some cuboids that don't make sense. This helps us identify them.
    pub fn is_valid(&self) -> bool {
        self.x.0 <= self.x.1 && self.y.0 <= self.y.1 && self.z.0 <= self.z.1
    }

    pub fn num_cubes(&self) -> u64 {
        ((self.x.1 - self.x.0 + 1) * (self.y.1 - self.y.0 + 1) * (self.z.1 - self.z.0 + 1)) as u64
    }

    pub fn intersects(&self, other: &Self) -> bool {
        self.x.0 <= other.x.1 && self.x.1 >= other.x.0 &&
        self.y.0 <= other.y.1 && self.y.1 >= other.y.0 &&
        self.z.0 <= other.z.1 && self.z.1 >= other.z.0
    }

    // Breaks the current cuboid, returning cuboids that were part of the original cuboid, but don't intersect/touch `other`.
    pub fn break_apart(self, other: &Self) -> Vec<Self> {
        if !self.intersects(other) {
            return vec![self];
        }

        let mut result = vec![
            // We'll carve the space first by taking the bottom and top in the Z axis that isn't covered by `other`.
            Cuboid { x: self.x, y: self.y, z: (self.z.0, other.z.0 - 1) },
            Cuboid { x: self.x, y: self.y, z: (other.z.1 + 1, self.z.1) },
            // Then, we'll take the left and right in the X axis that isn't covered by `other`, making sure to only take in the Z axis the amount of `self` that intersects with `other`.
            Cuboid { x: (self.x.0, other.x.0 - 1), y: self.y, z: clamped(other.z, self.z) },
            Cuboid { x: (other.x.1 + 1, self.x.1), y: self.y, z: clamped(other.z, self.z) },
            // Finally, we take the back and front in the Y axis that isn't covered by `other`, making sure to only take in the X and Z axes the amount of `self` that intersects with `other`.
            Cuboid { x: clamped(other.x, self.x), y: (self.y.0, other.y.0 - 1), z: clamped(other.z, self.z) },
            Cuboid { x: clamped(other.x, self.x), y: (other.y.1 + 1, self.y.1), z: clamped(other.z, self.z) },
        ];

        // At a maximum, we'll end up with the 6 spaces we carved (only in the case that `other` is completely inside `self`).
        result.retain(|c| c.is_valid());
        result
    }
}

pub struct Submarine {
    on_cuboids_initialization: Vec<Cuboid>,
    on_cuboids: Vec<Cuboid>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            on_cuboids_initialization: Vec::new(),
            on_cuboids: Vec::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let instructions: Vec<_> = result.split(" ").collect();

        let turn_on = instructions[0] == "on";
        let coords: Vec<Vec<i64>> = instructions[1].split(",").map(|d| d[2..].split("..").map(|n| n.parse().unwrap()).collect::<Vec<_>>()).collect();

        self.reboot(turn_on, coords);
    }

    fn reboot(&mut self, turn_on: bool, coords: Vec<Vec<i64>>) {
        let action_cuboid = Cuboid::from_coords(coords);

        if action_cuboid.in_initialization_area() {
            self.on_cuboids_initialization = self.on_cuboids_initialization
                .drain(..)
                .flat_map(|c| c.break_apart(&action_cuboid))
                .collect();

            if turn_on {
                // Only add `action_cuboid` if it should be on. Otherwise, we already made sure that the cuboids we have don't intersect `action_cuboid`.
                self.on_cuboids_initialization.push(action_cuboid.clone());
            }
        }

        self.on_cuboids = self.on_cuboids
            .drain(..)
            .flat_map(|c| c.break_apart(&action_cuboid))
            .collect();

        if turn_on {
            self.on_cuboids.push(action_cuboid);
        }
    }

    fn cubes_initialization_on(&self) -> u64 {
        self.on_cuboids_initialization.iter().map(|c| c.num_cubes()).sum()
    }

    fn cubes_on(&self) -> u64 {
        self.on_cuboids.iter().map(|c| c.num_cubes()).sum()
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.cubes_initialization_on());
        println!("Part 2: {}", self.cubes_on());
    }
}