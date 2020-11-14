unit Analitics.SyntaxTreeWriter;

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST.Classes;

type
  TSyntaxTreeAnalitycsWriter = class
  public
    class procedure Generate(const Root: TSyntaxNode); static;
  end;

implementation

uses
  Generics.Collections,
  DelphiAST.Consts;


procedure NodeTreeWalker(const Node: TSyntaxNode);
var
  ChildNode: TSyntaxNode;
  len: Integer;
  attr: TPair<TAttributeName, string>;
  kind: string;
  methodname: string;
begin
  if Node.Typ = ntInterface then
    exit;
  if Node.Typ = ntMethod then
  begin
    len := TCompoundSyntaxNode(Node).EndLine - TCompoundSyntaxNode
      (Node).Line + 1;
    kind := Node.GetAttribute(anKind);
    methodname := Node.GetAttribute(anName);
    writeln(Format('   - %s %s = [%d]', [kind, methodname, len]));
    exit;
  end;
  for ChildNode in Node.ChildNodes do
    NodeTreeWalker(ChildNode);
end;


class procedure TSyntaxTreeAnalitycsWriter.Generate(const Root: TSyntaxNode);
begin
  NodeTreeWalker(Root);
end;

end.
