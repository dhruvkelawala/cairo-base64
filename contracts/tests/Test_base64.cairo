%lang starknet
%builtins pedersen range_check ecdsa

from contracts.lib.base64 import base64_encode
from contracts.lib.binary import binary_encode, binary_decode
from starkware.cairo.common.uint256 import Uint256

# Test file for the cairo lib

@view
func test_base64_encode{range_check_ptr}(original_str_len : felt, original_str : felt*) -> (
        encoded_str_len : felt, encoded_str : felt*):
    return base64_encode(original_str_len=original_str_len, original_str=original_str)
end

@view
func test_binary_encode{range_check_ptr}(data : felt) -> (res : felt):
    return binary_encode(data)
end

@view
func test_binary_decode{range_check_ptr}(data : felt) -> (res : felt):
    return binary_decode(data)
end
