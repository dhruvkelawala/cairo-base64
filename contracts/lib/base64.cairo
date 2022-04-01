from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.memcpy import memcpy

from contracts.lib.tables import get_char_from_table
from contracts.lib.binary import binary_encode, add_8bit_padding, binary_decode, remove_6bit_padding

const pow_10_6 = 1000000
const pow_10_8 = 100000000
const pow_10_16 = 10000000000000000

# Main base64 encoder function
func base64_encode{range_check_ptr}(original_str_len : felt, original_str : felt*) -> (
        encoded_str_len : felt, encoded_str : felt*):
    alloc_locals

    let (local encoded_str : felt*) = alloc()
    let (local encoded_str_len : felt*) = alloc()

    let (local data_len : felt*) = alloc()

    let (q, r) = unsigned_div_rem(original_str_len, 3)

    let last_index_og_str = original_str_len - 1

    if r == 0:
        assert [encoded_str_len] = q * 4
        assert [data_len] = original_str_len
    else:
        let incremented_q = q + 1
        assert [encoded_str_len] = incremented_q * 4

        if r == 1:
            assert [original_str + last_index_og_str + 1] = 0
            assert [original_str + last_index_og_str + 2] = 0
            assert [data_len] = original_str_len + 2
        else:
            assert [original_str + last_index_og_str + 1] = 0
            assert [data_len] = original_str_len + 1
        end
    end

    _base64_encode_partial(
        original_str_len=[data_len],
        original_str=original_str,
        encoded_str_len=[encoded_str_len],
        encoded_str=encoded_str,
        current_index=0)

    if r == 0:
        return ([encoded_str_len], encoded_str)
    end

    let (local overwritten_str) = alloc()

    let overwritten_str_len = [encoded_str_len]

    let overwritten_str_len_to_copy = [encoded_str_len] - 3 + r

    memcpy(overwritten_str, encoded_str, overwritten_str_len_to_copy)

    let padding_to_add = [encoded_str_len] - overwritten_str_len_to_copy

    if padding_to_add == 1:
        assert [overwritten_str + overwritten_str_len_to_copy] = '='
    else:
        if padding_to_add == 2:
            assert [overwritten_str + overwritten_str_len_to_copy] = '='
            assert [overwritten_str + overwritten_str_len_to_copy + 1] = '='
        end
    end

    return (overwritten_str_len, overwritten_str)
end

# Partial base64 function
# From an inputed original string, takes a group of 3 char at a time and converts them to base64 recursively

func _base64_encode_partial{range_check_ptr}(
        original_str_len : felt, original_str : felt*, encoded_str_len : felt, encoded_str : felt*,
        current_index : felt) -> ():
    alloc_locals

    if original_str_len == current_index:
        return ()
    end

    let (local str_to_encode : felt*) = alloc()

    let (local sliced_original_str : felt*) = alloc()
    let sliced_original_str_len = 3

    memcpy(sliced_original_str, original_str + current_index, sliced_original_str_len)

    # Get UTF-8 binary representation of Chars with 0 -> 1 and 1 -> 2
    _recursive_binary_encoding(sliced_original_str_len, sliced_original_str, str_to_encode, 0)

    # Concatenate 3 8bit values which gives total 24bits encoded string
    let (concatenated_felt) = concatenate_to_24_bits(sliced_original_str_len, str_to_encode)

    let (sliced_group_len, sliced_group) = slice_into_4_groups(concatenated_felt=concatenated_felt)

    let (local decoded_str : felt*) = alloc()

    _recursive_binary_decoding(sliced_group_len, sliced_group, decoded_str, 0)

    let (q, r) = unsigned_div_rem(current_index, 3)

    let (local incrementer : felt*) = alloc()

    if r == 0:
        assert [incrementer] = q * 4
    else:
        let incremented_q = q + 1
        assert [encoded_str_len] = incremented_q * 4
    end

    memcpy(encoded_str + [incrementer], decoded_str, sliced_group_len)

    return _base64_encode_partial(
        original_str_len=original_str_len,
        original_str=original_str,
        encoded_str_len=encoded_str_len,
        encoded_str=encoded_str,
        current_index=current_index + 3)
