unit Metrics.UnitMethod;

interface

uses
  System.SysUtils,
  Utils.IntegerArray;

type
  TUnitMethodMetrics = class
  private
    fKind: string;
    fFullName: string;
    fLenght: Integer;
    fComplexity: Integer;
    fNameOfUnit: string;
  public
    constructor Create(const aNameOfUnit: string; const aKind: string;
      const aFullName: string);
    function SetLenght(aLength: Integer): TUnitMethodMetrics;
    function SetComplexity(aMaxIndentation: Integer): TUnitMethodMetrics;
    function ToString(): string; override;
    property NameOfUnit: string read fNameOfUnit;
    property Kind: string read fKind;
    property FullName: string read fFullName;
    property Lenght: Integer read fLenght;
    property Complexity: Integer read fComplexity;
  end;

implementation

constructor TUnitMethodMetrics.Create(const aNameOfUnit: string;
  const aKind: string; const aFullName: string);
begin
  self.fNameOfUnit := aNameOfUnit;
  self.fKind := aKind;
  self.fFullName := aFullName;
end;

function TUnitMethodMetrics.SetLenght(aLength: Integer): TUnitMethodMetrics;
begin
  self.fLenght := aLength;
  Result := self;
end;

function TUnitMethodMetrics.SetComplexity(aMaxIndentation: Integer)
  : TUnitMethodMetrics;
begin
  self.fComplexity := aMaxIndentation;
  Result := self;
end;

function TUnitMethodMetrics.ToString: string;
begin
  Result := Format('%s %s  =  [Lenght: %d] [Level: %d]',
    [Kind, FullName, Lenght, fComplexity])
end;

end.
