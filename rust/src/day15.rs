use std::{cmp::Ordering, collections::BinaryHeap};

#[derive(Debug, Eq, PartialEq)]
struct Node {
    position: (usize, usize),
    risk_level_estimate: u32,
}

impl Node {
    pub fn new((x, y): (usize, usize), risk_level: u32, (final_x, final_y): (usize, usize)) -> Self {
        let risk_level_estimate = risk_level + ((final_x - x) + (final_y - y)) as u32;

        Node { position: (x, y), risk_level_estimate }
    }
}

impl Ord for Node {
    fn cmp(&self, n: &Self) -> Ordering {
        // Inverting the comparison to turn the max heap into a min heap.
        n.risk_level_estimate.cmp(&self.risk_level_estimate).then_with(|| self.position.cmp(&n.position))
    }
}

impl PartialOrd for Node {
    fn partial_cmp(&self, n: &Self) -> Option<Ordering> {
        Some(self.cmp(n))
    }
}

pub struct Submarine {
    risk_map_template: Vec<Vec<u32>>,
    full_risk_map: Vec<Vec<u32>>,
    smallest_risk_level_map: Vec<Vec<u32>>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            risk_map_template: Vec::new(),
            full_risk_map: Vec::new(),
            smallest_risk_level_map: Vec::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        self.risk_map_template.push(result.chars().map(|c| c.to_digit(10).unwrap()).collect());
    }

    fn build_full_risk_level_map(&mut self) {
        self.full_risk_map = (0..5).flat_map(|e| {
            self.risk_map_template.iter().map(move |row| {
                (0..5).flat_map(|f| row.iter().map(move |r| wrap(*r + e + f))).collect()
            })
        }).collect();
    }

    fn set_smallest_risk_level_map(&mut self, width: usize, height: usize) {
        self.smallest_risk_level_map = (0..height).map(|_| vec![u32::MAX; width]).collect();
    }

    fn shortest_risk_level(&mut self, full_map: bool) -> u32 {
        // Before returning an immutable reference to the risk map to use, we'll do some mutable operations to set up the algorithm. We won't be able to mutate stuff after taking the immutable reference.
        let risk_map = if full_map {
            self.build_full_risk_level_map();
            self.set_smallest_risk_level_map(self.full_risk_map[0].len(), self.full_risk_map.len());
            &self.full_risk_map
        } else {
            self.set_smallest_risk_level_map(self.risk_map_template[0].len(), self.risk_map_template.len());
            &self.risk_map_template
        };

        let final_position = (risk_map[0].len() - 1, risk_map.len() - 1);

        let mut heap = BinaryHeap::new();
        heap.push(Node::new((0, 0), 0, final_position));
        self.smallest_risk_level_map[0][0] = 0;

        while let Some(node) = heap.pop() {
            if node.position == final_position {
                return node.risk_level_estimate;
            }

            let current_risk_level = self.smallest_risk_level_map[node.position.1][node.position.0];

            for neighbor in neighbors(node.position, final_position) {
                let new_risk_level = current_risk_level + risk_map[neighbor.1][neighbor.0];
                let current_smallest_neighbor_risk_level = &mut self.smallest_risk_level_map[neighbor.1][neighbor.0];

                if new_risk_level < *current_smallest_neighbor_risk_level {
                    *current_smallest_neighbor_risk_level = new_risk_level;
                    heap.push(Node::new(neighbor, new_risk_level, final_position));
                }
            }
        }

        0
    }

    fn _print_smallest_risk_level_map(&self) {
        self.smallest_risk_level_map.iter().for_each(|row| {
            row.iter().for_each(|n| {
                if *n == u32::MAX {
                    print!("  ∞")
                } else {
                    print!("{:>3}", *n)
                }
            });
            println!("");
        })
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.shortest_risk_level(false));
        println!("Part 2: {}", self.shortest_risk_level(true));
    }
}

// This is probably gonna slow down the code a lot since it's always creating a new vec for each position. Could be optimized further.
fn neighbors((x, y): (usize, usize), (x_max, y_max): (usize, usize)) -> impl Iterator<Item = (usize, usize)> {
    let mut result = Vec::new();

    if x > 0 {
        result.push((x - 1, y));
    }

    if x < x_max {
        result.push((x + 1, y));
    }

    if y > 0 {
        result.push((x, y - 1));
    }

    if y < y_max {
        result.push((x, y + 1));
    }

    result.into_iter()
}

fn wrap(v: u32) -> u32 {
    if v >= 10 {
        v % 9
    } else {
        v
    }
}