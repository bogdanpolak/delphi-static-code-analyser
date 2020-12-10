unit Model.ClassMetrics;

interface

uses
  System.SysUtils;

type
  TClassMetrics = class
  private
    fUnitFullPath: string;
    fNameOfClass: string;
    fNameOfUnit: string;
  public
    constructor Create(const aUnitFullPath: string;
      const aNameOfClass: string);
    property UnitFullPath: string read fUnitFullPath;
    property NameOfClass: string read fNameOfClass;
    property NameOfUnit: string read fNameOfUnit;
  end;

implementation

constructor TClassMetrics.Create(const aUnitFullPath, aNameOfClass: string);
begin
  fUnitFullPath := aUnitFullPath;
  fNameOfClass := aNameOfClass;
  fNameOfUnit := ExtractFileName(fUnitFullPath);
end;

end.
