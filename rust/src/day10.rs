pub struct Submarine {
    syntax_error_score: u32,
}

fn is_opening_equivalent(c: char, o: char) -> bool {
    match c {
        ')' => o == '(',
        ']' => o == '[',
        '}' => o == '{',
        '>' => o == '<',
        _ => panic!("Invalid closing character!"),
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
                    if is_opening_equivalent(c, o) {
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

fn score_parsing_result(r: Result<Vec<char>, char>) -> u32 {
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

impl Submarine {
    pub fn new() -> Self {
        Self {
            syntax_error_score: 0,
        }
    }

    pub fn on_input(&mut self, result: &str) {
        let parsing_result = result.chars().fold(Ok(Vec::new()), apply_character_to_stack);

        self.syntax_error_score += score_parsing_result(parsing_result);
    }

    pub fn output(&mut self) {
        println!("Part 1: {}", self.syntax_error_score);
    }
}