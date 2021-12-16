use std::str::FromStr;

enum PacketData {
    Literal { value: u64 },
    Operator { subpackets: Vec<Packet> },
}

struct Packet {
    version: u8,
    type_id: u8,
    data: PacketData,
}

impl Packet {
    pub fn evaluate(&self) -> usize {
        if self.type_id == 4 {
            if let PacketData::Literal { value } = self.data {
                return value as usize;
            } else {
                panic!("Got a packet with type id == 4 but without literal data!");
            }
        }

        let subpackets = if let PacketData::Operator { subpackets } = &self.data {
            subpackets.iter().collect()
        } else {
            Vec::new()
        };

        match self.type_id {
            0 => subpackets.into_iter().map(Packet::evaluate).sum(),
            1 => subpackets.into_iter().map(Packet::evaluate).product(),
            2 => subpackets.into_iter().map(Packet::evaluate).min().unwrap(),
            3 => subpackets.into_iter().map(Packet::evaluate).max().unwrap(),
            5 => if let [a, b] = subpackets[..] {
                (a.evaluate() > b.evaluate()) as usize
            } else {
                panic!("Got a greater than packet without exactly 2 subpackets!")
            }
            6 => if let [a, b] = subpackets[..] {
                (a.evaluate() < b.evaluate()) as usize
            } else {
                panic!("Got a less than packet without exactly 2 subpackets!")
            }
            7 => if let [a, b] = subpackets[..] {
                (a.evaluate() == b.evaluate()) as usize
            } else {
                panic!("Got an equal to packet without exactly 2 subpackets!")
            }
            _ => panic!("Invalid packet type id!"),
        }
    }
}

struct Transmission {
    raw_data: Vec<u8>,
    current_bit_pos: usize,
    current_byte_pos: usize,
}

impl FromStr for Transmission {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let bytevec = s.chars()
            .map(|c| c.to_digit(16).unwrap())
            .scan((0u8, false), |state, d| {
                if !state.1 {
                    *state = (d as u8, true);
                    Some(None)
                } else {
                    let final_num = (state.0 << 4) | (d as u8);
                    *state = (0u8, false);
                    Some(Some(final_num))
                }
            })
            .filter_map(std::convert::identity)
            .collect();

        Ok(Self {
            raw_data: bytevec,
            current_bit_pos: 0,
            current_byte_pos: 0,
        })
    }
}

struct TransmissionIter<'a> {
    transmission: &'a mut Transmission,
    top_level_packet: bool,
}

impl<'a> Iterator for TransmissionIter<'a> {
    type Item = Packet;

    fn next(&mut self) -> Option<Self::Item> {
        let is_top_level = self.top_level_packet;

        if self.transmission.reached_end() {
            return None;
        }

        let version: u8 = self.transmission.next_bits(3);
        let type_id: u8 = self.transmission.next_bits(3);

        let return_packet = if type_id == 4 {
            let mut literal: u64 = 0;

            loop {
                let next_bit: u8 = self.transmission.next_bits(1);
                literal = (literal << 4) | self.transmission.next_bits::<u64>(4);

                if next_bit == 0 {
                    break;
                }
            }

            Some(Packet {
                version,
                type_id,
                data: PacketData::Literal { value: literal },
            })
        } else {
            let length_type_id: u8 = self.transmission.next_bits(1);

            let mut length_value: usize = if length_type_id == 0 {
                self.transmission.next_bits(15)
            } else {
                self.transmission.next_bits(11)
            };

            let mut subpackets = Vec::new();
            self.top_level_packet = false;

            while length_value > 0 {
                let starting_position = self.transmission.current_bit_pos;
                let next_packet = self.next().unwrap();

                if length_type_id == 0 {
                    let total_bits_read = self.transmission.current_bit_pos - starting_position;
                    length_value -= total_bits_read;
                } else {
                    length_value -= 1;
                }

                subpackets.push(next_packet);
            }

            Some(Packet {
                version,
                type_id,
                data: PacketData::Operator { subpackets },
            })
        };

        if is_top_level {
            self.transmission.realign_checked();
            self.top_level_packet = true;
        }

        return_packet
    }
}

impl Transmission {
    pub fn new() -> Self {
        Self {
            raw_data: Vec::new(),
            current_bit_pos: 0,
            current_byte_pos: 0,
        }
    }

    pub fn iter_mut(&mut self) -> TransmissionIter {
        TransmissionIter {
            transmission: self,
            top_level_packet: true,
        }
    }

    fn reached_end(&self) -> bool {
        self.current_bit_pos == self.raw_data.len() * 8
    }

    fn next_bits<T: Default + TryFrom<usize>>(&mut self, num_bits: usize) -> T {
        let mut result: usize = 0;

        let mut remaining_bits = num_bits;

        while remaining_bits > 0 {
            let remaining_bits_in_current_byte = 8 - (self.current_bit_pos - (self.current_byte_pos * 8));
            let bits_to_take = remaining_bits.min(remaining_bits_in_current_byte);

            result = (result << bits_to_take) | self.get_bits_in_byte(bits_to_take);

            self.current_bit_pos += bits_to_take;
            if bits_to_take == remaining_bits_in_current_byte {
                self.current_byte_pos += 1;
            }

            remaining_bits -= bits_to_take;
        }

        if let Ok(r) = result.try_into() {
            r
        } else {
            Default::default()
        }
    }

    fn get_bits_in_byte(&self, num_bits: usize) -> usize {
        let used_bits = self.current_bit_pos - (self.current_byte_pos * 8);
        // How many bits will remain in this byte that we won't need to use.
        let bits_not_needed = 8 - used_bits - num_bits;

        let mut mask = u8::MAX;
        // Zeroing the bits we already used.
        mask <<= used_bits;
        // Zeroing the bits we won't need.
        mask >>= used_bits + bits_not_needed;
        // Bringing the mask back to the correct position.
        mask <<= bits_not_needed;

        let masked_bits = self.raw_data[self.current_byte_pos] & mask;

        // Move the masked bits to the least significant positions and return
        (masked_bits >> bits_not_needed) as usize
    }

    // Skips over any padding to realign the current bit position to a multiple of 8. Ensures that the padding that was skipped was all 0.
    fn realign_checked(&mut self) {
        if self.current_bit_pos % 8 == 0 {
            return;
        }

        let bits_to_realign = 8 - (self.current_bit_pos % 8);

        let padding: usize = self.next_bits(bits_to_realign);

        if padding != 0 {
            panic!("During realignment, we skipped over some bits that were set!");
        }
    }

    // Unchecked version of `realign_checked`.
    fn _realign(&mut self) {
        self.current_bit_pos = self.current_bit_pos + (self.current_bit_pos % 8);
    }
}

pub struct Submarine {
    transmission: Transmission,
}

impl Submarine {
    pub fn new() -> Self {
        Self {
            transmission: Transmission::new(),
        }
    }

    pub fn on_input(&mut self, result: &str) {
        self.transmission = result.parse().unwrap();
    }

    pub fn output(&mut self) {
        let mut total_version_sum: usize = 0;
        let mut outermost_packet_value = 0;

        for packet in self.transmission.iter_mut() {
            total_version_sum += version_sum(&packet);
            outermost_packet_value = packet.evaluate();
        }

        println!("Part 1: {}", total_version_sum);
        println!("Part 2: {}", outermost_packet_value);
    }
}

fn version_sum(packet: &Packet) -> usize {
    let mut result = 0;

    result += packet.version as usize;

    if let PacketData::Operator { subpackets } = &packet.data {
        for subpacket in subpackets.iter() {
            result += version_sum(subpacket);
        }
    }

    result
}