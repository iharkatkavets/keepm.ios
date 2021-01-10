# BIG ENDIAN 0x4F52 #
0   1 2  3
┌----┬----┐
| 4F | 52 |
└----┴----┘
# LITTLE ENDIAN 0x4F52 #
0   1 2  3
┌----┬----┐
| 52 | 4F |
└----┴----┘

KDB FILE SIGNATURE
0              3 4             7 8                                    11
┌-----------------┬-------------┬---------------------------------------┐
| base identifier | kdb version | file minor version/file major version |
└-----------------┴-------------┴---------------------------------------┘
base identifier for all kdbx files:
[0x03,0xD9,0xA2,0x9A]

kdb version:
[0x67,0xFB,0x4B,0xB5]

file version:
Bytes 8-9: LE WORD, file version (minor)
Bytes 10-11: LE WORD, file version (major)

