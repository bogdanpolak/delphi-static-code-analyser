unit Helper.TSyntaxNode;

interface

uses
  DelphiAST.Consts,
  DelphiAST.Classes;

type
  TSyntaxNodeExtention = class helper for TSyntaxNode
  public
    function HasClassChildNode(): boolean;
    function IsTypeDeclaration(): boolean;
    function IsClassNode(): boolean;
  end;

implementation

function TSyntaxNodeExtention.HasClassChildNode(): boolean;
begin
  Result := (Self.HasChildren) and (Self.ChildNodes[0].typ = ntType) and
    (Self.ChildNodes[0].GetAttribute(anType) = 'class');
end;

function TSyntaxNodeExtention.IsClassNode(): boolean;
begin
  Result := (Self.IsTypeDeclaration()) and (Self.HasClassChildNode());
end;

function TSyntaxNodeExtention.IsTypeDeclaration(): boolean;
begin
  Result := (Self.typ = ntTypeDecl);
end;

end.
