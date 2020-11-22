unit Main;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Diagnostics;

procedure ApplicationRun();

implementation

uses
  Command.AnalyseUnit;

function GetTestFolder(): string;
begin
  if DirectoryExists('..\..\..\test\data') then
    Result := '..\..\..\test\data\'
  else if DirectoryExists('..\test\data') then
    Result := '..\test\data'
  else
    raise Exception.Create('Can''t find test data folder.');
end;

procedure ApplicationRun();
var
  fname: string;
begin
  writeln('DelphiAST - Static Code Analyser');
  writeln('----------------------------------');
  fname := TPath.Combine(GetTestFolder, 'testunit.pas');
  TAnalyseUnitCommand.Execute(fname);
  readln;
end;

end.
