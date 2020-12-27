unit Metrics.UnitM;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  {--}
  Utils.IntegerArray,
  Metrics.UnitMethod;

type
  TUnitMetrics = class
  private
    fName: string;
    fMethods: TObjectList<TUnitMethodMetrics>;
  public
    constructor Create(const aUnitName: string);
    destructor Destroy; override;
    property Name: string read fName;
    function MethodsCount(): Integer;
    function GetMethod(aIdx: Integer): TUnitMethodMetrics;
    function GetMethods: TList<TUnitMethodMetrics>;
    function GetMethodsSorted(const aNameofClass: string = '')
      : TArray<TUnitMethodMetrics>;
    procedure AddMethod(const aMethodMetics: TUnitMethodMetrics);
  end;

implementation

constructor TUnitMetrics.Create(const aUnitName: string);
begin
  self.fName := aUnitName;
  fMethods := TObjectList<TUnitMethodMetrics>.Create();
end;

destructor TUnitMetrics.Destroy;
begin
  fMethods.Free;
  inherited;
end;

function TUnitMetrics.GetMethod(aIdx: Integer): TUnitMethodMetrics;
begin
  Result := fMethods[aIdx];
end;

function TUnitMetrics.GetMethods: TList<TUnitMethodMetrics>;
begin
  Result := fMethods;
end;

function TUnitMetrics.GetMethodsSorted(const aNameofClass: string)
  : TArray<TUnitMethodMetrics>;
var
  sorted: TList<TUnitMethodMetrics>;
  method: TUnitMethodMetrics;
begin
  sorted := TList<TUnitMethodMetrics>.Create();
  try
    if aNameofClass <> '' then
    begin
      for method in fMethods do
        if method.Name.StartsWith(aNameofClass + '.') then
          sorted.Add(method);
    end
    else
      sorted.AddRange(fMethods);
    sorted.Sort(TComparer<TUnitMethodMetrics>.Construct(
      function(const Left, Right: TUnitMethodMetrics): Integer
      begin
        Result := TComparer<string>.Default.Compare(Left.Name.ToUpper,
          Right.Name.ToUpper)
      end));
    Result := sorted.ToArray;
  finally
    sorted.Free;
  end;
end;

function TUnitMetrics.MethodsCount: Integer;
begin
  Result := fMethods.Count;
end;

procedure TUnitMetrics.AddMethod(const aMethodMetics: TUnitMethodMetrics);
begin
  fMethods.Add(aMethodMetics);
end;

end.
