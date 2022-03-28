from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256

from contracts.lib.tables import get_table_encode
from contracts.lib.utils.binary import binary_encode

# data = ["A", "B", "C"]

func base64_encode{range_check_ptr}(data_len : felt, data : felt*) -> (
        encoded_str_len : felt, encoded_str : felt*):
    let TABLE_ENCODE_len : felt = 64

    alloc_locals
    let (local encoded_str : felt*) = alloc()

    # let (local TABLE_ENCODE : felt*) = get_table_encode()

    return _recursive_binary_encoding(data_len, data, encoded_str, 0)
end

func _recursive_binary_encoding{range_check_ptr}(
        src_data_len : felt, src_data : felt*, dest_data : felt*, index : felt) -> (
        encoded_str_len : felt, encoded_str : felt*):
    alloc_locals

    let (res : felt) = binary_encode(src_data[index])
    assert dest_data[index] = res

    if index == src_data_len - 1:
        return (encoded_str_len=src_data_len, encoded_str=dest_data)
    end

    return _recursive_binary_encoding(
        src_data_len=src_data_len, src_data=src_data, dest_data=dest_data, index=index + 1)
end
