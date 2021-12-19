use std::{collections::BTreeSet};

// All 24 possible rotation states that a scanner can be in are listed here. Each function will translate between the scanner's local coordinate system to a "global" coordinate system. I calculated all of these just using my hand (right-hand rule, although I used my left hand, but it doesn't really matter which hand you use) and going through each case one by one and listing the directions.
const ROTATIONS: [fn(&Point) -> Point; 24] = [
    |p: &Point| Point { x: p.x, y: p.y, z: p.z },
    |p: &Point| Point { x: p.x, y: -p.z, z: p.y },
    |p: &Point| Point { x: p.x, y: -p.y, z: -p.z },
    |p: &Point| Point { x: p.x, y: p.z, z: -p.y },

    |p: &Point| Point { x: -p.x, y: -p.y, z: p.z },
    |p: &Point| Point { x: -p.x, y: -p.z, z: -p.y },
    |p: &Point| Point { x: -p.x, y: p.y, z: -p.z },
    |p: &Point| Point { x: -p.x, y: p.z, z: p.y },

    |p: &Point| Point { x: -p.y, y: p.x, z: p.z },
    |p: &Point| Point { x: p.z, y: p.x, z: p.y },
    |p: &Point| Point { x: -p.z, y: p.x, z: -p.y },
    |p: &Point| Point { x: p.y, y: p.x, z: -p.z },

    |p: &Point| Point { x: -p.y, y: -p.x, z: -p.z },
    |p: &Point| Point { x: -p.z, y: -p.x, z: p.y },
    |p: &Point| Point { x: p.y, y: -p.x, z: p.z },
    |p: &Point| Point { x: p.z, y: -p.x, z: -p.y },

    |p: &Point| Point { x: -p.z, y: p.y, z: p.x },
    |p: &Point| Point { x: p.y, y: p.z, z: p.x },
    |p: &Point| Point { x: -p.y, y: -p.z, z: p.x },
    |p: &Point| Point { x: p.z, y: -p.y, z: p.x },

    |p: &Point| Point { x: p.z, y: p.y, z: -p.x },
    |p: &Point| Point { x: -p.y, y: p.z, z: -p.x },
    |p: &Point| Point { x: -p.z, y: -p.y, z: -p.x },
    |p: &Point| Point { x: p.y, y: -p.z, z: -p.x },
];

#[derive(Clone, Copy, Eq, Ord, PartialEq, PartialOrd)]
struct Point {
    x: i32,
    y: i32,
    z: i32,
}

impl std::ops::Sub for &Point {
    type Output = Point;

    fn sub(self, rhs: Self) -> Self::Output {
        Point {
            x: self.x - rhs.x,
            y: self.y - rhs.y,
            z: self.z - rhs.z,
        }
    }
}

impl std::ops::Add for Point {
    type Output = Point;

    fn add(self, rhs: Self) -> Self::Output {
        Point {
            x: self.x + rhs.x,
            y: self.y + rhs.y,
            z: self.z + rhs.z,
        }
    }
}

impl Point {
    pub fn zero() -> Self {
        Point { x: 0, y: 0, z: 0 }
    }

    pub fn new(coords: Vec<i32>) -> Self {
        Point {
            x: coords[0],
            y: coords[1],
            z: coords[2],
        }
    }

    pub fn squared_mag(&self) -> i32 {
        self.x * self.x + self.y * self.y + self.z * self.z
    }

    pub fn squared_dist(&self, p: &Point) -> i32 {
        let dist = self - p;
        dist.squared_mag()
    }

    pub fn manhattan(&self, p: &Point) -> i32 {
        (self.x - p.x).abs() + (self.y - p.y).abs() + (self.z - p.z).abs()
    }
}

