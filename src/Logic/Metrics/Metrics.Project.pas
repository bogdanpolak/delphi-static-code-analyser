unit Metrics.Project;

interface

uses
  System.Generics.Collections,
  {--}
  Metrics.ClassM;

type
  TProject = class
  private
    fClasses: TObjectList<TClassMetrics>;
  public
    constructor Create();
    destructor Destroy; override;
    function ClassCount(): Integer;
    function GetClass(aIdx: Integer): TClassMetrics;
    procedure AddClass(const aClassMetrics: TClassMetrics);
  end;

implementation

constructor TProject.Create;
begin
  fClasses := TObjectList<TClassMetrics>.Create();
end;

destructor TProject.Destroy;
begin
  fClasses.Free;
  inherited;
end;

procedure TProject.AddClass(const aClassMetrics: TClassMetrics);
begin
  fClasses.Add(aClassMetrics);
end;

function TProject.ClassCount: Integer;
begin
  Result:=fClasses.Count;
end;

function TProject.GetClass(aIdx: Integer): TClassMetrics;
begin
  Result:=fClasses.Items[aIdx];
end;

end.
