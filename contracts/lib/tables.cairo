from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.math_cmp import is_le

func get_table_encode{range_check_ptr}() -> (encoded_table : felt*):
    let (table_address) = get_label_location(TABLE_ENCODE)

    return (encoded_table=cast(table_address, felt*))

    TABLE_ENCODE:
    dw 'A'
    dw 'B'
    dw 'C'
    dw 'D'
    dw 'E'
    dw 'F'
    dw 'G'
    dw 'H'
    dw 'I'
    dw 'J'
    dw 'K'
    dw 'L'
    dw 'M'
    dw 'N'
    dw 'O'
    dw 'P'
    dw 'Q'
    dw 'R'
    dw 'S'
    dw 'T'
    dw 'U'
    dw 'V'
    dw 'W'
    dw 'X'
    dw 'Y'
    dw 'Z'
    dw 'a'
    dw 'b'
    dw 'c'
    dw 'd'
    dw 'e'
    dw 'f'
    dw 'g'
    dw 'h'
    dw 'i'
    dw 'j'
    dw 'k'
    dw 'l'
    dw 'm'
    dw 'n'
    dw 'o'
    dw 'p'
    dw 'q'
    dw 'r'
    dw 's'
    dw 't'
    dw 'u'
    dw 'v'
    dw 'w'
    dw 'x'
    dw 'y'
    dw 'z'
    dw '0'
    dw '1'
    dw '2'
    dw '3'
    dw '4'
    dw '5'
    dw '6'
    dw '7'
    dw '8'
    dw '9'
    dw '+'
    dw '/'
end

func get_ascii_from_table{range_check_ptr}(index : felt) -> (ascii_value : felt):
    alloc_locals
    let (local encoded_table) = get_table_encode()

    let (is_index_le_63) = is_le(index, 63)

    assert is_index_le_63 = 1

    let ascii_value = encoded_table[index]

    return (ascii_value=ascii_value)
end
