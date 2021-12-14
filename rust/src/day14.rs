use std::collections::HashMap;

fn two_chars_to_string(a: char, b: char) -> String {
    vec![a, b].into_iter().collect()
}

fn tuple_chars_to_string((a, b): (char, char)) -> String {
    two_chars_to_string(a, b)
}

pub struct Submarine {
    polymer_template: String,
    insertion_templates: HashMap<String, Vec<String>>,
    pair_frequencies: HashMap<String, u64>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            polymer_template: String::new(),
            insertion_templates: HashMap::new(),
            pair_frequencies: HashMap::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        if self.polymer_template.is_empty() {
            self.polymer_template = result.to_string();
            self.seed_frequencies(result);
            return;
        }

        if result.is_empty() {
            return;
        }

        let mut insertion_parts = result.split(" -> ");
        let pattern = insertion_parts.next().unwrap();
        let new_element = insertion_parts.next().unwrap().chars().next().unwrap();

        self.add_insertion_templates(pattern, new_element);
    }

    fn add_insertion_templates(&mut self, pattern: &str, new_element: char) {
        if let [a, b] = pattern.chars().collect::<Vec<char>>()[..] {
            let first = two_chars_to_string(a, new_element);
            let second = two_chars_to_string(new_element, b);

            self.insertion_templates.insert(pattern.to_string(), vec![first, second]);
        }
    }

    fn seed_frequencies(&mut self, polymer_template: &str) {
        let pairs = polymer_template.chars().zip(polymer_template.chars().skip(1)).map(tuple_chars_to_string);

        for pair in pairs {
            *self.pair_frequencies.entry(pair).or_default() += 1;
        }
    }

    fn polymerize(&mut self) {
        let mut new_frequency_map = HashMap::new();

        for (pair, frequency) in self.pair_frequencies.iter() {
            let new_pairs = self.insertion_templates.get(pair)
                .map(|x| x.iter().collect()) // We need the `map` to go from &Vec<String> to Vec<&String> so we can `unwrap_or_else()`.
                .unwrap_or_else(|| vec![pair]); // If there's no insertion template, this pair must remain there.

            for new_pair in new_pairs.iter() {
                *new_frequency_map.entry((*new_pair).to_owned()).or_default() += *frequency;
            }
        }

        self.pair_frequencies = new_frequency_map;
    }

    fn count_max_min_frequencies(&mut self) -> (u64, u64) {
        let mut element_frequencies = HashMap::new();

        // By counting every pair like this, we'll end up double-counting every element that isn't the first or last element of the final polymer.
        for (pair, frequency) in self.pair_frequencies.iter() {
            if let [a, b] = pair.chars().collect::<Vec<char>>()[..] {
                *element_frequencies.entry(a).or_default() += *frequency;
                *element_frequencies.entry(b).or_default() += *frequency;
            }
        }

        // Adjusting the frequencies, making sure to add the +1 for the starting and last elements.
        element_frequencies.iter_mut().for_each(|(char, frequency)| {
            if self.polymer_template.starts_with(*char) || self.polymer_template.ends_with(*char) {
                *frequency += 1;
            }

            *frequency /= 2;
        });

        (*element_frequencies.values().max().unwrap(), *element_frequencies.values().min().unwrap())
    }

    pub fn output(&mut self) {
        for _ in 0..10 {
            self.polymerize();
        }

        let (a, b) = self.count_max_min_frequencies();

        println!("Part 1: {}", a - b);

        for _ in 0..30 {
            self.polymerize();
        }

        let (a, b) = self.count_max_min_frequencies();

        println!("Part 2: {}", a - b);
    }
}