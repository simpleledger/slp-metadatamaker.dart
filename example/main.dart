import 'package:slp_mdm/slp_mdm.dart';
import 'package:convert/convert.dart';

main() {
  var divisibility = 9;
  var mintBatonVout = 2;
  var qty = BigInt.from(1000000) * BigInt.from(10).pow(divisibility);
  var genesisMsg = Genesis('', '', '', [], divisibility, qty, mintBatonVout);
  print(hex.encode(genesisMsg));

  var tokenId = hex.decode('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
  var sendMsg = Send(tokenId, [BigInt.from(1), BigInt.from(10)]);
  print(hex.encode(sendMsg));

  var mintMsg = Mint(tokenId, BigInt.from(10), mintBatonVout);
  print(hex.encode(mintMsg));
}
