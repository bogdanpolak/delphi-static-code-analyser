unit test05.UnitWithClass;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.StdCtrls;

type
  IAppHandler = interface
    ['{4A8D64B3-49E8-4A47-B11C-69F33C4A57C5}']
    function TryGetContent(const aParent: string; out Content: string): Boolean;
  end;

  THandler = class(TInterfacedObject, IAppHandler)
  private
    fPath: string;
  public
    constructor Create(const Path: string);
    function TryGetContent(const aParent: string; out Content: string): Boolean;
  end;

  TTestForm = class(TForm)
    memLog: TMemo;
    btnRun: TButton;
    procedure btnRunClick(Sender: TObject);
  private
    isLoaded: Boolean;
  public
    constructor Create(aOwner: TComponent); override;
  end;

implementation

uses
  System.IOUtils;

{ THandler }

constructor THandler.Create(const Path: string);
begin
  inherited Create;
  fPath := Path;
end;

function THandler.TryGetContent(const aParent: string;
  out Content: string): Boolean;
var
  slContent: TStringList;
  fn: string;
begin
  fn := TPath.Combine(fPath, 'log-' + aParent + '.csv');
  if not FileExists(fn) then
    exit(False);
  slContent := TStringList.Create;
  try
    slContent.LoadFromFile(fn);
    Content := slContent.Text;
    Result := True;
  finally
    slContent.Free;
  end;
end;

{ TTestForm }

constructor TTestForm.Create(aOwner: TComponent);
begin
  inherited;
  inherited;
  memLog := TMemo.Create(Self);
  with memLog do
  begin
    Left := 0;
    Top := 0;
    Width := 687;
    Height := 193;
    ScrollBars := ssBoth;
  end;
end;

procedure TTestForm.btnRunClick(Sender: TObject);
var
  Path, FileName: string;
begin
  memLog.Clear;
  Path := ExtractFilePath(Application.ExeName) + 'Snippets\';
  for FileName in TDirectory.GetFiles(Path, '*.pas',
    TSearchOption.soAllDirectories) do
  begin
    try
      memLog.Lines.Add('OK:     ' + FileName);
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

end.
