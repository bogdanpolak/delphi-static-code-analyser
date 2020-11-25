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
  TCodeAnalyserMode = (camGenerateMetrics, camGenerateXml);

type
  TAnalyseUnitCommand = class
  private
    fFileName: string;
    fStringStream: TStringStream;
    fUnitMetrics: TUnitMetrics;
    fTreeBuilder: TPasSyntaxTreeBuilder;
    procedure LoadUnit();
    procedure CalculateMetrics();
    procedure DisplayMetricsResults;
    procedure GenerateXmlTree;
  public
    constructor Create(const aUnitName: string);
    destructor Destroy; override;
    class procedure Execute(const aFileName: string;
      aCodeAnalyserMode: TCodeAnalyserMode = camGenerateMetrics); static;
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
end;

procedure TAnalyseUnitCommand.GenerateXmlTree();
var
  syntaxTree: TSyntaxNode;
begin
  try
    syntaxTree := fTreeBuilder.Run(fStringStream);
    writeln(TSyntaxTreeWriter.ToXML(syntaxTree, true));
    syntaxTree.Free;
  except
    on E: ESyntaxTreeException do
    begin
      writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]) + sLineBreak +
        sLineBreak + TSyntaxTreeWriter.ToXML(E.syntaxTree, True));
    end;
  end;
end;

procedure TAnalyseUnitCommand.DisplayMetricsResults();
var
  idx: Integer;
begin
  writeln(fUnitMetrics.Name);
  for idx := 0 to fUnitMetrics.MethodsCount - 1 do
    writeln('  - ', fUnitMetrics.GetMethod(idx).ToString);
end;

class procedure TAnalyseUnitCommand.Execute(const aFileName: string;
      aCodeAnalyserMode: TCodeAnalyserMode = camGenerateMetrics);
var
  cmdAnalyseUnit: TAnalyseUnitCommand;
begin
  cmdAnalyseUnit := TAnalyseUnitCommand.Create(aFileName);
  try
    cmdAnalyseUnit.LoadUnit();
    case aCodeAnalyserMode of
      camGenerateMetrics:
        begin
          cmdAnalyseUnit.CalculateMetrics();
          cmdAnalyseUnit.DisplayMetricsResults();
        end;
      camGenerateXml:
          cmdAnalyseUnit.GenerateXmlTree();
    end;
  finally
    cmdAnalyseUnit.Free;
  end;
end;

end.
