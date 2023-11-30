use std::collections::HashMap;

struct Cave {
    pub is_big: bool,
    pub connections: Vec<usize>,
}

impl Cave {
    pub fn new(is_big: bool) -> Self {
        Self {
            is_big,
            connections: Vec::new(),
        }
    }
}

pub struct Submarine {
    caves: Vec<Cave>,
    cave_name_map: HashMap<String, usize>,
}

fn is_big_cave(name: &str) -> bool {
    name.chars().next().unwrap().is_ascii_uppercase()
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            caves: Vec::new(),
            cave_name_map: HashMap::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let mut cave_names = result.split("-");

        let from = cave_names.next().unwrap();
        let to = cave_names.next().unwrap();

        self.add_cave_if_unknown(from);
        self.add_cave_if_unknown(to);

        let from_index = self.cave_name_map[from];
        let to_index = self.cave_name_map[to];

        self.caves[from_index].connections.push(to_index);
        self.caves[to_index].connections.push(from_index);
    }

    fn add_cave_if_unknown(&mut self, name: &str) {
        if !self.cave_name_map.contains_key(name) {
            self.caves.push(Cave::new(is_big_cave(name)));
            self.cave_name_map.insert(name.to_string(), self.caves.len() - 1);
        }
    }

    fn find_total_valid_paths_from_to(&self, from: &str, to: &str, double_small_cave_allowed: bool) -> u32 {
        let from_index = self.cave_name_map[from];
        let to_index = self.cave_name_map[to];

        self.dive(from_index, to_index, Vec::new(), double_small_cave_allowed, false, from_index)
    }

    fn dive(&self,
        from_index: usize,
        to_index: usize,
        mut small_caves_visited: Vec<usize>,
        double_small_cave_allowed: bool,
        mut has_double_small_cave: bool,
        start_index: usize
    ) -> u32 {
        if from_index == to_index {
            return 1;
        }

        if !self.caves[from_index].is_big {
            if small_caves_visited.contains(&from_index) {
                if double_small_cave_allowed && !has_double_small_cave && from_index != start_index {
                    has_double_small_cave = true;
                } else {
                    return 0;
                }
            } else {
                small_caves_visited.push(from_index);
            }
        }

        let mut connections_from_here = 0;

        for connection in self.caves[from_index].connections.iter() {
            connections_from_here += self.dive(
                *connection,
                to_index,
                small_caves_visited.clone(),
                double_small_cave_allowed,
                has_double_small_cave,
                start_index
            );
        }

        connections_from_here
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.find_total_valid_paths_from_to("start", "end", false));
        println!("Part 2: {}", self.find_total_valid_paths_from_to("start", "end", true));
    }
}