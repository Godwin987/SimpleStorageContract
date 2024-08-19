from web3 import Web3
from solcx import compile_standard, install_solc
from dotenv import load_dotenv
import json
import os

load_dotenv()

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()

solc_version = install_solc("latest")
# Compile Our Solidity

compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {
                    "*": ["abi", "metadata", "evm.bytecode", "evm.bytecode.sourceMap"]
                }
            },
        },
    },
    solc_version=solc_version
)

with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)

# Getting byte code for deploying

bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"]["bytecode"]["object"]

# get abi
abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

# connecting with Ganache
w3 = Web3(Web3.HTTPProvider(
    "https://sepolia.infura.io/v3/ecbb923e8bc44210a8167b61333cc9c8"))
chain_id = 1337
my_address = "0x00b962EDA5180967445B46F9c9F47A5F78da4BA5"
private_key = os.getenv("PRIVATE_KEY")

# Create the contract in python
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
# Get the latest transaction
nonce = w3.eth.get_transaction_count(my_address)

# Build a transaction
# Sign a transaction
# Send a transaction
transaction = SimpleStorage.constructor().build_transaction(
    {"from": my_address, "nonce": nonce})
signed_txn = w3.eth.account.sign_transaction(
    transaction, private_key=private_key)  # Sign the txn with the private key.

# Send signed transaction
print("Deploying Contract...")
tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)

# Wait for Block confirmations
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
print("Contract deployed!")
# Working with a contract, you always need
# Contract Address
# Contract ABI
# New contract object to work with contracts.
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

# Initial value of favorite number
print(simple_storage.functions.retrieve().call())
'''When making transactions in a blockchain, we can interact in Calls and Transact
Call => Doesn't make a State change to the blockchain 
Transact => Does make a state change(E.g building and sending txns)'''

store_transaction = simple_storage.functions.store(15).build_transaction({
    "from": my_address, "nonce": w3.eth.get_transaction_count(my_address),
})
signed_store_txn = w3.eth.account.sign_transaction(
    store_transaction, private_key=private_key)

print("Updating Contract...")
store_transaction_hash = w3.eth.send_raw_transaction(
    signed_store_txn.rawTransaction)

store_receipt = w3.eth.wait_for_transaction_receipt(store_transaction_hash)
print("Contract Updated!")
print(simple_storage.functions.retrieve().call())
