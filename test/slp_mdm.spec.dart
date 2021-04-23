import 'package:test/test.dart';
import 'package:convert/convert.dart';

import 'package:slp_mdm/slp_mdm.dart';

void main() {
  group('util', () {
    group('BNToInt64BE', () {
      test('negative', () {
         expect(() => BNToInt64BE(BigInt.from(-1)),throwsA('bn not positive integer'));
      });
      test('out-of-range', () {
         expect(() => BNToInt64BE(BigInt.parse('ffffffffffffffff01', radix: 16)), throwsA('bn outside of range'));
      });
      test('OK: parsed tiny', () {
        expect(BNToInt64BE(BigInt.parse("11", radix: 16)),[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11]);
      });
      test('OK: parsed full', () {
        expect(BNToInt64BE(BigInt.parse("1122334455667788", radix: 16)), [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88]);
      });
      test("0", () {
        List<int> a = BNToInt64BE(BigInt.from(0));
        expect(hex.encode(a), '0000000000000000');
      });

      test("1", () {
        List<int> a = BNToInt64BE(BigInt.from(1));
        expect(hex.encode(a), '0000000000000001');
      });

      test("-1", () {
        expect(() { BNToInt64BE(BigInt.from(-1)); }, throwsA('bn not positive integer'));
      });

      test("100", () {
        List<int> a = BNToInt64BE(BigInt.from(100));
        expect(hex.encode(a), '0000000000000064');
      });

      test("1844674407370955", () {
        List<int> a = BNToInt64BE(BigInt.parse("1844674407370955"));
        expect(hex.encode(a), '00068db8bac710cb');
      });

      test("18446744073709551615", () {
        List<int> a = BNToInt64BE(BigInt.parse("18446744073709551615"));
        expect(hex.encode(a), 'ffffffffffffffff');
      });

      test("18446744073709551616", () {
        expect(() { BNToInt64BE(BigInt.parse("18446744073709551616")); }, throwsA('bn outside of range'));
      });
    });

    group('pushdata', () {
      test('OK: empty', () {
        expect(pushdata([]),[0x4c, 0x00]);
      });
    
      test('OK: tiny 0x00', () {
        expect(pushdata([0x00]),[0x01, 0x00]);
      });
    
      test('OK: tiny 0x01', () {
        expect(pushdata([0x01]),[0x01, 0x01]);
      });
    
      test('OK: tiny 0xff', () {
        expect(pushdata([0xff]),[0x01, 0xff]);
      });
    
      test('OK: 0x4e length', () {
        List<int> dat = new List<int>.filled(0x4e, 0);
        dat.fillRange(0, 0x4e, 0xff);
        expect(pushdata(dat),[0x4c, 0x4e, ...dat]);
      });
    
      test('OK: 0x4c', () {
        List<int> dat = new List<int>.filled(0x4f, 0);
        dat.fillRange(0, 0x4f, 0xff);
        expect(pushdata(dat),[0x4c, 0x4f, ...dat]);
      });
    
      test('OK: 0x4d', () {
        List<int> dat = new List<int>.filled(0x100, 0);
        dat.fillRange(0, 0x100, 0xff);
        expect(pushdata(dat),[0x4d, 0x00, 0x01, ...dat]);
      });
    
      test('OK: 0x4e', () {
        List<int> dat = new List<int>.filled(0x10000, 0);
        dat.fillRange(0, 0x10000, 0xff);
        expect(pushdata(dat),[0x4e, 0x00, 0x00, 0x01, 0x00, ...dat]);
      });
    });

    test('OK: createOpReturnGenesis', () {
      var result = createOpReturnGenesis(0x01, '', '', '', [], 0, BigInt.from(0x64));
      expect(hex.encode(result), '6a04534c500001010747454e455349534c004c004c004c0001004c00080000000000000064');
    });
    // test('OK: createOpReturnGenesis (Buffer)', () {
    //   var result = createOpReturnGenesis(0x01, Buffer.from(''), Buffer.from(''), Buffer.from(''), Buffer.from(''), 0, null, BigInt.from(0x64)).toString('hex');
    //   expect(result, '6a04534c500001010747454e455349534c004c004c004c0001004c00080000000000000064');
    // });

    test('OK: createOpReturnMint', () {
      var result = createOpReturnMint(0x01, hex.decode('f'.padRight(64,'f')), BigInt.from(0x64));
      expect(hex.encode(result), '6a04534c50000101044d494e5420ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4c00080000000000000064');
    });
    // test('OK: createOpReturnMint (Buffer)', () {
    //   var result = createOpReturnMint(0x01, Buffer.from('f'.repeat(64), 'hex'), null, BigInt.from(0x64)).toString('hex');
    //   expect(result, '6a04534c50000101044d494e5420ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4c00080000000000000064');
    // });

    test('OK: createOpReturnSend', () {
      var result = createOpReturnSend(0x01, hex.decode('8'.padRight(64,'8')), [BigInt.from(0x42)]);
      var r = hex.encode(result);
      expect(hex.encode(result), '6a04534c500001010453454e44208888888888888888888888888888888888888888888888888888888888888888080000000000000042');
    });
    // test('OK: createOpReturnSend (Buffer)', () {
    //   var result = createOpReturnSend(0x01, Buffer.from('8'.repeat(64), 'hex'), [BigInt.from(0x42)]).toString('hex');
    //   expect(result, '6a04534c500001010453454e44208888888888888888888888888888888888888888888888888888888888888888080000000000000042');
    // });

    test('(must be invalid: bad value): NFT1 Child Genesis with mint_baton_vout!==null', () {
      expect(() => createOpReturnGenesis(0x41, '', '', '', [], 0, BigInt.from(0x01), 2), throwsA('mintBatonVout must be null for NFT1 child genesis'));
    });

    test('(must be invalid: bad value): NFT1 Child Genesis with divisibility!==0', () {
      expect(() => createOpReturnGenesis(0x41, '', '', '', [], 1, BigInt.from(0x01)), throwsA('decimals must be 0 for NFT1 child genesis'));
    });

    test('(must be invalid: bad value): NFT1 Child Genesis with quanitity!==1', () {
      expect(() => createOpReturnGenesis(0x41, '', '', '', [], 0, BigInt.from(0x64)), throwsA('quantity must be 1 for NFT1 child genesis'));
    });

    test('(must be invalid: bad version type): GENESIS with token_type=69', () {
      expect(() => createOpReturnGenesis(0x69, '', '', '', [], 0, BigInt.from(0x64)), throwsA('unknown versionType'));
    });
    test('(must be invalid: bad version type): MINT with token_type=69', () {
      expect(() => createOpReturnMint(0x69, hex.decode('f'.padRight(64,'f')), BigInt.from(0x64)), throwsA('unknown versionType'));
    });
    test('(must be invalid: bad version type): SEND with token_type=69', () {
      expect(() => createOpReturnSend(0x69, hex.decode('8'.padRight(64,'8')), [BigInt.from(0x64)]), throwsA('unknown versionType'));
    });
  });

  group("GENESIS", () {
    test('OK: minimal GENESIS', () {
      var result = Genesis('', '', '', [], 0, BigInt.from(0x64));
      expect(hex.encode(result), '6a04534c500001010747454e455349534c004c004c004c0001004c00080000000000000064');
    });

    test('OK: minimal NFT1 Group GENESIS', () {
      var result = Nft1GroupGenesis('', '', '', [], 0, BigInt.from(0x64));
      expect(hex.encode(result), '6a04534c500001810747454e455349534c004c004c004c0001004c00080000000000000064');
    });

    test('OK: minimal NFT1 Child GENESIS', () {
      var result = Nft1ChildGenesis('', '', '', []);
      expect(hex.encode(result), '6a04534c500001410747454e455349534c004c004c004c0001004c00080000000000000001');
    });

    test('(must be invalid: wrong size): Genesis with 2-byte decimals', () {
      expect(() => Genesis('', '', '', [], 0xFFEE, BigInt.from(0x64)),throwsA('decimals out of range'));
    });

    test('OK: Genesis with 32-byte dochash', () {
      var result = Genesis('', '', '', hex.decode('f'.padRight(64, 'f')), 0, BigInt.from(0x64));
      expect(hex.encode(result), '6a04534c500001010747454e455349534c004c004c0020ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff01004c00080000000000000064');
    });

    test('(must be invalid: wrong size): Genesis with 31-byte dochash', () {
      expect(() => Genesis('', '', '', hex.decode('f'.padRight(62, 'f')), 0, BigInt.from(0x64)), throwsA('documentHash must be either 0 or 32 hex bytes'));
    });

    test('(must be invalid: wrong size): Genesis with 33-byte dochash', () {
      expect(() => Genesis('', '', '', hex.decode('f'.padRight(66, 'f')), 0, BigInt.from(0x64)), throwsA('documentHash must be either 0 or 32 hex bytes'));
    });

    test('(must be invalid: wrong size): Genesis with 64-byte dochash', () {
      expect(() => Genesis('', '', '', hex.decode('f'.padRight(128, 'f')), 0, BigInt.from(0x64)), throwsA('documentHash must be either 0 or 32 hex bytes'));
    });

    test('(must be invalid: wrong size): Genesis with 20-byte dochash', () {
      expect(() => Genesis('', '', '', hex.decode('f'.padRight(40, 'f')), 0, BigInt.from(0x64)), throwsA('documentHash must be either 0 or 32 hex bytes'));
    });

    test('(must be invalid: wrong format): Genesis with non-hex dochash', () {
      expect(() => Genesis('', '', '', hex.decode('g'.padRight(64, 'g')), 0, BigInt.from(0x64)), throwsFormatException);
    });

    test('OK: Genesis with decimals=9', () {
      var result = Genesis('', '', '', [], 9, BigInt.from(0x64));
      expect(hex.encode(result), '6a04534c500001010747454e455349534c004c004c004c0001094c00080000000000000064');
    });

    test('(must be invalid: bad value): Genesis with decimals=10', () {
      expect(() => Genesis('', '', '', [], 10, BigInt.from(0x64)), throwsA('decimals out of range'));
    });

    test('OK: Genesis with mint_baton_vout=255', () {
      var result = Genesis('', '', '', [], 0, BigInt.from(0x64), 255);
      expect(hex.encode(result), '6a04534c500001010747454e455349534c004c004c004c00010001ff080000000000000064');
    });

    test('OK: Genesis with mint_baton_vout=95', () {
      var result = Genesis('', '', '', [], 0, BigInt.from(0x64), 95);
      expect(hex.encode(result), '6a04534c500001010747454e455349534c004c004c004c000100015f080000000000000064');
    });

    test('OK: Genesis with mint_baton_vout=2', () {
      var result = Genesis('', '', '', [], 0, BigInt.from(0x64), 2);
      expect(hex.encode(result), '6a04534c500001010747454e455349534c004c004c004c0001000102080000000000000064');
    });

    test('(must be invalid: bad value): Genesis with mint_baton_vout=1', () {
      expect(() => Genesis('', '', '', [], 0, BigInt.from(0x64), 1), throwsA('mintBatonVout out of range (0x02 < > 0xFF)'));
    });

    test('(must be invalid: bad value): Genesis with mint_baton_vout=0', () {
      expect(() => Genesis('', '', '', [], 0, BigInt.from(0x64), 0), throwsA('mintBatonVout out of range (0x02 < > 0xFF)'));
    });

    test('OK: genesis with 300-byte name \'UUUUU...\' (op_return over 223 bytes, validators must not refuse this)', () {
      var result = Genesis('', 'U'.padRight(300, 'U'), '', [], 0, BigInt.from(0x64));
      expect(hex.encode(result), '6a04534c500001010747454e455349534c004d2c015555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555554c004c0001004c00080000000000000064');
    });

    test('OK: genesis with 300-byte document url \'UUUUU...\' (op_return over 223 bytes, validators must not refuse this)', () {
      var result = Genesis('', '', 'U'.padRight(300, 'U'), [], 0, BigInt.from(0x64));
      expect(hex.encode(result), '6a04534c500001010747454e455349534c004c004d2c015555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555554c0001004c00080000000000000064');
    });
  });

  group("MINT", () {
    test('OK: typical MINT without baton', () {
      var result = Mint(hex.decode('f'.padRight(64, 'f')), BigInt.from(0x64));
      expect(hex.encode(result), '6a04534c50000101044d494e5420ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4c00080000000000000064');
    });

    test('OK: typical NFT1 Group MINT without baton', () {
      var result = Nft1GroupMint(hex.decode('f'.padRight(64, 'f')), BigInt.from(0x64));
      expect(hex.encode(result), '6a04534c50000181044d494e5420ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4c00080000000000000064');
    });

    test('(must be invalid: wrong size): MINT with 0-byte token_id', () {
      expect(() => Mint([], BigInt.from(0x64)), throwsA('tokenIdHex must be 32 bytes'));
    });
    test('(must be invalid: wrong size): MINT with 31-byte token_id', () {
      expect(() => Mint(hex.decode('f'.padRight(62, 'f')), BigInt.from(0x64)), throwsA('tokenIdHex must be 32 bytes'));
    });
    test('(must be invalid: wrong size): MINT with 33-byte token_id', () {
      expect(() => Mint(hex.decode('f'.padRight(66, 'f')), BigInt.from(0x64)), throwsA('tokenIdHex must be 32 bytes'));
    });
    test('OK: MINT with mint_baton_vout=255', () {
      var result = Mint(hex.decode('f'.padRight(64, 'f')), BigInt.from(0x64), 255);
      expect(hex.encode(result), '6a04534c50000101044d494e5420ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff01ff080000000000000064');
    });

    test('OK: MINT with mint_baton_vout=95', () {
      var result = Mint(hex.decode('f'.padRight(64, 'f')), BigInt.from(0x64), 95);
      expect(hex.encode(result), '6a04534c50000101044d494e5420ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff015f080000000000000064');
    });

    test('OK: MINT with mint_baton_vout=2', () {
      var result = Mint(hex.decode('f'.padRight(64, 'f')), BigInt.from(0x64), 2);
      expect(hex.encode(result), '6a04534c50000101044d494e5420ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0102080000000000000064');
    });

    test('(must be invalid: bad value): MINT with mint_baton_vout=1', () {
      expect(() => Mint(hex.decode('f'.padRight(64, 'f')), BigInt.from(0x64), 1), throwsA('mintBatonVout out of range (0x02 < > 0xFF)'));
    });

    test('(must be invalid: bad value): MINT with mint_baton_vout=0', () {
      expect(() => Mint(hex.decode('f'.padRight(64, 'f')), BigInt.from(0x64), 0), throwsA('mintBatonVout out of range (0x02 < > 0xFF)'));
    });
  });

  group("SEND", () {
    test('OK: typical 1-output SEND', () {
      var result = Send(hex.decode('8'.padRight(64, '8')), [BigInt.from(0x42)]);
      expect(hex.encode(result), '6a04534c500001010453454e44208888888888888888888888888888888888888888888888888888888888888888080000000000000042');
    });

    test('OK: typical 1-output NFT1 Group SEND', () {
      var result = Nft1GroupSend(hex.decode('8'.padRight(64, '8')), [BigInt.from(0x42)]);
      expect(hex.encode(result), '6a04534c500001810453454e44208888888888888888888888888888888888888888888888888888888888888888080000000000000042');
    });

    test('OK: typical 1-output NFT1 Child SEND', () {
      var result = Nft1ChildSend(hex.decode('8'.padRight(64, '8')), BigInt.from(0x42));
      expect(hex.encode(result), '6a04534c500001410453454e44208888888888888888888888888888888888888888888888888888888888888888080000000000000042');
    });

    test('OK: typical 2-output SEND', () {
      var result = Send(hex.decode('8'.padRight(64, '8')), [BigInt.from(0x42), BigInt.from(0x63)]);
      expect(hex.encode(result), '6a04534c500001010453454e44208888888888888888888888888888888888888888888888888888888888888888080000000000000042080000000000000063');
    });

    test('OK: typical SEND for token_type=41', () {
      var result = Nft1ChildSend(hex.decode('8'.padRight(64, '8')), BigInt.from(1));
      expect(hex.encode(result), '6a04534c500001410453454e44208888888888888888888888888888888888888888888888888888888888888888080000000000000001');
    });

    test('(must be invalid: wrong size): SEND with 0-byte token_id', () {
      expect(() => Send([], [BigInt.from(0x64)]), throwsA('tokenIdHex must be 32 bytes'));
    });

    test('(must be invalid: wrong size): SEND with 31-byte token_id', () {
      expect(() => Send(hex.decode('f'.padRight(62, 'f')), [BigInt.from(0x64)]), throwsA('tokenIdHex must be 32 bytes'));
    });

    test('(must be invalid: wrong size): SEND with 33-byte token_id', () {
      expect(() => Send(hex.decode('f'.padRight(66, 'f')), [BigInt.from(0x64)]), throwsA('tokenIdHex must be 32 bytes'));
    });

    test('OK: SEND with 19 token output amounts', () {
      var dat = List<BigInt>.filled(19, BigInt.from(0));
      var result = Send(hex.decode('8'.padRight(64, '8')), dat.map((a) => BigInt.from(0x01)).toList());
      expect(hex.encode(result), '6a04534c500001010453454e44208888888888888888888888888888888888888888888888888888888888888888080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001080000000000000001');
    });

    test('(must be invalid: not enough parameters): SEND with 0 token output amounts', () {
      expect(() => Send(hex.decode('8'.padRight(64, '8')), []), throwsA('send requires at least one amount'));
    });

    test('(must be invalid: too many parameters): SEND with 20 token output amounts', () {
      var dat = List<BigInt>.filled(20, BigInt.from(0));
      expect(() => Send(hex.decode('8'.padRight(64, '8')), dat.map((a) => BigInt.from(0x01)).toList()), throwsA('too many slp amounts'));
    });

    test('OK: all output amounts 0', () {
      var dat = List<BigInt>.filled(2, BigInt.from(0));
      var result = Send(hex.decode('8'.padRight(64, '8')), dat.map((a) => BigInt.from(0x00)).toList());
      expect(hex.encode(result), '6a04534c500001010453454e44208888888888888888888888888888888888888888888888888888888888888888080000000000000000080000000000000000');
     });
  });
}
