#[derive(Clone)]
struct Node {
    val: u32,
    // How many times we went to the left and to the right (to count the magnitude later).
    directions: (u32, u32),
}

impl Node {
    pub fn depth(&self) -> u32 {
        self.directions.0 + self.directions.1
    }
}

pub struct Submarine {
    all_snail_numbers: Vec<Vec<Node>>,
    final_sum: Vec<Node>,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            all_snail_numbers: Vec::new(),
            final_sum: Vec::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let curr_snail_number = parse_snail_number(result);
        self.all_snail_numbers.push(curr_snail_number.clone());

        if self.final_sum.len() == 0 {
            self.final_sum = curr_snail_number;
        } else {
            add(&mut self.final_sum, curr_snail_number);
        }
    }

    fn largest_magnitude(&self) -> u64 {
        let mut result = 0;

        for i in 0..self.all_snail_numbers.len() {
            for j in 0..self.all_snail_numbers.len() {
                if i == j {
                    continue;
                }

                let mut left = self.all_snail_numbers[i].clone();
                let right = self.all_snail_numbers[j].clone();
                add(&mut left, right);
                let mag = magnitude(&left);

                result = result.max(mag);
            }
        }

        result
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", magnitude(&self.final_sum));
        println!("Part 2: {}", self.largest_magnitude());
    }
}

fn parse_snail_number(s: &str) -> Vec<Node> {
    let mut result = Vec::new();

    // `directions.0` is how much we went on the left direction, `directions.1` is how much we went on the right direction.
    let mut directions = (0, 0);
    let mut i: usize = 0;

    let sb = s.as_bytes();

    let num_end_chars: &[_] = &[']', ','];

    while i < sb.len() {
        match sb[i] as char {
            '[' => directions.0 += 1,
            ']' => directions.1 -= 1,
            ',' => {
                // Finished parsing the node on the left and going to the right, so we'll change the directions.
                directions.0 -= 1;
                directions.1 += 1;
            },
            _ => { // Guaranteed to be the beginning of a number if the string is valid.
                let num_end = i + s[i..].find(num_end_chars).unwrap();
                let val = s[i..num_end].parse().unwrap();

                result.push(Node { val, directions });
                // Need to subtract 1 because we'll add 1 later.
                i = num_end - 1;
            },
        }

        i += 1;
    }

    result
}

fn add(s: &mut Vec<Node>, mut t: Vec<Node>) {
    // The nodes from `s` will become the left side, so increase the left directions.
    s.iter_mut().for_each(|n| n.directions.0 += 1);
    // The nodes from `t` will become the right side, so increase the right directions.
    t.iter_mut().for_each(|n| n.directions.1 += 1);
    s.append(&mut t);

    reduce(s);
}

fn reduce(s: &mut Vec<Node>) {
    // Taking advantage of short-circuiting.
    while explode(s) || split(s) {}
}

fn explode(s: &mut Vec<Node>) -> bool {
    let position_to_explode = s.windows(2).position(|win| win[0].depth() == win[1].depth() && win[0].depth() >= 5);

    if let Some(pos) = position_to_explode {
        if pos > 0 {
            s[pos - 1].val += s[pos].val;
        }

        if pos < s.len() - 2 {
            s[pos + 2].val += s[pos + 1].val;
        }

        // We're adding the new element on the position of the leftmost element of the pair, so we just need to decrease the left direction.
        let new_element = [Node {
            val: 0,
            directions: (s[pos].directions.0 - 1, s[pos].directions.1)
        }];
        s.splice(pos..=pos + 1, new_element);

        return true;
    }

    false
}

fn split(s: &mut Vec<Node>) -> bool {
    let position_to_split = s.iter().position(|n| n.val >= 10);

    if let Some(pos) = position_to_split {
        let left = Node {
            val: s[pos].val / 2,
            directions: (s[pos].directions.0 + 1, s[pos].directions.1)
        };
        let right = Node {
            val: (s[pos].val + 1) / 2,
            directions: (s[pos].directions.0, s[pos].directions.1 + 1)
        };
        let new_elements = [left, right];

        s.splice(pos..=pos, new_elements);
        return true;
    }

    false
}

fn magnitude(s: &Vec<Node>) -> u64 {
    s.iter().map(|n| 3u64.pow(n.directions.0) * 2u64.pow(n.directions.1) * n.val as u64).sum()
}