unit Metrics.UnitMethod;

interface

uses
  System.SysUtils,
  Utils.IntegerArray;

type
  TUnitMethod = class
  private
    fKind: string;
    fFullName: string;
    fLenght: Integer;
    fComplexity: Integer;
  public
    constructor Create(const aKind: string; const aFullName: string);
    function SetLenght(aLength: Integer): TUnitMethod;
    function SetComplexity(aMaxIndentation: Integer): TUnitMethod;
    function ToString(): string; override;
    property Kind: string read fKind;
    property FullName: string read fFullName;
    property Lenght: Integer read fLenght;
    property Complexity: Integer read fComplexity;
  end;

implementation

constructor TUnitMethod.Create(const aKind: string; const aFullName: string);
begin
  self.fKind := aKind;
  self.fFullName := aFullName;
end;

function TUnitMethod.SetLenght(aLength: Integer): TUnitMethod;
begin
  self.fLenght := aLength;
  Result := self;
end;

function TUnitMethod.SetComplexity(aMaxIndentation: Integer): TUnitMethod;
begin
  self.fComplexity := aMaxIndentation;
  Result := self;
end;

function TUnitMethod.ToString: string;
begin
  Result := Format('%s %s  =  [Lenght: %d] [Level: %d]',
    [Kind, FullName, Lenght, fComplexity])
end;

end.
