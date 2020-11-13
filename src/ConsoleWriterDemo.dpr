program ConsoleWriterDemo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Main in 'Main.pas';

begin
  try
    ApplicationRun();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
