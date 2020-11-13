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
          Result := TSyntaxTreeWriter.ToXML(syntaxtree, True);
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

procedure ApplicationRun();
var
  s: string;
begin
  writeln('DelphiAST Console Writer Demo');
  s := Parse('C:\Sources\github\DelphiAST\Test\uMainForm.pas');
  writeln(s);
  readln;
end;

end.
