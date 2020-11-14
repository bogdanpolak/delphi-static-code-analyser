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
  public
    constructor Create(const aKind: string; const aFullName: string;
      aLength: Integer);
    function ToString(): string; override;
    property Kind: string read fKind;
    property FullName: string read fFullName;
    property Lenght: Integer read fLenght;
  end;

implementation

constructor TMethodMetrics.Create(const aKind: string; const aFullName: string;
  aLength: Integer);
begin
  self.fKind := aKind;
  self.fFullName := aFullName;
  self.fLenght := aLength;
end;

function TMethodMetrics.ToString: string;
begin
  Result := Format('%s %s = [%d]', [Kind, FullName, Lenght])
end;

end.
