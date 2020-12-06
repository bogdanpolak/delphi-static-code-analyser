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
  public
    class procedure Generate(const aFileName: string); static;
  end;

implementation

class procedure TGenerateXmlCommand.Generate(const aFileName: string);
var
  syntaxRootNode: TSyntaxNode;
begin
  syntaxRootNode := TPasSyntaxTreeBuilder.Run(aFileName);
  try
    writeln(TSyntaxTreeWriter.ToXML(syntaxRootNode, True));
  finally
    syntaxRootNode.Free;
  end;
end;

end.
