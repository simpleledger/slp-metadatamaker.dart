import './util.dart';

/// Creates a SEND OP_RETURN buffer for token type 1.
List<int> Genesis(
    String ticker,
    String name,
    String documentUrl,
    List<int> documentHash,
    int decimals,
    BigInt quantity,
    [ int? mintBatonVout ]
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

/// Creates a MINT OP_RETURN buffer for token type 1.
List<int> Mint(
    List<int> tokenId,
    BigInt quantity,
    [ int? mintBatonVout ]
  ) {
  return createOpReturnMint(
    0x01,
    tokenId,
    quantity,
    mintBatonVout
  );
}

/// Creates a SEND OP_RETURN buffer for token type 1.
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