end

# Performs binary encoding recursively
func _recursive_binary_encoding{range_check_ptr}(
        src_data_len : felt, src_data : felt*, dest_data : felt*, index : felt) -> ():
    alloc_locals

    if index == src_data_len:
        return ()
    end

    # Convert All Chars of String to ASCII Binary representation
    let (res : felt) = binary_encode(src_data[index])

    # Add Padding to make each binary character 8-bits
    let (padded_res : felt) = add_8bit_padding(res)

    assert dest_data[index] = padded_res

    return _recursive_binary_encoding(
        src_data_len=src_data_len, src_data=src_data, dest_data=dest_data, index=index + 1)
end

# Concatenates 3 (8-bit) binary encoded chars into a 24-bit binary felt

func concatenate_to_24_bits{range_check_ptr}(
        binary_encoded_str_len : felt, binary_encoded_str : felt*) -> (concatenated_felt : felt):
    alloc_locals

    # Make sure only 3 UTF-8 chars are passed
    assert binary_encoded_str_len = 3

    let least_significant_bits = binary_encoded_str[2]  # x * 10^0 = x

    let middle_significant_bits = pow_10_8 * binary_encoded_str[1]

    let most_significant_bits = pow_10_16 * binary_encoded_str[0]

    let concatenated_felt = most_significant_bits + middle_significant_bits + least_significant_bits

    return (concatenated_felt=concatenated_felt)
end

# Slice a 24-bit binary felt into 4 groups
# This makes each felt of the group 6-bits

func slice_into_4_groups{range_check_ptr}(concatenated_felt : felt) -> (
        sliced_group_len : felt, sliced_group : felt*):
    alloc_locals

    let (local sliced_group) = alloc()

    local updated_concatenated_felt = concatenated_felt

    let sliced_group_len = 4

    _recursive_slice(sliced_group_len, sliced_group, updated_concatenated_felt, 0)

    return (sliced_group_len=sliced_group_len, sliced_group=sliced_group)
end

func _recursive_slice{range_check_ptr}(
        sliced_group_len : felt, sliced_group : felt*, src_felt : felt, index : felt) -> ():
    alloc_locals

    if index == sliced_group_len:
        return ()
    end

    let (q, r) = unsigned_div_rem(src_felt, pow_10_6)

    let reverse_index = 3 - index

    assert [sliced_group + reverse_index] = r

    return _recursive_slice(
        sliced_group_len, sliced_group=sliced_group, src_felt=q, index=index + 1)
end

# This function recursively handles 3 functions
# - Remove padding from a 6-bit felt
# - Convert binary represented felt to a regular felt
# - Get the character corresponding to the index represented by the felt

func _recursive_binary_decoding{range_check_ptr}(
        src_data_len : felt, src_data : felt*, dest_data : felt*, index : felt) -> ():
    alloc_locals

    if index == src_data_len:
        return ()
    end

    # Remove Padding to get each binary character
    let (binary_felt : felt) = remove_6bit_padding(src_data[index])

    # Convert All Chars of String to ASCII Binary representation
    let (res : felt) = binary_decode(binary_felt)

    # Code them to Ascii Value
    let (char_value : felt) = get_char_from_table(res)

    assert dest_data[index] = char_value

    return _recursive_binary_decoding(
        src_data_len=src_data_len, src_data=src_data, dest_data=dest_data, index=index + 1)
end

# func _recursive_remove_padding{range_check_ptr}(
#         src_data_len : felt, src_data : felt*, dest_data : felt*, index : felt) -> (
#         decoded_str_len : felt, decoded_str : felt*):
#     alloc_locals

# let (local binary_felt : felt) = remove_6bit_padding(src_data[index])

# assert dest_data[index] = binary_felt

# if index == src_data_len - 1:
#         return (decoded_str_len=src_data_len, decoded_str=dest_data)
#     end

# return _recursive_remove_padding(
#         src_data_len=src_data_len, src_data=src_data, dest_data=dest_data, index=index + 1)
# end
