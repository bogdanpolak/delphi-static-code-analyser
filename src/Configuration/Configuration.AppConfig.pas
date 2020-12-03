unit Configuration.AppConfig;

interface

type
  IAppConfiguration = interface(IInvokable)
    ['{974BDED1-7D77-4C34-8D3B-76EBADD58D9E}']
    procedure Initialize;
    function GetSourceFolders: TArray<string>;
    function GetOutputFile: string;
  end;

implementation

end.
