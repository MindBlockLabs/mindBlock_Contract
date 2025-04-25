# 🧠 MindBlock Contracts

Welcome to the **MindBlock Smart Contracts** repository!  
This repo contains the **on-chain logic** for the MindBlock Game a puzzle-based, educational logic game powered by **StarkNet** and built with **Cairo 1.0**.

> 🧩 Think: Solve puzzles, earn tokens, and level up — all on-chain!

---

## 🔗 Powered by StarkNet + Cairo 1.0

- **Cairo** is a programming language used to build provable smart contracts for StarkNet (zk-rollup on Ethereum).
- **Scarb** is Cairo’s package manager, like npm or cargo.
- This repo includes contracts for:
  - 🧩 Puzzle creation & solution verification
  - 👤 Player progress tracking
  - 🪙 Token reward distribution

---

## 🧰 Prerequisites (One-time Setup)

Before you can run anything, make sure you install the following tools:

### 1. **Install Scarb + Cairo**

Follow the [official Cairo install guide](https://book.cairo-lang.org/getting_started/installation.html) or run:

```bash
curl -L https://raw.githubusercontent.com/software-mansion/scarb/main/install.sh | bash
```

> ✅ After installing, restart your terminal and verify:
```bash
scarb --version
```

---

## 🚀 Getting Started

1. **Clone the repo**
```bash
git clone https://github.com/MindBlockLabs/mindBlock_Contract
cd mindblock-contracts
```

2. **Install dependencies**
```bash
scarb build
```

3. **Run tests**
```bash
scarb test
```

4. **View your contract files**
- All Cairo source files are in the `/src` folder.
- Tests are in `/tests`.

---

## 🏗️ Repo Structure

```bash
mindblock-contracts/
├── src/
│   #Code files here
├── tests/
│   #test files here
├── Scarb.toml             # Project config file
└── README.md
```

---

## 🧠 Learning Resources

> Recommended if you’re new to Cairo and StarkNet:

### 🌟 Video Tutorials
- [OnlyDust Cairo 1.0 for StarkNet Devs (YouTube)](https://www.youtube.com/playlist?list=PLcIyXLwiPilWczLZCk24yI7ZOcwMfF2xS)
- [StarkNet Book (Official Docs)](https://book.starknet.io/)
- [Zero to Hero Cairo Course](https://github.com/HerodotusDev/zero-to-hero-cairo)

---

## 🤝 Contributing

We love open-source contributions! If you're new to smart contract development, this is a great place to learn while building something cool.

1. Check the [Issues](https://github.com/MindBlockLabs/mindBlock_Contract/issues)
2. Look for `good first issue` 
3. Fork, branch, and PR

### 🧪 Tip: Use `snforge` for testing

Run tests with:

```bash
scarb test
```

We’re using **Forge-style Cairo tests** with the `snforge_std` library.

---

## 📩 Questions or Help?

- Open an issue
- Reach out via [Telegram](https://t.me/+kjacdy68yfwwNTVk)
- Or drop a comment in the repo Discussions tab

---

Built with ❤️ on StarkNet
