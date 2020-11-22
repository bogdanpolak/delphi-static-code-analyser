unit Main;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Diagnostics,
  {}
  StringPool,
  DelphiAST,
  DelphiAST.Writer,
  DelphiAST.Classes,
  SimpleParser.Lexer.Types,
  DelphiAST.SimpleParserEx,
  IncludeHandler;

procedure ApplicationRun();

implementation

uses
  Analytics.Generator,
  Analytics.UnitMetrics;

function GetTestFolder(): string;
begin
  if DirectoryExists('..\..\..\test\data') then
    Result := '..\..\..\test\data\'
  else if DirectoryExists('..\test\data') then
    Result := '..\test\data'
  else
    raise Exception.Create('Can''t find test data folder.');
end;

function LoadUnit(const FileName: string): TStream;
var
  strStream: TStringStream;
begin
  strStream := TStringStream.Create;
  strStream.LoadFromFile(FileName);
  strStream.Position := 0;
  Result := strStream;
end;

function BuildMetrics(aUnitStream: TStream; const aIncludeFolder: string = '')
  : TUnitMetrics;
var
  Builder: TPasSyntaxTreeBuilder;
  syntaxTree: TSyntaxNode;
begin
  Builder := TPasSyntaxTreeBuilder.Create;
  try
    if aIncludeFolder <> '' then
    begin
      Builder.IncludeHandler := TIncludeHandler.Create(aIncludeFolder);
    end;
    try
      syntaxTree := Builder.Run(aUnitStream);
      try
        Result := TAnalyticsGenerator.Build(syntaxTree);
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
    writeln('  - ', aUnitMetrics.Method[idx].ToString);
end;

procedure RunUnitAnalyser(const fname: string);
var
  metrics: TUnitMetrics;
  stream: TStream;
begin
  stream := LoadUnit(fname);
  try
    metrics := BuildMetrics(stream);
    DisplayMetricsResults(metrics);
    metrics.Free;
  finally
    stream.Free;
  end;
end;

procedure ApplicationRun();
var
  fname: string;
begin
  writeln('DelphiAST - Static Code Analyser');
  writeln('----------------------------------');
  fname := TPath.Combine(GetTestFolder, 'testunit.pas');
  RunUnitAnalyser(fname);
  readln;
end;

end.
