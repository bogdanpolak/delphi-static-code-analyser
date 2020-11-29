unit test02;

interface

uses
  System.SysUtils;

implementation

type
  hash32 = cardinal;
  /// internal buffer for SHA256 hashing
  TSHA256Buffer = array[0..63] of hash32;
  /// internal work buffer for SHA256 hashing
  TSHAHash  = record
    A,B,C,D,E,F,G,H: hash32;
  end;
  shr0 = hash32;

var
  Hash: TSHAHash;
  Buffer: TSHA256Buffer;


const
  K: TSHA256Buffer = (
   $428a2f98, $71374491, $b5c0fbcf, $e9b5dba5, $3956c25b, $59f111f1,
   $923f82a4, $ab1c5ed5, $d807aa98, $12835b01, $243185be, $550c7dc3,
   $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174, $e49b69c1, $efbe4786,
   $0fc19dc6, $240ca1cc, $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da,
   $983e5152, $a831c66d, $b00327c8, $bf597fc7, $c6e00bf3, $d5a79147,
   $06ca6351, $14292967, $27b70a85, $2e1b2138, $4d2c6dfc, $53380d13,
   $650a7354, $766a0abb, $81c2c92e, $92722c85, $a2bfe8a1, $a81a664b,
   $c24b8b70, $c76c51a3, $d192e819, $d6990624, $f40e3585, $106aa070,
   $19a4c116, $1e376c08, $2748774c, $34b0bcb5, $391c0cb3, $4ed8aa4a,
   $5b9cca4f, $682e6ff3, $748f82ee, $78a5636f, $84c87814, $8cc70208,
   $90befffa, $a4506ceb, $bef9a3f7, $c67178f2);

procedure TSHA256Compress;
var W: TSHA256Buffer;
    H: TSHAHash;
    i: integer;
    t1, t2: hash32;
begin
  H := Hash;
  for i := 0 to 15 do
    W[i]:= shr0((Buffer[i*4] shl 24)or(Buffer[i*4+1] shl 16)or
                (Buffer[i*4+2] shl 8)or Buffer[i*4+3]);
  for i := 16 to 63 do
    W[i] := shr0((((W[i-2]shr 17)or(W[i-2]shl 15))xor((W[i-2]shr 19)or(W[i-2]shl 13))
      xor (W[i-2]shr 10))+W[i-7]+(((W[i-15]shr 7)or(W[i-15]shl 25))
      xor ((W[i-15]shr 18)or(W[i-15]shl 14))xor(W[i-15]shr 3))+W[i-16]);
  for i := 0 to high(W) do begin
    t1 := shr0(H.H+(((H.E shr 6)or(H.E shl 26))xor((H.E shr 11)or(H.E shl 21))xor
      ((H.E shr 25)or(H.E shl 7)))+((H.E and H.F)xor(not H.E and H.G))+K[i]+W[i]);
    t2 := shr0((((H.A shr 2)or(H.A shl 30))xor((H.A shr 13)or(H.A shl 19))xor
      ((H.A shr 22)xor(H.A shl 10)))+((H.A and H.B)xor(H.A and H.C)xor(H.B and H.C)));
    H.H := H.G; H.G := H.F; H.F := H.E; H.E := shr0(H.D+t1);
    H.D := H.C; H.C := H.B; H.B := H.A; H.A := shr0(t1+t2);
  end;
  Hash.A := shr0(Hash.A+H.A);
  Hash.B := shr0(Hash.B+H.B);
  Hash.C := shr0(Hash.C+H.C);
  Hash.D := shr0(Hash.D+H.D);
  Hash.E := shr0(Hash.E+H.E);
  Hash.F := shr0(Hash.F+H.F);
  Hash.G := shr0(Hash.G+H.G);
  Hash.H := shr0(Hash.H+H.H);
end;

end.
