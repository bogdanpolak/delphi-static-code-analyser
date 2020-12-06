unit Model.MethodMetrics;

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
    fComplexity: Integer;
  public
    constructor Create(const aKind: string; const aFullName: string);
    function SetLenght(aLength: Integer): TMethodMetrics;
    function SetComplexity(aMaxIndentation: Integer): TMethodMetrics;
    function ToString(): string; override;
    property Kind: string read fKind;
    property FullName: string read fFullName;
    property Lenght: Integer read fLenght;
    property Complexity: Integer read fComplexity;
  end;

implementation

constructor TMethodMetrics.Create(const aKind: string; const aFullName: string);
begin
  self.fKind := aKind;
  self.fFullName := aFullName;
end;

function TMethodMetrics.SetLenght(aLength: Integer): TMethodMetrics;
begin
  self.fLenght := aLength;
  Result := self;
end;

function TMethodMetrics.SetComplexity(aMaxIndentation: Integer): TMethodMetrics;
begin
  self.fComplexity := aMaxIndentation;
  Result := self;
end;

function TMethodMetrics.ToString: string;
begin
  Result := Format('%s %s  =  [Lenght: %d] [Level: %d]',
    [Kind, FullName, Lenght, fComplexity])
end;

end.
