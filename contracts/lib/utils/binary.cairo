from starkware.cairo.common.math import unsigned_div_rem

# data = ["A", "B", "C"]

func binary_encode{range_check_ptr}(data : felt) -> (res : felt):
    alloc_locals

    if data == 0:
        return (res=data)
    end

    let (q, r) = unsigned_div_rem(data, 2)

    let (local bin : felt) = binary_encode(q)

    let res = r + 10 * bin

    return (res=res)
end

# In Cairo, due to lack of Support of String, we cannot use 0 as the most significant bit
# Therefore, we are using 11111111 which replaces 0 -> 1 and 1 -> 2 in a binary representation
func add_8bit_padding{range_check_ptr}(binary_felt : felt) -> (binary_padded_felt : felt):
    let binary_padded_felt = binary_felt + 11111111

    return (binary_padded_felt=binary_padded_felt)
end

func remove_6bit_padding{range_check_ptr}(binary_padded_felt : felt) -> (binary_felt : felt):
    let binary_felt = binary_padded_felt - 111111

    return (binary_felt=binary_felt)
end

func binary_decode{range_check_ptr}(encoded_str : felt) -> (decimal_felt : felt):
    alloc_locals

    if encoded_str == 0:
        return (decimal_felt=encoded_str)
    end

    let (q, r) = unsigned_div_rem(encoded_str, 10)

    let (local dec : felt) = binary_decode(q)

    let decimal_felt = r + 2 * dec

    return (decimal_felt=decimal_felt)
end
