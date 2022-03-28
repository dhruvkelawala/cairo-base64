%lang starknet
%builtins pedersen range_check ecdsa

from contracts.lib.base64 import base64_encode
from contracts.lib.utils.binary import binary_encode
from starkware.cairo.common.uint256 import Uint256

@view
func test_base64_encode{range_check_ptr}(data_len : felt, data: felt*) -> (encoded_str_len: felt,
        encoded_str : felt*):
    return base64_encode(data_len=data_len, data=data)
end

@view
func test_binary_encode{range_check_ptr}(data : felt) -> (res : felt):
    return binary_encode(data)
end
