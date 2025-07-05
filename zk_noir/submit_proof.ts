// submit_proof.ts
// Example script to hash and submit IQ assessment proof to IqAssessmentVerifier.cairo

import { Account, Contract, json, Provider } from 'starknet';
import * as crypto from 'crypto';

// Replace with your contract address and ABI path
const CONTRACT_ADDRESS = 'YOUR_CONTRACT_ADDRESS';
const ABI_PATH = './IqAssessmentVerifier_abi.json';

// Replace with your provider and account setup
const provider = new Provider(); // Defaults to testnet (goerli-alpha)
const privateKey = 'YOUR_PRIVATE_KEY';
const accountAddress = 'YOUR_ACCOUNT_ADDRESS';
const account = new Account(provider, accountAddress, privateKey);

async function hashScore(score: number, secret: string, timestamp: number): Promise<string> {
  // Example: hash(score + secret + timestamp) using keccak256
  const hashInput = `${score}:${secret}:${timestamp}`;
  return '0x' + crypto.createHash('keccak256').update(hashInput).digest('hex');
}

async function submitProof(userAddress: string, hashedScore: string, timestamp: number) {
  const abi = json.parse(await import('fs').then(fs => fs.promises.readFile(ABI_PATH, 'utf8')));
  const contract = new Contract(abi, CONTRACT_ADDRESS, provider);
  contract.connect(account);
  const tx = await contract.invoke('submit_proof', [userAddress, hashedScore, timestamp]);
  console.log('Proof submitted. Tx hash:', tx.transaction_hash);
}

(async () => {
  const score = 130;
  const secret = 'user-specific-secret';
  const timestamp = Math.floor(Date.now() / 1000);
  const hashedScore = await hashScore(score, secret, timestamp);
  await submitProof(accountAddress, hashedScore, timestamp);
})();
