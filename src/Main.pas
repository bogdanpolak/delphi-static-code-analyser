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
  Analitics.SyntaxTreeWriter;

function Parse(const FileName: string): string;
var
  syntaxtree: TSyntaxNode;
  Builder: TPasSyntaxTreeBuilder;
  StringStream: TStringStream;
begin
  Result := '';
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
          TSyntaxTreeAnalitycsWriter.Generate(syntaxtree);
          // writeln(TSyntaxTreeWriter.ToXML(syntaxtree,true));
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
  s: string;
  fname: string;
begin
  writeln('DelphiAST Console Writer Demo');
  fname := TPath.Combine(GetTestFolder, 'testunit.pas');
  s := Parse(fname);
  writeln(s);
  readln;
end;

end.
