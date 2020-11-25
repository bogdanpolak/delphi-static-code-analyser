unit Main;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Diagnostics;

type
  TApplicationMode = (amFolderAnalysis, amFileAnalysis, amGenerateXml);

const
  ApplicationMode: TApplicationMode = amFolderAnalysis;

procedure ApplicationRun();

implementation

uses
  Command.AnalyseUnit,
  Command.AnalyseFolder;

function GetTestFolder(): string;
begin
  if DirectoryExists('..\..\..\test\data') then
    Result := '..\..\..\test\data\'
  else if DirectoryExists('..\test\data') then
    Result := '..\test\data'
  else
    raise Exception.Create('Can''t find test data folder.');
end;

function IsDeveloperMode(): boolean;
var
  dprFileName: string;
begin
  dprFileName :=  ChangeFileExt(ExtractFileName(ParamStr(0)),'.dpr');
  Result := FileExists('..\..\'+dprFileName) or FileExists(dprFileName);
end;

function GetSampleFilePath(): string;
begin
  Result := TPath.Combine(GetTestFolder, 'testunit.pas');
end;

procedure ConsoleApplicationHeader();
begin
  writeln('DelphiAST - Static Code Analyser');
  writeln('----------------------------------');
end;

procedure RunAnalysisOnFolder();
begin
  ConsoleApplicationHeader();
  TAnalyseFolderCommand.Execute(GetTestFolder + 'mORMot');
end;

procedure RunAnalysisOnFile();
begin
  ConsoleApplicationHeader();
  TAnalyseUnitCommand.Execute(GetSampleFilePath());
end;

procedure ApplicationRun();
begin
  case ApplicationMode of
    amFolderAnalysis:
      RunAnalysisOnFolder();
    amFileAnalysis:
      RunAnalysisOnFile();
    amGenerateXml:
      TAnalyseUnitCommand.Execute(GetSampleFilePath(), camGenerateXml);
  end;
  if IsDeveloperMode then
    readln;
end;

end.
