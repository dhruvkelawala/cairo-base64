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
