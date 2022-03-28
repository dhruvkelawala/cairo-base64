import pytest


def str_to_felt(text):
    b_text = bytes(text, 'UTF-8')
    return int.from_bytes(b_text, "big")


def split(word):
    return [char for char in word]


@pytest.mark.asyncio
async def test_base64_encode(test_base64):

    # input_string = str_to_felt('A')
    # input_string2 = str_to_felt('B')
    # input_string3 = str_to_felt('C')

    input_string_array = list(map(lambda str: str_to_felt(
        str), split("ABC")))

    print("Input String: {}".format(input_string_array))

    execution_info = await test_base64.test_base64_encode(input_string_array).call()
    print("Execution Info:  {}".format(
        execution_info.result))


# @pytest.mark.asyncio
# async def test_binary_encode(test_base64):

#     input_string = str_to_felt('B')

#     execution_info = await test_base64.test_binary_encoding(input_string).call()
#     print("Execution Info:  {}".format(
#         execution_info.result[0]))
