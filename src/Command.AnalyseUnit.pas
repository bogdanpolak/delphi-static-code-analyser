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
  Model.UnitMetrics,
  Model.MethodMetrics;

type
  TAnalyseUnitCommand = class
  private
    class procedure DisplayMetricsResults(aUnitMetrics: TUnitMetrics;
      aMinLevel: Integer); static;
    class function GenerateXml(const aStream: TStream): string; static;
  public
    class procedure Execute(const aFileName: string;
      aDisplayLevelHigherThan: Integer = 0); static;
    class procedure Execute_GenerateXML(const aFileName: string); static;
  end;

implementation

uses Model.MetricsCalculator;

class function TAnalyseUnitCommand.GenerateXml(const aStream: TStream): string;
var
  treeBuilder: TPasSyntaxTreeBuilder;
  syntaxTree: TSyntaxNode;
begin
  Result := '';
  treeBuilder := TPasSyntaxTreeBuilder.Create;
  try
    try
      syntaxTree := treeBuilder.Run(aStream);
      Result := TSyntaxTreeWriter.ToXML(syntaxTree, True);
      syntaxTree.Free;
    except
      on E: ESyntaxTreeException do
      begin
        Result := Format('[%d, %d] %s', [E.Line, E.Col, E.Message]) + sLineBreak
          + sLineBreak + TSyntaxTreeWriter.ToXML(E.syntaxTree, True);
      end;
    end;
  finally
    treeBuilder.Free;
  end;
end;

class procedure TAnalyseUnitCommand.DisplayMetricsResults
  (aUnitMetrics: TUnitMetrics; aMinLevel: Integer);
var
  idx: Integer;
  MethodMetrics: TMethodMetrics;
begin
  writeln(aUnitMetrics.Name);
  for idx := 0 to aUnitMetrics.MethodsCount - 1 do
  begin
    MethodMetrics := aUnitMetrics.GetMethod(idx);
    if MethodMetrics.IndentationLevel >= aMinLevel then
      writeln('  - ', MethodMetrics.ToString);
  end;
end;

class procedure TAnalyseUnitCommand.Execute(const aFileName: string;
  aDisplayLevelHigherThan: Integer = 0);
var
  UnitMetrics: TUnitMetrics;
begin
  UnitMetrics := TUnitMetrics.Create(aFileName);
  try
    TUnitCalculator.Calculate(UnitMetrics);
    DisplayMetricsResults(UnitMetrics, aDisplayLevelHigherThan);
  finally
    UnitMetrics.Free;
  end;
end;

class procedure TAnalyseUnitCommand.Execute_GenerateXML(const aFileName
  : string);
var
  stringStream: TStringStream;
  text: string;
begin
  stringStream:= TStringStream.Create;
  try
    stringStream.LoadFromFile(aFileName);
    stringStream.Position := 0;
    text := GenerateXml(stringStream);
    writeln(text);
  finally
    stringStream.Free;
  end;

end;

end.
