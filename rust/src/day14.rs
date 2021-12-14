use std::collections::HashMap;

pub struct Submarine {
    polymer_template: String,
    insertion_templates: HashMap<String, char>,
    element_frequency: HashMap<char, u32>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            polymer_template: String::new(),
            insertion_templates: HashMap::new(),
            element_frequency: HashMap::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        if self.polymer_template.is_empty() {
            self.polymer_template = result.to_string();
            return;
        }

        if result.is_empty() {
            return;
        }

        let mut insertion_parts = result.split(" -> ");
        let pattern = insertion_parts.next().unwrap();
        let new_element = insertion_parts.next().unwrap().chars().next().unwrap();

        self.insertion_templates.insert(pattern.to_string(), new_element);
    }

    fn polymerize(&mut self) {
        let new_polymer = self.polymer_template.chars()
            .zip(self.polymer_template.chars().skip(1))
            .flat_map(|(a, b)| {
                if let Some(insertion) = self.insertion_templates.get(&format!("{}{}", a, b)) {
                    return vec![a, *insertion];
                }

                return vec![a];
            })
            .chain(self.polymer_template.chars().last())
            .collect();

        self.polymer_template = new_polymer;
    }

    fn count_max_min_frequencies(&mut self) -> (u32, u32) {
        self.polymer_template.chars().for_each(|c| *self.element_frequency.entry(c).or_default() += 1);

        let mut frequencies: Vec<u32> = self.element_frequency.values().cloned().collect();
        frequencies.sort_unstable_by(|a, b| b.cmp(a));

        (frequencies[0], *frequencies.last().unwrap())
    }

    pub fn output(&mut self) {
        for _ in 0..10 {
            self.polymerize();
        }

        let (a, b) = self.count_max_min_frequencies();

        println!("Part 1: {}", a - b);
    }
}