Developer Onboarding Guide
For Cairo SDK/Contract Contributors

Prerequisites
Install Rust (required for Cairo tooling).

Install Git.

Recommended: Familiarity with Starknet and Cairo basics.

1. Cairo Setup
   Install Cairo Compiler
   bash

# Install Cairo (Starknet) toolchain

curl -L https://github.com/franalgaba/cairo-installer/raw/main/bin/cairo-installer | bash
Or use Scarb (recommended for newer projects):

bash
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh
Verify Installation
bash
cairo-compile --version # Cairo 1.x  
scarb --version # Scarb (if used)  
2. Contract Testing
Set Up Tests
Write tests in Cairo (example test_contract.cairo):

python
%lang starknet

@contract_interface  
namespace TestContract {  
 func balance() -> (res: felt) {  
 }  
}

@external  
func test_balance() {  
 let (res) = TestContract.balance();  
 assert res = 0;  
 return ();  
}  
Run tests with:

bash
cairo-test test_contract.cairo
Advanced Testing
Use Starknet Devnet for local testing:

bash
pip install starknet-devnet  
devnet --host 0.0.0.0 --port 5050  
3. Deployment Scripts
Deploy to Starknet Testnet
Install Starknet CLI:

bash
pip install starknet-devnet
Write a deployment script (deploy.py):

python
from starknet_py.contract import Contract

async def deploy():  
 contract = await Contract.deploy(  
 account=account,  
 compiled_contract="contract_compiled.json"  
 )  
 print(f"Deployed at: {contract.address}")  
Run:

bash
python deploy.py
Contribution Workflow
Fork the repo.

Create a branch (git checkout -b feat/your-feature).

Commit changes with descriptive messages.

Submit a PR targeting main with:

Test coverage.

Updated docs (if applicable).

Notes for Maintainers

Add this file to /docs or the repo root.

Include a ## Troubleshooting section for common issues (e.g., Rust/Cairo version conflicts).
