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
                // println!("Board won! Win score: {}", self.win_score);
            }
        }
    }
}

pub struct Submarine {
    input_read_state: InputReadState,
    current_read_board: Option<BingoBoard>,

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
            current_read_board: None,

            chosen_bingo_numers: Vec::new(),
            bingo_boards: Vec::new(),
        }
    }

    pub fn on_input(&mut self, result : &str) {
        match self.input_read_state {
            InputReadState::ReadingChosenNumbers => {
                if result.is_empty() {
                    self.input_read_state = InputReadState::ReadingBoards;
                    self.current_read_board = Some(BingoBoard::new());
                } else {
                    self.chosen_bingo_numers = result.split(",").map(|x| x.parse().unwrap()).collect();
                }
            }
            InputReadState::ReadingBoards => {
                if result.is_empty() {
                    self.bingo_boards.push(self.current_read_board.take().unwrap());
                    self.current_read_board = Some(BingoBoard::new());
                } else {
                    self.current_read_board.as_mut().unwrap().numbers.extend(result.split(" ").filter(|x| !x.is_empty()).map(|x| x.parse::<i32>().unwrap()));
                }
            }
        }
    }

    pub fn output(mut self) {
        let mut last_board_score = 0;
        let mut first_board_score = 0;

        for num in self.chosen_bingo_numers.iter() {
            self.bingo_boards.iter_mut().for_each(|b| b.mark(*num));

            match self.bingo_boards.iter().find(|b| b.won) {
                Some(board) => {
                    if first_board_score == 0 {
                        first_board_score = board.win_score;
                    }

                    if self.bingo_boards.len() == 1 {
                        last_board_score = board.win_score;
                        break;
                    }
                },
                None => {}
            };

            self.bingo_boards = self.bingo_boards.into_iter().filter(|b| !b.won).collect();
        }

        println!("Part 1: {}", first_board_score);
        println!("Part 2: {}", last_board_score);
    }
}