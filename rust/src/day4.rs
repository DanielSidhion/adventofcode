#[derive(Clone)]
struct BingoBoard {
    // Negative number means it's marked.
    pub numbers: Vec<i32>,
    won: bool,
    win_score: i32,
}

impl BingoBoard {
    pub fn new() -> Self {
        Self {
            numbers: Vec::new(),
            won: false,
            win_score: 0,
        }
    }

    pub fn mark(&mut self, number: i32) {
        self.numbers.iter_mut().for_each(|n| {
            if *n == number {
                *n = -number;
            }
        });

        self.evaluate_win(number);
    }

    pub fn evaluate_win(&mut self, number: i32) {
        for i in 0..5 {
            let row_win = self.numbers.iter().skip(i * 5).take(5).all(|&x| x < 0);
            let column_win = self.numbers.iter().skip(i).step_by(5).all(|&x| x < 0);

            if row_win || column_win {
                self.won = true;
                self.win_score = number * self.numbers.iter().filter(|&&x| x > 0).sum::<i32>();
            }
        }
    }
}

pub struct Submarine {
    input_read_state: InputReadState,
    current_read_board: BingoBoard,

    chosen_bingo_numers: Vec<i32>,
    bingo_boards: Vec<BingoBoard>,
}

enum InputReadState {
    ReadingChosenNumbers,
    ReadingBoards,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            input_read_state: InputReadState::ReadingChosenNumbers,
            current_read_board: BingoBoard::new(),

            chosen_bingo_numers: Vec::new(),
            bingo_boards: Vec::new(),
        }
    }

    pub fn on_input(&mut self, result : &str) {
        match self.input_read_state {
            InputReadState::ReadingChosenNumbers => {
                if result.is_empty() {
                    self.input_read_state = InputReadState::ReadingBoards;
                } else {
                    self.chosen_bingo_numers = result.split(",").map(|x| x.parse().unwrap()).collect();
                }
            }
            InputReadState::ReadingBoards => {
                if result.is_empty() {
                    self.bingo_boards.push(self.current_read_board.clone());
                    self.current_read_board = BingoBoard::new();
                } else {
                    self.current_read_board.numbers.extend(result.split(" ").filter(|x| !x.is_empty()).map(|x| x.parse::<i32>().unwrap()));
                }
            }
        }
    }

    pub fn output(&mut self) {
        for num in self.chosen_bingo_numers.iter() {
            self.bingo_boards.iter_mut().for_each(|b| b.mark(*num));

            let win_score = match self.bingo_boards.iter().find(|b| b.won) {
                Some(board) => board.win_score,
                None => 0,
            };

            if win_score > 0 {
                println!("Part 1: {}", win_score);
                break;
            }
        }
    }
}