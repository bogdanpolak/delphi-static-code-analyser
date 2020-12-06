unit test04;

interface

uses
  System.SysUtils;

implementation

function TInterfaceFactory.GetMethodsVirtualTable: pointer;
begin
  tmp := {$ifdef CPUX86}fMethodsCount*24{$endif}
         {$ifdef CPUX64}fMethodsCount*16{$endif}
         {$ifdef CPUARM}fMethodsCount*12{$endif}
         {$ifdef CPUAARCH64}($120 shr 2)+fMethodsCount*28{$endif};
end;

end.