pub struct Submarine {
    scanner_reports: Vec<Vec<Point>>,
    // Contains all the beacon positions relative to scanner 0.
    beacons_relative_to_0: BTreeSet<Point>,
    // For every `i`, contains all offsets between scanner `i` and scanner 0.
    beacon_position_relative_to_0: Vec<Point>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            scanner_reports: Vec::new(),
            beacons_relative_to_0: BTreeSet::new(),
            beacon_position_relative_to_0: Vec::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        if result.starts_with("---") {
            self.scanner_reports.push(Vec::new());
            // Just initialization, we'll calculate this later.
            self.beacon_position_relative_to_0.push(Point::zero());
            return;
        }

        if result.is_empty() {
            return;
        }

        let coords: Vec<_> = result.split(",").map(|c| c.parse().unwrap()).collect();
        let point = Point::new(coords);

        self.scanner_reports.last_mut().unwrap().push(point);
    }

    fn triangulate_scanners(&mut self, i: usize, j: usize) -> bool {
        if self.beacon_position_relative_to_0[i] != Point::zero() && self.beacon_position_relative_to_0[j] != Point::zero() {
            // We already triangulated both scanners. Nothing to do, we can skip this.
            return false;
        }

        let mut common = common_beacons(&self.scanner_reports[i], &self.scanner_reports[j]);

        if common.len() < 12 {
            // Not enough beacons to triangulate. Exit.
            return false;
        }

        // `from` is the scanner that was already triangulated, `to` is the scanner we're triangulating.
        let mut from = i;
        let mut to = j;

        if self.beacon_position_relative_to_0[j] != Point::zero() {
            from = j;
            to = i;

            // Since we're switching i and j, we need to also switch the indices mapping the common beacons.
            common.iter_mut().for_each(|b| {
                *b = (b.1, b.0);
            });
        }

        // For each possible rotation, we'll check if that particular rotation puts the scanner in the coordinate system we want.
        for rotation_index in 0..ROTATIONS.len() {
            let adjusted_points: Vec<_> = self.scanner_reports[to].iter().map(|p| ROTATIONS[rotation_index](p)).collect();

            let dists: Vec<_> = common.iter().map(|&(k, l)| &self.scanner_reports[from][k] - &adjusted_points[l]).collect();
            let all_dists_equal = dists.iter().skip(1).fold(true, |s, p| s && p == &dists[0]);
            if all_dists_equal {
                // We found our rotation, so let's adjust the points from the scanner to have the correct rotation. This is important because later we'll try to triangulate this scanner with other scanners, so we need to ensure that any scanner we triangulate is in the same coordinate system as scanner 0.
                self.scanner_reports[to] = adjusted_points;

                // Figuring out the offset between this scanner and scanner 0. Important for manhattan distance later.
                self.beacon_position_relative_to_0[to] = self.beacon_position_relative_to_0[from] + dists[0];

                for p in self.scanner_reports[to].iter() {
                    self.beacons_relative_to_0.insert(*p + self.beacon_position_relative_to_0[to]);
                }

                return true;
            }
        }

        return false;
    }

    fn triangulate(&mut self) {
        let total_scanners = self.scanner_reports.len();

        // Points from scanner 0 don't need to be messed with.
        for p in &self.scanner_reports[0] {
            self.beacons_relative_to_0.insert(*p);
        }

        // Will tell us whether a given scanner was already visited and its points were already rotated.
        let mut visited = vec![false; total_scanners];
        visited[0] = true;

        // We start from scanner 0 and try to triangulate it with any other scanners.
        for i in 1..total_scanners {
            if self.triangulate_scanners(0, i) {
                visited[i] = true;
            }
        }

        loop {
            let mut visited_all = true;

            // Now we'll try to start from any visited scanner, and see if we can triangulate any unvisited scanners.
            for i in 1..total_scanners {
                if !visited[i] {
                    visited_all = false;
                    continue;
                }

                // If we're here, we already visited this scanner, so let's try to match it to any other scanners.
                for j in 1..total_scanners {
                    if visited[j] {
                        // No point in doing triangulation work between two visited scanners.
                        continue;
                    }

                    if self.triangulate_scanners(i, j) {
                        visited[j] = true;
                    }
                }
            }

            if visited_all {
                // Triangulation job is done.
                break;
            }
        }
    }

    fn max_manhattan_between_scanners(&self) -> i32 {
        let mut result = 0;

        let total_scanners = self.scanner_reports.len();

        for i in 0..total_scanners {
            for j in i + 1..total_scanners {
                let p1 = &self.beacon_position_relative_to_0[i];
                let p2 = &self.beacon_position_relative_to_0[j];

                result = result.max(p1.manhattan(p2));
            }
        }

        result
    }

    pub fn output(&mut self) {
        self.triangulate();

        println!("Part 1: {}", self.beacons_relative_to_0.len());
        println!("Part 2: {}", self.max_manhattan_between_scanners());
    }
}

