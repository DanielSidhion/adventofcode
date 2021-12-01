use std::io;

mod day1;

fn main() -> io::Result<()> {
    let mut scanner = day1::DepthIncrementScanner::new();

    let stdin = io::stdin();

    let mut curr_line = String::new();

    loop {
        curr_line.clear();
        stdin.read_line(&mut curr_line)?;

        let cleaned_line = curr_line.trim();

        if cleaned_line.is_empty() {
            break;
        }

        scanner.on_new_result(cleaned_line);
    }

    println!("{}", scanner.num_increments);

    Ok(())
}