import './util.dart';

/// Creates a GENESIS OP_RETURN buffer for an NFT1 Group.
List<int> Nft1GroupGenesis(
    String ticker,
    String name,
    String documentUrl,
    List<int> documentHash,
    int decimals,
    BigInt quantity,
    [ int mintBatonVout ]
  ) {
  return createOpReturnGenesis(
    0x81,
    ticker,
    name,
    documentUrl,
    documentHash,
    decimals,
    quantity,
    mintBatonVout
  );
}

/// Creates a MINT OP_RETURN buffer for an NFT1 Group.
List<int> Nft1GroupMint(
    List<int> tokenId,
    BigInt quantity,
    [ int mintBatonVout ]
  ) {
  return createOpReturnMint(
    0x81,
    tokenId,
    quantity,
    mintBatonVout
  );
}

/// Creates a SEND OP_RETURN buffer for an NFT1 Group.
List<int> Nft1GroupSend(
    List<int> tokenId,
    List<BigInt> slpAmounts
  ) { 
  return createOpReturnSend(
    0x81,
    tokenId,
    slpAmounts,
  );
}

/// Creates a GENESIS OP_RETURN buffer for an NFT1 child.
List<int> Nft1ChildGenesis(
    String ticker,
    String name,
    String documentUrl,
    List<int> documentHash
  ) {
  return createOpReturnGenesis(
    0x41,
    ticker,
    name,
    documentUrl,
    documentHash,
    0,
    BigInt.from(1),
    null
  );
}

/// Creates a SEND OP_RETURN buffer for NFT1 child.
List<int> Nft1ChildSend(
    List<int> tokenId,
    BigInt sendAmount
  ) { 
  return createOpReturnSend(
    0x41,
    tokenId,
    [sendAmount]
  );
}
