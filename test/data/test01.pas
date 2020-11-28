unit test01;

interface

uses
  System.SysUtils;

procedure StoreMessage(const aTemplateFolder: string;
  const TemplateFileName: string);

implementation

procedure FileFromString(const aLines: string; const aFileName: string);
begin
end;

procedure StoreMessage(const aTemplateFolder: string;
  const TemplateFileName: string);
begin
  if (aTemplateFolder = '') and not FileExists(string(TemplateFileName)) then
    FileFromString('Welcome to {{Application}}!' + sLineBreak + sLineBreak +
      'Please click on the button:' + sLineBreak,
      UTF8ToString(TemplateFileName));
end;

end.
