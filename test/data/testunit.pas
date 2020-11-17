unit testunit;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
  {$IFNDEF FPC}
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  {$ELSE}
    SysUtils, Variants, Classes, Controls, Forms, StdCtrls,
  {$ENDIF}
  SimpleParser.Lexer.Types;

type
  TIncludeHandler = class(TInterfacedObject, IIncludeHandler)
  private
    FPath: string;
  public
    constructor Create(const Path: string);
    function GetIncludeFileContent(const ParentFileName, IncludeName: string;
      out Content: string; out FileName: string): Boolean;
  end;

  TTestForm = class(TForm)
    memLog: TMemo;
    btnRun: TButton;
    procedure btnRunClick(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(aOwner: TComponent); override;
  end;

implementation

uses
  FileCtrl, IOUtils, DelphiAST, DelphiAST.Classes;

procedure Test01;
var
  I: Integer;
  a: Integer;
  b: Integer;
begin
  for I := 0 to 5 do
    a := a + I;
  for i := 0 to 4 do
  begin
    b := a + i;
    a := a - i div 2;
  end;
  while a>0 do
    a := a - 1;
  while a<10 do
  begin
    a := a + 1;
    b := b - 1;
  end;
  if a>0 then
    a := a - 1
  else
    a := a + 1;
  if a<10 then
  begin
    a := a + 1;
    b := b + 1;
  end
  else
  begin
    a := a - 1;
    b := b - 1;
  end
end;

procedure TTestForm.btnRunClick(Sender: TObject);
var
  Path, FileName: string;
  SyntaxTree: TSyntaxNode;
begin
  memLog.Clear;

  Path := ExtractFilePath(Application.ExeName) + 'Snippets\';
  if not SelectDirectory('Select Folder', '', Path) then
    Exit;

  for FileName in TDirectory.GetFiles(Path, '*.pas', TSearchOption.soAllDirectories) do
  begin
    try
      SyntaxTree := TPasSyntaxTreeBuilder.Run(FileName, False, TIncludeHandler.Create(Path));
      try
        memLog.Lines.Add('OK:     ' + FileName);
      finally
        SyntaxTree.Free;
      end;
    except
      on E: Exception do
      begin
        memLog.Lines.Add('FAILED: ' + FileName);
        memLog.Lines.Add('        ' + E.ClassName);
        memLog.Lines.Add('        ' + E.Message);
        memLog.Repaint;
      end;
    end;
  end;
end;

{ TIncludeHandler }

constructor TIncludeHandler.Create(const Path: string);
begin
  inherited Create;
  FPath := Path;
end;

function TIncludeHandler.GetIncludeFileContent(const ParentFileName, IncludeName: string;
  out Content: string; out FileName: string): Boolean;
var
  FileContent: TStringList;
begin
  FileContent := TStringList.Create;
  try
    FileName := TPath.Combine(FPath, IncludeName);
    FileContent.LoadFromFile(FileName);
    Content := FileContent.Text;
    Result := True;
  finally
    FileContent.Free;
  end;
end;

constructor TTestForm.Create(aOwner: TComponent);
begin
  inherited;
  Self.Caption := 'DelphiAST Test Application';
  Self.ClientHeight := 231;
  Self.ClientWidth := 687;
  memLog := TMemo.Create(Self);
  with memLog do begin
    Left := 0;
    Top := 0;
    Width := 687;
    Height := 193;
    Anchors := [akLeft, akTop, akRight, akBottom];
    ScrollBars := ssBoth
  end;
  btnRun := TButton.Create(Self);
  with btnRun do begin
    Left := 604;
    Top := 198;
    Width := 75;
    Height := 25;
    Anchors := [akRight, akBottom];
    Caption := 'Run';
    OnClick := btnRunClick;
  end;
end;

end.
