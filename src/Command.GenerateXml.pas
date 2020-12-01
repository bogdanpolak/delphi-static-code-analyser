unit Command.GenerateXml;

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Writer;

type
  TGenerateXmlCommand = class
  private
    class function GenerateXml(const aStream: TStream): string; static;
  public
    class procedure Execute(const aFileName: string); static;
  end;

implementation

class function TGenerateXmlCommand.GenerateXml(const aStream: TStream): string;
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

class procedure TGenerateXmlCommand.Execute(const aFileName: string);
var
  stringStream: TStringStream;
  text: string;
begin
  stringStream := TStringStream.Create;
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
