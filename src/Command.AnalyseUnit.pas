unit Command.AnalyseUnit;

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
  Analytics.UnitMetrics;

type
  TAnalyseUnitCommand = class
  private
  public
    class procedure Execute(const aFileName: string); static;
  end;

implementation

function LoadUnit(const FileName: string): TStream;
var
  strStream: TStringStream;
begin
  strStream := TStringStream.Create;
  strStream.LoadFromFile(FileName);
  strStream.Position := 0;
  Result := strStream;
end;

function BuildMetrics(aUnitStream: TStream; const aUnitName: string;
  const aIncludeFolder: string = ''): TUnitMetrics;
var
  Builder: TPasSyntaxTreeBuilder;
  syntaxTree: TSyntaxNode;
begin
  Result := TUnitMetrics.Create(aUnitName);
  Builder := TPasSyntaxTreeBuilder.Create;
  try
    if aIncludeFolder <> '' then
    begin
      Builder.IncludeHandler := TIncludeHandler.Create(aIncludeFolder);
    end;
    try
      syntaxTree := Builder.Run(aUnitStream);
      try
        Result.CalculateMetrics(syntaxTree);
        // writeln(TSyntaxTreeWriter.ToXML(syntaxTree, true));
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
  finally
    Builder.Free;
  end
end;

procedure DisplayMetricsResults(aUnitMetrics: TUnitMetrics);
var
  idx: Integer;
begin
  writeln(aUnitMetrics.Name);
  for idx := 0 to aUnitMetrics.MethodsCount - 1 do
    writeln('  - ', aUnitMetrics.GetMethod(idx).ToString);
end;

procedure RunUnitAnalyser(const aFileName: string);
var
  metrics: TUnitMetrics;
  stream: TStream;
begin
  stream := LoadUnit(aFileName);
  try
    metrics := BuildMetrics(stream, aFileName);
    DisplayMetricsResults(metrics);
    metrics.Free;
  finally
    stream.Free;
  end;
end;

class procedure TAnalyseUnitCommand.Execute(const aFileName: string);
begin
  RunUnitAnalyser(aFileName);
end;

end.
