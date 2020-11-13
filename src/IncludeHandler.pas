unit IncludeHandler;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
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

implementation

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
    if not FileExists(TPath.Combine(FPath, IncludeName)) then
    begin
      Result := False;
      Exit;
    end;

    FileContent.LoadFromFile(TPath.Combine(FPath, IncludeName));
    Content := FileContent.Text;
    FileName := TPath.Combine(FPath, IncludeName);

    Result := True;
  finally
    FileContent.Free;
  end;
end;

end.
