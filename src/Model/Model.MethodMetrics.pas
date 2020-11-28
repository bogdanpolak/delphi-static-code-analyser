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
    fIndentationLevel: Integer;
  public
    constructor Create(const aKind: string; const aFullName: string);
    procedure SetLenght(aLength: Integer);
    procedure SetMaxIndentation(aMaxIndentation: Integer);
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

procedure TMethodMetrics.SetLenght(aLength: Integer);
begin
  self.fLenght := aLength;
end;

procedure TMethodMetrics.SetMaxIndentation(aMaxIndentation: Integer);
begin
  self.fIndentationLevel := aMaxIndentation;
end;

function TMethodMetrics.ToString: string;
begin
  Result := Format('%s %s  =  [Lenght: %d] [Level: %d]',
    [Kind, FullName, Lenght, fIndentationLevel])
end;

end.
