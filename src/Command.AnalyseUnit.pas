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
    fFileName: string;
    fStringStream: TStringStream;
    fUnitMetrics: TUnitMetrics;
    fTreeBuilder: TPasSyntaxTreeBuilder;
    procedure LoadUnit();
    procedure CalculateMetrics();
    procedure DisplayMetricsResults(aMinLevel: Integer);
    procedure GenerateXmlTree;
  public
    constructor Create(const aUnitName: string);
    destructor Destroy; override;
    class procedure Execute(const aFileName: string;
      aDisplayLevelHigherThan: Integer = 0); static;
    class procedure Execute_GenerateXML(const aFileName: string); static;
  end;

implementation

constructor TAnalyseUnitCommand.Create(const aUnitName: string);
begin
  fStringStream := TStringStream.Create;
  fUnitMetrics := TUnitMetrics.Create(aUnitName);
  fFileName := aUnitName;
  fTreeBuilder := TPasSyntaxTreeBuilder.Create;
  {
    if aIncludeFolder <> '' then
    begin
    fTreeBuilder.IncludeHandler := TIncludeHandler.Create(aIncludeFolder);
    end;
  }
end;

destructor TAnalyseUnitCommand.Destroy;
begin
  fTreeBuilder.Free;
  fStringStream.Free;
  fUnitMetrics.Free;
  inherited;
end;

procedure TAnalyseUnitCommand.LoadUnit();
begin
  fStringStream.Clear;
  fStringStream.LoadFromFile(fFileName);
  fStringStream.Position := 0;
end;

procedure TAnalyseUnitCommand.CalculateMetrics();
var
  syntaxTree: TSyntaxNode;
begin
  try
    syntaxTree := fTreeBuilder.Run(fStringStream);
    try
      fUnitMetrics.CalculateMetrics(syntaxTree);
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

procedure TAnalyseUnitCommand.GenerateXmlTree();
var
  syntaxTree: TSyntaxNode;
begin
  try
    syntaxTree := fTreeBuilder.Run(fStringStream);
    writeln(TSyntaxTreeWriter.ToXML(syntaxTree, True));
    syntaxTree.Free;
  except
    on E: ESyntaxTreeException do
    begin
      writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]) + sLineBreak +
        sLineBreak + TSyntaxTreeWriter.ToXML(E.syntaxTree, True));
    end;
  end;
end;

procedure TAnalyseUnitCommand.DisplayMetricsResults(aMinLevel: Integer);
var
  idx: Integer;
begin
  writeln(fUnitMetrics.Name);
  for idx := 0 to fUnitMetrics.MethodsCount - 1 do
    if fUnitMetrics.GetMethod(idx).IndentationLevel >= aMinLevel then
      writeln('  - ', fUnitMetrics.GetMethod(idx).ToString);
end;

class procedure TAnalyseUnitCommand.Execute(const aFileName: string;
  aDisplayLevelHigherThan: Integer = 0);
var
  cmdAnalyseUnit: TAnalyseUnitCommand;
begin
  cmdAnalyseUnit := TAnalyseUnitCommand.Create(aFileName);
  try
    cmdAnalyseUnit.LoadUnit();
    cmdAnalyseUnit.CalculateMetrics();
    cmdAnalyseUnit.DisplayMetricsResults(aDisplayLevelHigherThan);
  finally
    cmdAnalyseUnit.Free;
  end;
end;

class procedure TAnalyseUnitCommand.Execute_GenerateXML(const aFileName
  : string);
var
  cmdAnalyseUnit: TAnalyseUnitCommand;
begin
  cmdAnalyseUnit := TAnalyseUnitCommand.Create(aFileName);
  try
    cmdAnalyseUnit.LoadUnit();
    cmdAnalyseUnit.GenerateXmlTree();
  finally
    cmdAnalyseUnit.Free;
  end;
end;

end.
