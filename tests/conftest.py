import pytest
import asyncio
import os

from starkware.starknet.testing.starknet import Starknet

FPATH_TESTS = os.path.join("contracts", "tests")
FPATH_BASE64 = os.path.join(FPATH_TESTS, 'Test_base64.cairo')


@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


"""Use global starknet instance."""


@pytest.fixture(scope="module")
async def starknet():
    return await Starknet.empty()


@pytest.fixture(scope='module')
async def test_base64(starknet):
    base64 = await starknet.deploy(FPATH_BASE64, constructor_calldata=[])

    return base64
