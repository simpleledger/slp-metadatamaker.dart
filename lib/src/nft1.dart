import './util.dart';

List<int> Nft1GroupGenesis(
    String ticker,
    String name,
    String documentUrl,
    List<int> documentHash,
    int decimals,
    BigInt quantity,
    [int mintBatonVout=null]
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

List<int> Nft1GroupMint(
    List<int> tokenId,
    BigInt quantity,
    [int mintBatonVout = null]
  ) {
  return createOpReturnMint(
    0x81,
    tokenId,
    quantity,
    mintBatonVout
  );
}

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
    new BigInt.from(1),
    null
  );
}

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
