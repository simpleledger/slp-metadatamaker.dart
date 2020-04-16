import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';

List<int> pushdata(List<int> buf) {
  if (buf.length == 0) {
    return [0x4C, 0x00];
  } else if (buf.length < 0x4E) {
    return [buf.length, ...buf];
  } else if (buf.length < 0xFF) {
    return [0x4c, buf.length, ...buf];
  } else if (buf.length < 0xFFFF) {
    final tmp = new ByteData(2);
    tmp.setUint16(0, buf.length, Endian.little);
    return [0x4d, ...tmp.buffer.asUint8List().toList(), ...buf];
  } else if (buf.length < 0xFFFFFFFF) {
    final tmp = new ByteData(4);
    tmp.setUint32(0, buf.length, Endian.little);
    return [0x4e, ...tmp.buffer.asUint8List().toList(), ...buf];
  } else {
    throw('does not support bigger pushes yet');
  }
}

List<int> BNToInt64BE(BigInt bn) {
  if (bn.isNegative) {
    throw('bn not positive integer');
  }

  if (bn > BigInt.parse("18446744073709551615")) {
    throw('bn outside of range');
  }

  var hexStr = '';
  while (bn != BigInt.from(0)) {
    int temp = 0;
    temp = (bn % BigInt.from(16)).toInt();
    if (temp.toInt() < 10) {
      hexStr = String.fromCharCode(temp + 48) + hexStr;
    } else {
      hexStr = String.fromCharCode(temp + 55) + hexStr;
    }
    bn = bn ~/ BigInt.from(16);
  }
  return hex.decode(hexStr.padLeft(16, '0'));
}

List<int> createOpReturnGenesis(
  int versionType,
  String ticker,
  String name,
  String documentUrl,
  List<int> documentHash,
  int decimals,
  BigInt quantity,
  [ int mintBatonVout = null]
  ) {

  if (! [0x01, 0x41, 0x81].contains(versionType)) {
    throw('unknown versionType');
  }
  
  if (documentHash.length != 0 && documentHash.length != 32) {
    throw('documentHash must be either 0 or 32 hex bytes');
  }

  if (decimals < 0 || decimals > 9) {
    throw('decimals out of range');
  }

  if (mintBatonVout != null) {
    if (mintBatonVout < 2 || mintBatonVout > 0xFF) {
      throw('mintBatonVout out of range (0x02 < > 0xFF)');
    }
  }

  if (versionType == 0x41) {
    if (quantity != BigInt.from(1)) {
      throw('quantity must be 1 for NFT1 child genesis');
    }

    if (decimals != 0) {
      throw('decimals must be 0 for NFT1 child genesis');
    }

    if (mintBatonVout != null) {
      throw('mintBatonVout must be null for NFT1 child genesis');
    }
  }

  var buf = 
    [ 0x6A, // OP_RETURN
    ...pushdata(hex.decode("534c5000")), // lokad for "SLP")),
    ...pushdata([versionType]), // versionType
    ...pushdata(utf8.encode("GENESIS")),
    ...pushdata(utf8.encode(ticker)),
    ...pushdata(utf8.encode(name)),
    ...pushdata(utf8.encode(documentUrl)),
    ...pushdata(documentHash),
    ...pushdata([decimals]),
    ...pushdata(mintBatonVout == null ? [] : [mintBatonVout]),
    ...pushdata(BNToInt64BE(quantity)) 
  ];

  return buf;
}

List<int> createOpReturnMint(
  int versionType,
  List<int> tokenId,
  BigInt quantity,
 [int mintBatonVout = null]
){
  if (! [0x01, 0x41, 0x81].contains(versionType)) {
    throw('unknown versionType');
  }

  if (tokenId.length != 32) {
    throw('tokenIdHex must be 32 bytes');
  }

  if (mintBatonVout != null) {
    if (mintBatonVout < 2 || mintBatonVout > 0xFF) {
      throw('mintBatonVout out of range (0x02 < > 0xFF)');
    }
  }

  List<int> buf = [
    0x6A, // OP_RETURN
    ...pushdata(hex.decode("534c5000")), // lokad for "SLP")),
    ...pushdata([versionType]), // versionType
    ...pushdata(utf8.encode("MINT")),
    ...pushdata(tokenId),
    ...pushdata(mintBatonVout == null ? [] : [mintBatonVout]),
    ...pushdata(BNToInt64BE(quantity)),
  ];

  return buf;
}

List<int> createOpReturnSend(
  int versionType,
  List<int> tokenId,
  List<BigInt> slpAmounts
) {
  if (! [0x01, 0x41, 0x81].contains(versionType)) {
    throw('unknown versionType');
  }

  if (tokenId.length != 32) {
    throw('tokenIdHex must be 32 bytes');
  }

  if (slpAmounts.length < 1) {
    throw('send requires at least one amount');
  }
  if (slpAmounts.length > 19) {
    throw('too many slp amounts');
  }

  List<int> amounts = [];
  slpAmounts.forEach((v) {
    amounts.addAll(pushdata(BNToInt64BE(v)));
  });

  List<int> buf = [
    0x6A, // OP_RETURN
    ...pushdata(hex.decode("534c5000")), // lokad for "SLP")),
    ...pushdata([versionType]), // versionType
    ...pushdata(utf8.encode("SEND")),
    ...pushdata(tokenId),
    ...amounts
  ];

  return buf;
}
