unit Command.AnalyseFolder;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.IOUtils;

type
  TAnalyseFolderCommand = class
  public
    class procedure Execute(aFolderPath: string;
      aDisplayLevelHigherThan: Integer = 0); static;
    class procedure Execute_GenerateCsv(aFolderPath: string;
      aDisplayLevelHigherThan: Integer = 0); static;
  end;

implementation

uses
  Command.AnalyseUnit;

class procedure TAnalyseFolderCommand.Execute(aFolderPath: string;
  aDisplayLevelHigherThan: Integer = 0);
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
      TAnalyseUnitCommand.Execute_CodeAnalysis(fname, aDisplayLevelHigherThan);
    end;
  end
end;

class procedure TAnalyseFolderCommand.Execute_GenerateCsv(aFolderPath: string;
  aDisplayLevelHigherThan: Integer);
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
      TAnalyseUnitCommand.Execute_GenerateCsv(fname, aDisplayLevelHigherThan);
    end;
  end
end;

end.
