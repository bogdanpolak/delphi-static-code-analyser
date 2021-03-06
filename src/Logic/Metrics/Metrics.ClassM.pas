unit Metrics.ClassM;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
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
    { }
    procedure AddClassMethod(aVisibility: TVisibility; const aName: string);
    function MethodCount: Integer;
    function GetMethod(const aIdx: Integer): TClassMethodMetrics;
    function GetMethods(): TArray<TClassMethodMetrics>;
    function GetMethodsSorted: TArray<TClassMethodMetrics>;
    { }
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

function TClassMetrics.GetMethodsSorted: TArray<TClassMethodMetrics>;
var
  classMethodMetricsList: TList<TClassMethodMetrics>;
begin
  classMethodMetricsList := TList<TClassMethodMetrics>.Create();
  try
    classMethodMetricsList.AddRange(fClassMethods);
    classMethodMetricsList.Sort(TComparer<TClassMethodMetrics>.Construct(
      function(const Left, Right: TClassMethodMetrics): Integer
      begin
        Result := TComparer<string>.Default.Compare(Left.Name.ToUpper,
          Right.Name.ToUpper)
      end));
    Result := classMethodMetricsList.ToArray;
  finally
    classMethodMetricsList.Free;
  end;
end;

function TClassMetrics.MethodCount: Integer;
begin
  Result := fClassMethods.Count;
end;

end.
