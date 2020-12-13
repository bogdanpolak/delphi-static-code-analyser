unit Model.ClassMetrics;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  {--}
  Model.ClassMethod;

type
  TClassMetrics = class
  private
    fUnitFullPath: string;
    fNameOfClass: string;
    fNameOfUnit: string;
    fClassMethods: TList<TClassMethod>;
  public
    constructor Create(const aUnitFullPath: string; const aNameOfClass: string);
    destructor Destroy; override;
    {}
    function AddClassMethod(const aClassMethod: TClassMethod): TClassMetrics;
    function MethodCount: Integer;
    function GetMethod(const aIdx: Integer): TClassMethod;
    {}
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
  fClassMethods := TList<TClassMethod>.Create;
end;

destructor TClassMetrics.Destroy;
begin
  fClassMethods.Free;
  inherited;
end;

function TClassMetrics.AddClassMethod(
  const aClassMethod: TClassMethod): TClassMetrics;
begin
  Result := self;
  fClassMethods.Add(aClassMethod);
end;

function TClassMetrics.GetMethod(const aIdx: Integer): TClassMethod;
begin
  Result := fClassMethods[aIdx];
end;

function TClassMetrics.MethodCount: Integer;
begin
  Result := fClassMethods.Count;
end;

end.
