unit Analytics.MethodMetrics;

interface

uses
  System.SysUtils,
  Utils.IntegerArray;

type
  TMethodMetrics = class
  private
    fKind: string;
    fFullName: string;
    fLenght: Integer;
    fIndentationLevel: Integer;
  public
    constructor Create(const aKind: string; const aFullName: string);
    function WithMethodLenght(aLength: Integer): TMethodMetrics;
    function WithMethodIndentations(const aIndentations: TIntegerArray): TMethodMetrics;
    function ToString(): string; override;
    property Kind: string read fKind;
    property FullName: string read fFullName;
    property Lenght: Integer read fLenght;
    property IndentationLevel: Integer read fIndentationLevel;
  end;

implementation

constructor TMethodMetrics.Create(const aKind: string; const aFullName: string);
begin
  self.fKind := aKind;
  self.fFullName := aFullName;
end;

function TMethodMetrics.WithMethodLenght(aLength: Integer): TMethodMetrics;
begin
  self.fLenght := aLength;
  Result := self;
end;

function TMethodMetrics.WithMethodIndentations(
  const aIndentations: TIntegerArray): TMethodMetrics;
var
  step: Integer;
  level: Integer;
begin
  level := 0;
  if Length(aIndentations) >= 2 then
  begin
    step := aIndentations[1] - aIndentations[0];
    level := (aIndentations[High(aIndentations)] - aIndentations[1]) div step;
  end;
  self.fIndentationLevel := level;
  Result := self;
end;

function TMethodMetrics.ToString: string;
begin
  Result := Format('%s %s  =  [Lenght: %d] [Level: %d]',
    [Kind, FullName, Lenght, fIndentationLevel])
end;

end.
