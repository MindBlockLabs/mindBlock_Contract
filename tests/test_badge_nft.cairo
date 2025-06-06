use starknet::testing::Account;
use starknet::contract::ContractAddress;
use starknet::types::felt252;
use starknet::utils::assert_revert;

#[test]
fn test_badge_nft() {
    // Deploy contract with name and symbol
    let (contract_address, _) = badge_nft::constructor("MindBlock", "MBAD");

    // Mint a badge as owner
    badge_nft::mint_badge(contract_address, 1u256, "ipfs://QmBadge1");

    // Verify token owner
    let owner = badge_nft::owner_of(1u256);
    assert_eq!(owner, contract_address);

    // Verify metadata URI
    let metadata = badge_nft::token_uri(1u256);
    assert_eq!(metadata, "ipfs://QmBadge1");

    // Simulate a call from non-owner address
    let non_owner = ContractAddress::from_hex("0x1234");
    let result = assert_revert(|| {
        badge_nft::mint_badge(non_owner, 2u256, "ipfs://QmBadge2");
    });
    assert!(result.is_err(), "Minting by non-owner should fail");
}
