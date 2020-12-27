unit Metrics.UnitMethod;

interface

uses
  System.SysUtils,
  Utils.IntegerArray;

type
  TUnitMethodMetrics = class
  private
    fFullUnitName: string;
    fKind: string;
    fName: string;
    fLenght: Integer;
    fComplexity: Integer;
  public
    constructor Create(const aFullUnitName: string; const aKind: string;
      const aName: string);
    function SetLenght(aLength: Integer): TUnitMethodMetrics;
    function SetComplexity(aMaxIndentation: Integer): TUnitMethodMetrics;
    function ToString(): string; override;
    function HasName(aName: string): boolean;
    property FullUnitName: string read fFullUnitName;
    property Kind: string read fKind;
    property Name: string read fName;
    property Lenght: Integer read fLenght;
    property Complexity: Integer read fComplexity;
  end;

implementation

constructor TUnitMethodMetrics.Create(const aFullUnitName: string;
  const aKind: string; const aName: string);
begin
  self.fFullUnitName := aFullUnitName;
  self.fKind := aKind;
  self.fName := aName;
end;

function TUnitMethodMetrics.SetLenght(aLength: Integer): TUnitMethodMetrics;
begin
  self.fLenght := aLength;
  Result := self;
end;

function TUnitMethodMetrics.HasName(aName: string): boolean;
begin
  Result := (Name.ToUpper = aName.ToUpper);
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
    [Kind, Name, Lenght, fComplexity])
end;

end.
