import pytest


def str_to_felt(text):
    b_text = bytes(text, 'UTF-8')
    return int.from_bytes(b_text, "big")


def felt_to_str(value):
    return chr(value)


def split(word):
    return [char for char in word]


@pytest.mark.asyncio
async def test_base64_encode(test_base64):

    svg = '<svg xmlns = "http://www.w3.org/2000/svg" width = "30" height = "30" viewBox = "0 0 30 30" stroke = "#DAE5EF" fill = "none" stroke-width = "3" stroke-linecap = "round" stroke-linejoin = "round" class = "feather feather-search" > <circle cx = "11" cy = "11" r = "8" > </circle > <line x1 = "21" y1 = "21" x2 = "16.65" y2 = "16.65" > </line> </svg>'

    input_string_array = list(map(lambda str: str_to_felt(
        str), split(svg)))

    print("Input String: {}".format(input_string_array))

    execution_info = await test_base64.test_base64_encode(input_string_array).call()
    print("Execution Info:  {}".format(
        execution_info.result))

    decoded_string = "".join(map(lambda value: felt_to_str(
        value), execution_info.result.encoded_str))

    print("Encoded String: {}".format(decoded_string))


# @pytest.mark.asyncio
# async def test_binary_encode(test_base64):

#     input_string = str_to_felt('B')

#     execution_info = await test_base64.test_binary_encoding(input_string).call()
#     print("Execution Info:  {}".format(
#         execution_info.result[0]))

# @pytest.mark.asyncio
# async def test_binary_decode(test_base64):

#     # input_string = str_to_felt('B')

#     execution_info = await test_base64.test_binary_decode(1001).call()
#     print("Execution Info:  {}".format(
#         execution_info.result[0]))
