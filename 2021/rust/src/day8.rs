use std::collections::HashSet;

const EASY_DIGITS: [usize; 4] = [1, 7, 4, 8];
const EASY_LENGTHS: [usize; 4] = [2, 3, 4, 7];

fn easy_length_to_digit(len: usize) -> usize {
    match len {
        2 => 1,
        3 => 7,
        4 => 4,
        7 => 8,
        _ => usize::MAX,
    }
}

pub struct Submarine {
    total_easy_digits: usize,
    sum_digits: usize,
    digits: [HashSet<char>; 10],
    five_len_possibilities: Vec<HashSet<char>>,
    six_len_possibilities: Vec<HashSet<char>>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            total_easy_digits: 0,
            sum_digits: 0,
            digits: Default::default(),
            five_len_possibilities: Vec::new(),
            six_len_possibilities: Vec::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let mut parts = result.split(" | ");

        // Storing the 10 unique sets for processing.
        parts.next().unwrap().split(" ").for_each(|set| self.add_unique_set(set));

        self.figure_out_ambiguous_digits();

        // Match each set from the display to the actual digit it represents.
        let display_digits: Vec<_> = parts.next().unwrap().split(" ").map(hashset_from_str).map(|s| self.digits.iter().position(|x| *x == s).unwrap()).collect();

        self.total_easy_digits += display_digits.iter().filter(|x| EASY_DIGITS.contains(x)).count();

        let display_number = 1000 * display_digits[0] + 100 * display_digits[1] + 10 * display_digits[2] + display_digits[3];
        self.sum_digits += display_number;
    }

    fn add_unique_set<'a>(&mut self, set: &'a str) {
        match set.len() {
            n if EASY_LENGTHS.contains(&n) => self.digits[easy_length_to_digit(n)] = hashset_from_str(set),
            5 => self.five_len_possibilities.push(hashset_from_str(set)),
            6 => self.six_len_possibilities.push(hashset_from_str(set)),
            _ => panic!("Got a set with weird length!"),
        }
    }

    fn figure_out_ambiguous_digits(&mut self) {
        // The set that represents 3 is the 5-digit that contains 1.
        let three_index = self.five_len_possibilities.iter().position(|x| x.is_superset(&self.digits[1])).unwrap();
        self.digits[3] = self.five_len_possibilities.swap_remove(three_index);

        // The set that represents 5 is the 5-digit except 3 that has 3 intersections with 4.
        let five_index = self.five_len_possibilities.iter().position(|x| x.intersection(&self.digits[4]).count() == 3).unwrap();
        self.digits[5] = self.five_len_possibilities.swap_remove(five_index);

        // The set that represents 2 is the remaining 5-digit.
        self.digits[2] = self.five_len_possibilities.pop().unwrap();

        // The set that represents 0 is the 6-digit that doesn't contain 5.
        let zero_index = self.six_len_possibilities.iter().position(|x| !x.is_superset(&self.digits[5])).unwrap();
        self.digits[0] = self.six_len_possibilities.swap_remove(zero_index);

        // The set that represents 9 is the 6-digit that contains 3.
        let nine_index = self.six_len_possibilities.iter().position(|x| x.is_superset(&self.digits[3])).unwrap();
        self.digits[9] = self.six_len_possibilities.swap_remove(nine_index);

        // The set that represents 6 is the remaining 6-digit.
        self.digits[6] = self.six_len_possibilities.pop().unwrap();
    }

    fn _print_digits(&self) {
        for (i, set) in self.digits.iter().enumerate() {
            let charset: String = set.iter().to_owned().collect();
            println!("{} -> {}", i, charset);
        }
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.total_easy_digits);
        println!("Part 2: {}", self.sum_digits);
    }
}

fn hashset_from_str<'a>(set: &'a str) -> HashSet<char> {
    let mut hashset = HashSet::new();
    set.chars().for_each(|x| {
        hashset.insert(x);
    });

    hashset
}