unit test05.UnitWithClass;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  {}
  test05.Support;

type
  TDataIngestorForm = class(TForm)
    btnLoadData: TButton;
    btnProcessData: TButton;
    btnClearLog: TButton;
    memJSONData: TMemo;
    edtFileToLoad: TEdit;
    memProcessorLog: TMemo;
    rbtnFromDatabase: TRadioButton;
    rbtnFromFile: TRadioButton;
    rbtnFromMemo: TRadioButton;
    procedure btnLoadDataClick(Sender: TObject);
    procedure btnProcessDataClick(Sender: TObject);
    procedure FormOnShow(Sender: TObject);
  private
    fIsLoaded: Boolean;
    fJSONProvider: IStringProvider;
    fPurchasesProxy: TPurchasesDBProxy;
    fInventoryProxy: TInventoryDBProxy;
    fLogger: ILogger;
    fDataJSON: TJSONArray;
    procedure DoLoadData(); overload;
    procedure DoLoadData(const aJsonString: string;
      aLoggingMode: TLoggingMode); overload;
    procedure DoLoadData(const aFilePath: string); overload;
    class procedure DoProcessData(const aDataJSON: TJSONArray;
      const aPurchasesProxy: TPurchasesDBProxy;
      const aInventoryProxy: TInventoryDBProxy); static;
  public
    constructor Create(aOwner: TComponent); override;
    [InjectDBProvider('SelectRecentJSONForCustomer')]
    function WithJSONProvider(aJSONProvider: IStringProvider)
      : TDataIngestorForm;
    function WithLogger(aLogger: ILogger): TDataIngestorForm;
    function WithDBProxies(const aPurchasesProxy: TPurchasesDBProxy;
      const aInventoryProxy: TInventoryDBProxy): TDataIngestorForm;
  end;

implementation

uses
  System.IOUtils;

resourcestring
  ERROR_LoadData_FromDatabase = 'Not able to load data from database';
  ERROR_InvalidDataStructure = 'Provided invaild JSON data, not able to read';
  ERROR_ExpectedJSONArray = 'Expected data to be formatted as JSON array';
  ERROR_JSONCollectioEmpty = 'JSON Data collection is empty';
  ERROR_ProcessorFailure = 'Not able to process JSON data';

constructor TDataIngestorForm.Create(aOwner: TComponent);
begin
  inherited;
  fLogger := nil;
  fJSONProvider := nil;
  fPurchasesProxy := nil;
  fInventoryProxy := nil;
end;

procedure TDataIngestorForm.FormOnShow(Sender: TObject);
begin
  rbtnFromMemo.Checked := True;
  memProcessorLog.Clear;
end;

procedure TDataIngestorForm.DoLoadData();
var
  jsonString: string;
begin
  Assert(fJSONProvider <> nil);
  if not fJSONProvider.TryGetString('data', jsonString) then
  begin
    fLogger.LogCriticalError(ERROR_LoadData_FromDatabase, []);
    ShowMessage(Format('Critical Error: %s', [ERROR_LoadData_FromDatabase]));
  end;
  Self.DoLoadData(jsonString, lmLoggingActive);
end;

procedure TDataIngestorForm.DoLoadData(const aJsonString: string;
  aLoggingMode: TLoggingMode);
var
  jsonValue: TJSONValue;
  jsonArray: TJSONArray;
begin
  fIsLoaded := False;
  fDataJSON := nil;
  jsonValue := TJSONObject.ParseJSONValue(aJsonString);
  if jsonValue = nil then
  begin
    if aLoggingMode = lmLoggingActive then
    begin
      fLogger.LogError(ERROR_InvalidDataStructure, []);
    end;
    ShowMessage(Format('Error: %s', [ERROR_InvalidDataStructure]));
    exit;
  end;
  if not(jsonValue is TJSONArray) then
  begin
    if aLoggingMode = lmLoggingActive then
    begin
      fLogger.LogError(ERROR_ExpectedJSONArray, []);
    end;
    ShowMessage(Format('Error: %s', [ERROR_ExpectedJSONArray]));
    exit;
  end;
  jsonArray := jsonValue as TJSONArray;
  if jsonArray.Count = 0 then
  begin
    if aLoggingMode = lmLoggingActive then
    begin
      fLogger.LogError(ERROR_JSONCollectioEmpty, []);
    end;
    ShowMessage(Format('Error: %s', [ERROR_JSONCollectioEmpty]));
  end;
  fIsLoaded := True;
  fDataJSON := jsonArray;
end;

procedure TDataIngestorForm.DoLoadData(const aFilePath: string);
var
  ss: TStringStream;
begin
  ss := TStringStream.Create('', TEncoding.UTF8);
  try
    ss.LoadFromFile(aFilePath);
    Self.DoLoadData(ss.DataString, lmLoggingActive);
  finally
    ss.Free;
  end;
end;

function TDataIngestorForm.WithDBProxies(const aPurchasesProxy
  : TPurchasesDBProxy; const aInventoryProxy: TInventoryDBProxy)
  : TDataIngestorForm;
begin
  fPurchasesProxy := aPurchasesProxy;
  fInventoryProxy := aInventoryProxy;
  Result := Self;
end;

function TDataIngestorForm.WithJSONProvider(aJSONProvider: IStringProvider)
  : TDataIngestorForm;
begin
  fJSONProvider := aJSONProvider;
  rbtnFromDatabase.Checked := True;
  Result := Self;
end;

function TDataIngestorForm.WithLogger(aLogger: ILogger): TDataIngestorForm;
begin
  fLogger := aLogger;
  Result := Self;
end;

class procedure TDataIngestorForm.DoProcessData(const aDataJSON: TJSONArray;
  const aPurchasesProxy: TPurchasesDBProxy;
  const aInventoryProxy: TInventoryDBProxy);
begin
  ShowMessage
    ('[WIP] Data Processor - Sorry! That functionality is under development');
end;

procedure TDataIngestorForm.btnProcessDataClick(Sender: TObject);
begin
  if fIsLoaded then
  begin
    try
      DoProcessData(fDataJSON, fPurchasesProxy, fInventoryProxy);
    except
      on E: EDataProcessorError do
      begin
        if fPurchasesProxy = nil then
        begin
          fLogger.LogError(ERROR_ProcessorFailure, []);
          fLogger.LogInfo(
            { } '{"type":"error",' +
            { } ' "exception":"%s",' +
            { } ' "message":"%s",' +
            { } ' "data":"%s"}',
            { } [E.ClassName, ERROR_ProcessorFailure, fDataJSON.ToString]);
        end;
      end;
      on E: Exception do
      begin
        fLogger.LogCriticalError('Unhandled exception: Type:%s Message:"%s"',
          [E.ClassType, E.Message]);
        if fPurchasesProxy = nil then
          fLogger.LogInfo('Not initilized Purchase DBProxy (%s)',
            [TPurchasesDBProxy.ClassName]);
        if fInventoryProxy = nil then
          fLogger.LogInfo('Not initilized Inventory DBProxy (%s)',
            [TInventoryDBProxy.ClassName]);
        raise;
      end;
    end;
  end;

end;

procedure TDataIngestorForm.btnLoadDataClick(Sender: TObject);
begin
  if rbtnFromDatabase.Checked then
    Self.DoLoadData()
  else if rbtnFromMemo.Checked then
    Self.DoLoadData(memJSONData.Text, lmLoggingDisable)
  else if rbtnFromFile.Checked then
    Self.DoLoadData(edtFileToLoad.Text);
end;

end.
