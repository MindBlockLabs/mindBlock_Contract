# 🤝 Contributing to MindBlock Contracts

Welcome! Whether you're new to StarkNet, Cairo, or open-source — we're glad you're here.

This repo holds the smart contracts for the [MindBlock Game], and we're building it in the open with community help.

---

## 🧰 Prerequisites

Make sure you have the following installed:

- Cairo 1.0+
- [Scarb](https://docs.swmansion.com/scarb/) (Cairo's package manager)

---

## 🚀 Setting Up Locally

```bash
# Clone the repo
git clone https://github.com/MindBlockLabs/mindBlock_Contract
cd mindblock-contracts

# Build the contracts
scarb build

# Run all tests
scarb test
If you get errors, make sure scarb is properly installed and in your path.


## 📦 Project Structure
src/            # Contract source code
tests/          # Contract tests
Scarb.toml      # Cairo project config

## 🛠️ Contributing Process
Fork the repo

Create a new branch: git checkout -b feature/my-awesome-feature

Make your changes (contracts or tests)

Commit your work: git commit -m "feat: add my new thing"

Push to GitHub: git push origin feature/my-awesome-feature

Open a pull request into the main branch

GitHub Actions will run your tests


#🧪 Writing Tests
All tests live in the tests/ folder

Use snforge_std to write tests (just like Forge in Solidity)

You can run a single test file with:

scarb test --path tests/test_puzzle.cairo

# 💬 Questions?
Ask in [Telegram](https://t.me/+kjacdy68yfwwNTVk)

Or open an Issue with the question label!

Thanks for contributing 🙌
