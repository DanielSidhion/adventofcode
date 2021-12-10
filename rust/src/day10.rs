pub struct Submarine {
    syntax_error_score: u64,
    autocomplete_scores: Vec<u64>,
}

fn get_closing_equivalent(o: char) -> char {
    match o {
        '(' => ')',
        '[' => ']',
        '{' => '}',
        '<' => '>',
        _ => panic!("Invalid opening character!"),
    }
}

fn apply_character_to_stack(v: Result<Vec<char>, char>, c: char) -> Result<Vec<char>, char> {
    if let Err(_) = v {
        return v;
    }

    let mut uv = v.unwrap();

    match c {
        ')' | ']' | '}' | '>' => {
            match uv.pop() {
                None => {
                    Err(c)
                },
                Some(o) => {
                    if get_closing_equivalent(o) == c {
                        Ok(uv)
                    } else {
                        Err(c)
                    }
                }
            }
        }
        _ => {
            uv.push(c);
            Ok(uv)
        }
    }
}

fn calculate_syntax_error_score(r: &Result<Vec<char>, char>) -> u64 {
    match r {
        Ok(_) => 0,
        Err(c) => {
            match c {
                ')' => 3,
                ']' => 57,
                '}' => 1197,
                '>' => 25137,
                _ => panic!("Invalid unexpected character!"),
            }
        }
    }
}

fn calculate_autocomplete_score(r: Result<Vec<char>, char>) -> u64 {
    match r {
        Err(_) => 0,
        Ok(v) => v.iter().rev().fold(0, |score, o| score * 5 + closing_character_score(*o)),
    }
}

fn closing_character_score(o: char) -> u64 {
    match get_closing_equivalent(o) {
        ')' => 1,
        ']' => 2,
        '}' => 3,
        '>' => 4,
        _ => panic!("Invalid closing character!"),
    }
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            syntax_error_score: 0,
            autocomplete_scores: Vec::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let parsing_result = result.chars().fold(Ok(Vec::new()), apply_character_to_stack);

        self.syntax_error_score += calculate_syntax_error_score(&parsing_result);

        let autocomplete_score = calculate_autocomplete_score(parsing_result);
        if autocomplete_score > 0 {
            self.autocomplete_scores.push(autocomplete_score);
        }
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.syntax_error_score);

        self.autocomplete_scores.sort();

        println!("Part 2: {}", self.autocomplete_scores[self.autocomplete_scores.len() / 2]);
    }
}