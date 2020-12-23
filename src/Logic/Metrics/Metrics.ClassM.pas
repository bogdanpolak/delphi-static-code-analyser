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
    fClassMethods: TObjectList<TClassMethodMetrics>;
  public
    constructor Create(const aUnitFullPath: string; const aNameOfClass: string);
    destructor Destroy; override;
    {}
    procedure AddClassMethod(aVisibility: TVisibility; const aName: string);
    function MethodCount: Integer;
    function GetMethod(const aIdx: Integer): TClassMethodMetrics;
    function GetMethods(): TArray<TClassMethodMetrics>;
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
  fClassMethods := TObjectList<TClassMethodMetrics>.Create;
end;

destructor TClassMetrics.Destroy;
begin
  fClassMethods.Free;
  inherited;
end;

procedure TClassMetrics.AddClassMethod(aVisibility: TVisibility;
  const aName: string);
begin
  fClassMethods.Add(TClassMethodMetrics.Create(aVisibility, aName));
end;

function TClassMetrics.GetMethod(const aIdx: Integer): TClassMethodMetrics;
begin
  Result := fClassMethods[aIdx];
end;

function TClassMetrics.GetMethods: TArray<TClassMethodMetrics>;
begin
  Result := fClassMethods.ToArray;
end;

function TClassMetrics.MethodCount: Integer;
begin
  Result := fClassMethods.Count;
end;

end.
