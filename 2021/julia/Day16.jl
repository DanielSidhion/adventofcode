module Day16

export Submarine, on_input!, output

@enum PacketType::UInt8 PSum=0 PProduct PMinimum PMaximum PLiteral PGT PLT PEQ

struct Packet{T}
    version::UInt8
    type_id::PacketType
    data::T
end

mutable struct Submarine
    transmission::BitVector

    Submarine() = new(BitVector(undef, 0))
end

function on_input!(s::Submarine, a::AbstractString)
    s.transmission = BitVector(Iterators.flatten(map(x -> collect(Iterators.reverse(digits(x, base = 2, pad = 8))), hex2bytes(a))))
end

function get_packet(s::Submarine, starting_bit::UInt64)::Tuple{Packet,UInt64}
    version::UInt8 = bitarray_to_int(s.transmission[starting_bit:starting_bit+2])
    type_id::PacketType = PacketType(bitarray_to_int(s.transmission[starting_bit+3:starting_bit+5]))

    starting_bit += 6

    if type_id == PLiteral
        literal::UInt64 = 0

        while true
            is_last_chunk = !s.transmission[starting_bit] # is only last chunk if the value in the bitvector is false.
            literal = (literal << 4) | bitarray_to_int(s.transmission[starting_bit+1:starting_bit+4])
            starting_bit += 5

            if is_last_chunk
                break
            end
        end

        return (Packet(version, type_id, literal), starting_bit)
    else
        length_type_id = s.transmission[starting_bit]
        length_value = 0

        if length_type_id
            length_value = bitarray_to_int(s.transmission[starting_bit+1:starting_bit+11])
            starting_bit += 12
        else
            length_value = bitarray_to_int(s.transmission[starting_bit+1:starting_bit+15])
            starting_bit += 16
        end

        subpackets::Vector{Packet} = []

        while length_value > 0
            next_packet, final_position = get_packet(s, starting_bit)

            if length_type_id
                length_value -= 1
            else
                length_value -= final_position - starting_bit
            end

            starting_bit = final_position
            push!(subpackets, next_packet)
        end

        return (Packet(version, type_id, subpackets), starting_bit)
    end
end

function bitarray_to_int(arr)::UInt64
    result::UInt64 = 0

    total_bits = length(arr)

    v::UInt64 = 2 ^ (total_bits - 1)

    for i = 1:total_bits
        result += v * arr[i]
        v >>= 1
    end

    return result
end

function version_sum(packet::Packet)::UInt64
    result::UInt64 = packet.version

    if isa(packet.data, Vector{Packet})
        result += sum(version_sum.(packet.data))
    end

    result
end

function evaluate_packet(packet::Packet{UInt64})::UInt64
    packet.data
end

function evaluate_packet(packet::Packet{Vector{Packet}})::UInt64
    evaluated_packets = evaluate_packet.(packet.data)

    if packet.type_id == PSum
        sum(evaluated_packets)
    elseif packet.type_id == PProduct
        prod(evaluated_packets)
    elseif packet.type_id == PMinimum
        minimum(evaluated_packets)
    elseif packet.type_id == PMaximum
        maximum(evaluated_packets)
    elseif packet.type_id == PGT
        a, b = evaluated_packets
        a > b
    elseif packet.type_id == PLT
        a, b = evaluated_packets
        a < b
    elseif packet.type_id == PEQ
        a, b = evaluated_packets
        a == b
    end
end

function output(s::Submarine)
    outermost_packet, _ = get_packet(s, 1 % UInt64)

    println("Part 1: $(version_sum(outermost_packet))")
    println("Part 2: $(evaluate_packet(outermost_packet))")
end

end