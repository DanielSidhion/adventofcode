use std::io;

mod day4;

fn main() -> io::Result<()> {
    let mut submarine = day4::Submarine::new();

    let stdin = io::stdin();

    let mut curr_line = String::new();

    loop {
        curr_line.clear();
        let read_result = stdin.read_line(&mut curr_line);

        if let Ok(0) = read_result {
            break;
        }

        submarine.on_input(curr_line.trim());
    }

    submarine.output();

    Ok(())
}