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

function Parse(const FileName: string): TUnitMetrics;
var
  syntaxtree: TSyntaxNode;
  Builder: TPasSyntaxTreeBuilder;
  StringStream: TStringStream;
begin
  Result := nil;
  try
    Builder := TPasSyntaxTreeBuilder.Create;
    try
      StringStream := TStringStream.Create;
      try
        StringStream.LoadFromFile(FileName);
        Builder.IncludeHandler := TIncludeHandler.Create
          (ExtractFilePath(FileName));
        StringStream.Position := 0;
        syntaxtree := Builder.Run(StringStream);
        try
          Result := TAnalyticsGenerator.Build(syntaxtree);
          // writeln(TSyntaxTreeWriter.ToXML(syntaxtree, true));
        finally
          syntaxtree.Free;
        end;
      finally
        StringStream.Free;
      end;
    finally
      Builder.Free;
    end
  except
    on E: ESyntaxTreeException do
      writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]) + sLineBreak +
        sLineBreak + TSyntaxTreeWriter.ToXML(E.syntaxtree, True));
  end;
end;

function GetTestFolder(): string;
begin
  if DirectoryExists('..\..\..\test\data') then
    Result := '..\..\..\test\data\'
  else if DirectoryExists('..\test\data') then
    Result := '..\test\data'
  else
    raise Exception.Create('Can''t find test data folder.');
end;

procedure ApplicationRun();
var
  fname: string;
  unitmetrics: TUnitMetrics;
  idx: Integer;
begin
  writeln('DelphiAST Console Writer Demo');
  writeln('----------------------------------');
  fname := TPath.Combine(GetTestFolder, 'testunit.pas');
  unitmetrics := Parse(fname);
  try
    writeln(fname);
    for idx := 0 to unitmetrics.MethodsCount-1 do
      writeln('  - ',unitmetrics.Method[idx].ToString);
  finally
    if unitmetrics<>nil then
      unitmetrics.Free;
  end;
  readln;
end;

end.
