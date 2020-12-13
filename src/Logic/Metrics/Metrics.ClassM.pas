unit Metrics.ClassM;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  {--}
  Metrics.ClassMethod;

type
  TClassMetrics = class
  private
    fUnitFullPath: string;
    fNameOfClass: string;
    fNameOfUnit: string;
    fClassMethods: TList<TClassMethodMetrics>;
  public
    constructor Create(const aUnitFullPath: string; const aNameOfClass: string);
    destructor Destroy; override;
    {}
    function AddClassMethod(const aClassMethod: TClassMethodMetrics): TClassMetrics;
    function MethodCount: Integer;
    function GetMethod(const aIdx: Integer): TClassMethodMetrics;
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
  fClassMethods := TList<TClassMethodMetrics>.Create;
end;

destructor TClassMetrics.Destroy;
begin
  fClassMethods.Free;
  inherited;
end;

function TClassMetrics.AddClassMethod(
  const aClassMethod: TClassMethodMetrics): TClassMetrics;
begin
  Result := self;
  fClassMethods.Add(aClassMethod);
end;

function TClassMetrics.GetMethod(const aIdx: Integer): TClassMethodMetrics;
begin
  Result := fClassMethods[aIdx];
end;

function TClassMetrics.MethodCount: Integer;
begin
  Result := fClassMethods.Count;
end;

end.
