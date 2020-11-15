unit Analytics.MethodMetrics;

interface

uses
  System.SysUtils;

type
  TMethodMetrics = class
  private
    fKind: string;
    fFullName: string;
    fLenght: Integer;
    fComplexity: Integer;
  public
    constructor Create(const aKind: string; const aFullName: string;
      aLength: Integer; aComplexity: Integer);
    function ToString(): string; override;
    property Kind: string read fKind;
    property FullName: string read fFullName;
    property Lenght: Integer read fLenght;
    property Complexity: Integer read fComplexity;
  end;

implementation

constructor TMethodMetrics.Create(const aKind: string; const aFullName: string;
  aLength: Integer; aComplexity: Integer);
begin
  self.fKind := aKind;
  self.fFullName := aFullName;
  self.fLenght := aLength;
  self.fComplexity := aComplexity;
end;

function TMethodMetrics.ToString: string;
begin
  Result := Format('%s %s  =  [Len: %d] [Complex: %d]',
    [Kind, FullName, Lenght, fComplexity])
end;

end.
