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
    fIndentationLevel: Integer;
  public
    constructor Create(const aKind: string; const aFullName: string;
      aLength: Integer; aIndentationLevel: Integer);
    function ToString(): string; override;
    property Kind: string read fKind;
    property FullName: string read fFullName;
    property Lenght: Integer read fLenght;
    property IndentationLevel: Integer read fIndentationLevel;
  end;

implementation

constructor TMethodMetrics.Create(const aKind: string; const aFullName: string;
      aLength: Integer; aIndentationLevel: Integer);
begin
  self.fKind := aKind;
  self.fFullName := aFullName;
  self.fLenght := aLength;
  self.fIndentationLevel := aIndentationLevel;
end;

function TMethodMetrics.ToString: string;
begin
  Result := Format('%s %s  =  [Lenght: %d] [Level: %d]',
    [Kind, FullName, Lenght, fIndentationLevel])
end;

end.
