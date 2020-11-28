unit Model.UnitCalculator;

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Writer,
  SimpleParser.Lexer.Types,
  DelphiAST.SimpleParserEx,
  IncludeHandler,
  {}
  Model.UnitMetrics;

type
  TUnitCalculator = class
  private
    fStringStream: TStringStream;
    fTreeBuilder: TPasSyntaxTreeBuilder;
    procedure LoadUnit(const aFileName: string);
    procedure CalculateMetrics(var aUnitMetrics: TUnitMetrics);
  public
    constructor Create();
    destructor Destroy; override;
    class procedure Calculate(var aUnitMetrics: TUnitMetrics); static;
  end;

implementation

constructor TUnitCalculator.Create();
begin
  fStringStream := TStringStream.Create;
  fTreeBuilder := TPasSyntaxTreeBuilder.Create;
  {
    if aIncludeFolder <> '' then
    begin
    fTreeBuilder.IncludeHandler := TIncludeHandler.Create(aIncludeFolder);
    end;
  }
end;

destructor TUnitCalculator.Destroy;
begin
  fTreeBuilder.Free;
  fStringStream.Free;
  inherited;
end;

procedure TUnitCalculator.LoadUnit(const aFileName: string);
begin
  fStringStream.Clear;
  fStringStream.LoadFromFile(aFileName);
  fStringStream.Position := 0;
end;

procedure TUnitCalculator.CalculateMetrics(var aUnitMetrics: TUnitMetrics);
var
  syntaxTree: TSyntaxNode;
begin
  try
    syntaxTree := fTreeBuilder.Run(fStringStream);
    try
      aUnitMetrics.CalculateMetrics(syntaxTree);
    finally
      syntaxTree.Free;
    end;
  except
    on E: ESyntaxTreeException do
    begin
      writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]) + sLineBreak +
        sLineBreak + TSyntaxTreeWriter.ToXML(E.syntaxTree, True));
      raise;
    end;
  end;
end;

class procedure TUnitCalculator.Calculate(var aUnitMetrics: TUnitMetrics);
var
  calculator: TUnitCalculator;
begin
  calculator := TUnitCalculator.Create();
  try
    calculator.LoadUnit(aUnitMetrics.Name) ;
    calculator.CalculateMetrics(aUnitMetrics);
  finally
    calculator.Free;
  end;
end;

end.
