unit Utils.IntegerArray;

interface

uses
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections;

type
  TIntegerArray = TArray<Integer>;

  TIntegerArrayHelper = record helper for TIntegerArray
  public
    procedure Sort();
    function Length: Integer;
    function GetSorted(): TIntegerArray;
    function GetDistinctArray(): TIntegerArray;
  end;

implementation

function TIntegerArrayHelper.GetDistinctArray: TIntegerArray;
var
  arr: TIntegerArray;
  idx: Integer;
  prevValue: Integer;
  destIdx: Integer;
begin
  arr := self.GetSorted();
  SetLength(Result, arr.Length);
  prevValue := -MaxInt;
  destIdx:=0;
  for idx := 0 to High(arr) do
    if prevValue < arr[idx] then
    begin
      prevValue := arr[idx];
      Result[destIdx] := arr[idx];
      inc(destIdx);
    end;
  SetLength(Result,destIdx);
end;

function TIntegerArrayHelper.GetSorted: TIntegerArray;
begin
  // ---- Clone array to Result ----
  SetLength(Result, self.Length());
  Move(self[0], Result[0], self.Length() * sizeOf(Integer));
  // ----- ----
  TArray.Sort<Integer>(Result, TDelegatedComparer<Integer>.Construct(
    function(const Left, Right: Integer): Integer
    begin
      Result := TComparer<Integer>.Default.Compare(Left, Right);
    end));
end;

function TIntegerArrayHelper.Length: Integer;
begin
  Result := System.Length(self);
end;

procedure TIntegerArrayHelper.Sort;
begin
  TArray.Sort<Integer>(self, TDelegatedComparer<Integer>.Construct(
    function(const Left, Right: Integer): Integer
    begin
      Result := TComparer<Integer>.Default.Compare(Left, Right);
    end));
end;

end.
