import './util.dart';

List<int> Genesis(
    String ticker,
    String name,
    String documentUrl,
    List<int> documentHash,
    int decimals,
    BigInt quantity,
    [int mintBatonVout=null]
  ) {
  return createOpReturnGenesis(
    0x01,
    ticker,
    name,
    documentUrl,
    documentHash,
    decimals,
    quantity,
    mintBatonVout,
  );
}

List<int> Mint(
    List<int> tokenId,
    BigInt quantity,
    [int mintBatonVout=null]
  ) { 
  return createOpReturnMint(
    0x01,
    tokenId,
    quantity,
    mintBatonVout
  );
}

List<int> Send(
    List<int> tokenId,
    List<BigInt> slpAmounts
  ){
  return createOpReturnSend(
    0x01,
    tokenId,
    slpAmounts,
  );
}
