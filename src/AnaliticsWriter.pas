unit AnaliticsWriter;

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST.Classes;

type
  TSyntaxTreeConsoleWriter = class
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
  methodname: string;
  attr: TPair<TAttributeName, string>;
  s: string;
  mkind: string;
  mname: string;
begin
  if Node.Typ = ntInterface then
    exit;
  if Node.Typ = ntMethod then
  begin
    len := TCompoundSyntaxNode(Node).EndLine - TCompoundSyntaxNode
      (Node).Line + 1;
    for attr in Node.Attributes do
      if attr.Key = anKind then
        mkind := attr.Value
      else if attr.Key = anName then
        mname := attr.Value;
    methodname := mkind + ' ' + mname;
    writeln(Format('   - %s = [%d]', [methodname, len]));
    exit;
  end;
  for ChildNode in Node.ChildNodes do
    NodeTreeWalker(ChildNode);
end;


class procedure TSyntaxTreeConsoleWriter.Generate(const Root: TSyntaxNode);
begin
  NodeTreeWalker(Root);
end;

end.