// When figuring out beacons common to scanners, we need this helper struct to hold the distance between two beacons.
#[derive(Clone)]
struct PointDistanceElement {
    dist: i32,
    point_pos: usize,
}

// Following are PartialEq, Eq, PartialOrd, and Ord implementations for this helper struct. We only care about ordering based on distance. The pointer to the beacon position is important for other purposes.
impl PartialEq for PointDistanceElement {
    fn eq(&self, other: &Self) -> bool {
        self.dist == other.dist
    }
}

impl Eq for PointDistanceElement {}

impl PartialOrd for PointDistanceElement {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for PointDistanceElement {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.dist.cmp(&other.dist)
    }
}

// Given a list of all beacon positions scanned by a scanner, returns a list. Each index `i` of the returned list contains a set of all distances between beacon `i` and other beacons.
fn squared_distance_sets(scans: &Vec<Point>) -> Vec<BTreeSet<PointDistanceElement>> {
    let n = scans.len();

    let mut result = vec![BTreeSet::new(); n];

    for i in 0..n {
        for j in i + 1..n {
            let dist = scans[i].squared_dist(&scans[j]);
            // Distance between i and j is equal to distance between j and i, but the pointer position needs to be adjusted.
            result[i].insert(PointDistanceElement { dist, point_pos: j });
            result[j].insert(PointDistanceElement { dist, point_pos: i });
        }
    }

    result
}

// Given two lists of beacon positions scanned by two scanners, returns a list of mappings. Each index `i` of the returned list contains a mapping between a beacon scanned by the first scanner and a beacon scanned by the second scanner.
fn common_beacons(s1: &Vec<Point>, s2: &Vec<Point>) -> Vec<(usize, usize)> {
    let mut result = Vec::new();

    let dist1 = squared_distance_sets(s1);
    let dist2 = squared_distance_sets(s2);

    // A beacon will be common to both scanners if at least 11 other beacons from the first scanner have the same distances as 11 other beacons from the second scanner. In that case, we'll take those (at least) 12 beacons as the common beacons.
    for i in 0..dist1.len() {
        for j in 0..dist2.len() {
            let common_dists: Vec<_> = dist1[i].intersection(&dist2[j]).collect();

            // (i, j) is already a beacon, so we look for 11 or more intersections (to hit the 12 minimum beacons to triangulate).
            if common_dists.len() >= 11 {
                result.push((i, j));

                for d in common_dists {
                    // Due to how we check how a `PointDistanceElement` is equal/higher/lesser to another (we only check the distance), the intersection of distances in `common_dists` will either have a pointer to the position in the first scanner, or the position in the second scanner. To make sure that we get the proper position, we'll find the element from the intersection again in each distance set. This will ensure that the pointers will be correct.
                    let pos1 = dist1[i].get(d);
                    let pos2 = dist2[j].get(d);

                    if matches!((pos1, pos2), (Some(_), Some(_))) {
                        // Finally, we have a mapping between a beacon from the first scanner and a beacon from the second scanner.
                        result.push((pos1.unwrap().point_pos, pos2.unwrap().point_pos));
                    }
                }

                return result;
            }
        }
    }

    result
}