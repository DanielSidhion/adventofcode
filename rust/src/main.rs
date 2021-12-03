use std::io;

mod day3;

fn main() -> io::Result<()> {
    let mut submarine = day3::Submarine::new();

    let stdin = io::stdin();

    let mut curr_line = String::new();

    loop {
        curr_line.clear();
        stdin.read_line(&mut curr_line)?;

        let cleaned_line = curr_line.trim();

        if cleaned_line.is_empty() {
            break;
        }

        submarine.on_input(cleaned_line);
    }

    submarine.output();

    Ok(())
}