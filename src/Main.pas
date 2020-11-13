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

procedure Parse(const FileName: string; UseStringInterning: Boolean);
var
  SeyntaxTree: TSyntaxNode;
  sw: TStopwatch;
  StringPool: TStringPool;
  OnHandleString: TStringEvent;
  Builder: TPasSyntaxTreeBuilder;
  StringStream: TStringStream;
  xmlstring: String;
begin
  try
    if UseStringInterning then
    begin
      StringPool := TStringPool.Create;
      OnHandleString := StringPool.StringIntern;
    end
    else
    begin
      StringPool := nil;
      OnHandleString := nil;
    end;
    try
      Builder := TPasSyntaxTreeBuilder.Create;
      try
        StringStream := TStringStream.Create;
        try
          StringStream.LoadFromFile(FileName);

          Builder.IncludeHandler := TIncludeHandler.Create
            (ExtractFilePath(FileName));
          Builder.OnHandleString := OnHandleString;
          StringStream.Position := 0;

          SyntaxTree := Builder.Run(StringStream);
          try
            xmlstring := TSyntaxTreeWriter.ToXML(SyntaxTree, True);
          finally
            SyntaxTree.Free;
          end;
        finally
          StringStream.Free;
        end;
      finally
        Builder.Free;
      end
    finally
      if UseStringInterning then
        StringPool.Free;
    end;
    sw.Stop;
  except
    on E: ESyntaxTreeException do
      writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]) + sLineBreak +
        sLineBreak + TSyntaxTreeWriter.ToXML(E.SyntaxTree, True));
  end;
end;

procedure ApplicationRun();
begin
  writeln('DelphiAST Console Writer Demo');
  readln;
end;

end.
