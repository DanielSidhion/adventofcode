// I resolved this day manually. Explanation about what the MONAD does follows.
// If you look at the `inp` instructions and what's between each one, you'll realize a few things:
// - The MONAD is doing very similar work for each input (the instructions are essentially all the same, but some values change).
// - `x`, `y`, and `w` are never carried forward between the work for each input. Only `z` is.
// - (CASE 1) For some inputs, the MONAD tries to compare the input number with (something + NUMBER), where NUMBER is a literal number in the instruction. However, if you look at the numbers, they're all greater than 9, which means the comparison will never succeed.
//   - When this happens, the MONAD essentially multiplies `z` by 26 and adds the (input number + NUMBER2) to `z`.
// - (CASE 2) For other inputs, the MONAD tries to compare (`z` % 26 + NEGATIVE_NUMBER) to the input number, where NEGATIVE_NUMBER is always a negative number (duh).
//   - If the comparison succeeds, the MONAD doesn't do anything else.
//   - If the comparison does not succeed, the MONAD adds the (input number + NUMBER2) to `z`.
//
// Based on these observations, it can be noted that the MONAD is essentially building a number in base 26 and storing that in `z`, but sometimes it removes some digits from the number it's building (only happens when there's that NEGATIVE_NUMBER and the check succeeds).
// There are 14 inputs (the digit of the model number). The MONAD uses CASE 1 for 7 numbers, and CASE 2 for 7 other numbers.
// For the MONAD to output "valid", `z` must be 0 at the end, which means that for all CASE 2 inputs, the check must succeed.
//
// Based on all of the above, the MONAD is always tying two input numbers together whenever there's a CASE 2. When this happens, you can figure out exactly the relationship between two input numbers for the check to succeed.
// Applying this on my input, you get (assuming i is an array with all the input numbers):
// i[5] == i[4] + 5 - 12
// i[6] == i[3] + 13 - 12
// i[8] == i[7] + 9 - 7
// i[10] == i[9] + 13 - 8
// i[11] == i[2] + 1 - 5
// i[12] == i[1] + 2 - 10
// i[13] == i[0] + 14 - 7
// Further reducing this:
// i[5] == i[4] - 7
// i[6] == i[3] + 1
// i[8] == i[7] + 2
// i[10] == i[9] + 5
// i[11] == i[2] - 4
// i[12] == i[1] - 8
// i[13] == i[0] + 7
// Knowing that each digit must be between 1 and 9 (inclusive), you can figure out the highest and lowest model number that works. All that matters is whether you're trying to maximize the first digits or minimize them.

pub struct Submarine {
}

impl Submarine {
    pub fn new() -> Self {
        Self {}
    }

    pub fn on_input(&mut self, _: &str) {
    }

    pub fn output(&mut self) {
        println!("Part 1: 29989297949519");
        println!("Part 2: 19518121316118");
    }
}