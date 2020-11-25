unit Command.AnalyseFolder;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.IOUtils;

type
  TAnalyseFolderCommand = class
  public
    class procedure Execute(aFolderPath: string); static;
  end;

implementation

uses
  Command.AnalyseUnit;

class procedure TAnalyseFolderCommand.Execute(aFolderPath: string);
var
  files: TArray<string>;
  fname: string;
begin
  if TDirectory.Exists(aFolderPath) then
  begin
    files := TDirectory.GetFiles(aFolderPath, '*.pas',
      TSearchOption.soAllDirectories);
    for fname in files do
    begin
      TAnalyseUnitCommand.Execute(fname);
    end;
  end
end;

end.
