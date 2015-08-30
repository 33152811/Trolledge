unit uPluginUtils;

interface
uses
    System.JSON, Soap.XSBuiltIns, System.SysUtils, System.Classes, System.IOUtils,
    IdTCPClient,
    IdHTTP,
    REST.Client;
    /// <summary>
    /// �������� JSON �� Null & empty
    /// </summary>
    function ValidateJSONObject(AJsonValue : TJsonValue; var tempJson : TJSONObject) : Boolean; Overload;
    function ValidateJSONObject(AJsonValue : TJsonValue; var tempJson : string) : Boolean; Overload;
    /// <summary>
    /// ������� UTC ������ ������� � �������
    /// </summary>
    function UtcToNative(var dateTime : TDateTime; Utc : string) : Boolean;
    /// <summary>
    /// ������� ������� ������ ������� � UTC
    /// </summary>
    function NativeToUtc(dateTime : TDateTime; var Utc : string) : Boolean;
    /// <summary>
    /// �������� JSONArray �� Null & empty
    /// </summary>
    function ValidateJSONArray(AJsonValue : TJsonValue; var tempJson : TJSONArray) : Boolean;
    /// <summary>
    /// �������� ���������
    /// </summary>
    function CheckNetworkState : Boolean;
    /// <summary>
    /// ������ ������
    /// </summary>
    function HttpGetText(url : string; var st : TStringList) : Boolean;
    /// <summary>
    /// ������ �������� ������
    /// </summary>
    function HttpGetBinary(url : string; var stream : TMemoryStream) : Boolean;
    /// </summary>
    /// ������ ���� � �����
    /// </summary>
    function GetPath(dirName : string = '') : string;

implementation
{------------------------------------------------------------------------------}
/// �������� JSON �� Null & empty
function ValidateJSONObject(AJsonValue : TJsonValue; var tempJson : TJSONObject) : Boolean;
var
    res : Boolean;
    temp : string;
begin
  Result := True;
  try
    if not Assigned(AJsonValue) then
        Exit(True);
    res := AJsonValue.Null;
    temp := AJsonValue.Value;
    if res then
        Exit;
    tempJson := AJsonValue as TJSONObject;
    if not Assigned(tempJson) then
    begin
        res := true;
    end;
  except
    res := True;
  end;
  Result := res;
end;
{------------------------------------------------------------------------------}
function ValidateJSONObject(AJsonValue : TJsonValue; var tempJson : string) : Boolean;
var
    res : Boolean;
    temp : string;
begin
  Result := True;
  try
    if not Assigned(AJsonValue) then
        Exit(True);
    res := AJsonValue.Null;
    temp := AJsonValue.Value;
    if res then
        Exit;
    tempJson := temp;
  except
    res := True;
  end;
  Result := res;
end;
{------------------------------------------------------------------------------}
/// ������� UTC ������ ������� � �������
function UtcToNative(var dateTime : TDateTime; Utc : string) : Boolean;
var
    utcTime : TXsDateTime;
begin
    if Utc.IsEmpty then
        Exit;
    utcTime := TXsDateTime.Create;
    try
        utcTime.XSToNative(Utc);
        dateTime := utcTime.AsDateTime;
    finally
        FreeAndNil(utcTime);
    end;
end;
{------------------------------------------------------------------------------}
/// ������� ������� ������ ������� � UTC
function NativeToUtc(dateTime : TDateTime; var Utc : string) : Boolean;
var
    utcTime : TXsDateTime;
begin
    utcTime := TXsDateTime.Create;
    try
        utcTime.AsDateTime := dateTime;
        Utc := utcTime.NativeToXS;
    finally
        FreeAndNil(utcTime);
    end;
end;
{------------------------------------------------------------------------------}
/// �������� JSONArray �� Null & empty
function ValidateJSONArray(AJsonValue : TJsonValue; var tempJson : TJSONArray) : Boolean;
var
    res : Boolean;
    temp : string;
begin
  Result := True;
  try
    if not Assigned(AJsonValue) then
        Exit(True);
    res := AJsonValue.Null;
    if res then
        Exit;
    tempJson := AJsonValue as TJSONArray;
    if not Assigned(tempJson) then
    begin
        res := true;
    end;
  except
    res := True;
  end;
  Result := res;
end;
{------------------------------------------------------------------------------}
/// �������� ���������
function CheckNetworkState : Boolean;
var
  TCP : TIdTCPClient;
begin
    TCP:=TIdTCPClient.Create(nil);
    try
        TCP.Host := 'www.google.com';
        TCP.Port := 80;
        TCP.ReadTimeout := 1000;
        try
              TCP.Connect;
              Result := TCP.Connected;
        except
              Result := false;
        end;
    finally
        FreeAndNil(TCP);
    end;
end;
{------------------------------------------------------------------------------}
/// ������ ������
function HttpGetText(url : string; var st : TStringList) : Boolean;
var
    stream : TMemoryStream;
begin
    Result := false;
    if string.IsNullOrEmpty(url) then
        exit;
    if not Assigned(st) then
        st := TStringList.Create;
    stream := TMemoryStream.Create;
    try
        REST.Client.TDownloadURL.DownloadRawBytes(url, stream);
        st.LoadFromStream(stream);
    except
    end;
    FreeAndNil(stream);
    Result := not st.Text.IsEmpty;
end;
{------------------------------------------------------------------------------}
/// ������ �������� ������
function HttpGetBinary(url : string; var stream : TMemoryStream) : Boolean;
begin
    Result := false;
    if string.IsNullOrEmpty(url) then
        exit;
    if not Assigned(stream) then
        stream := TMemoryStream.Create;
    try
        REST.Client.TDownloadURL.DownloadRawBytes(url, stream);
    except
    end;
    stream.Position := 0;
    Result := True;
end;
{------------------------------------------------------------------------------}
/// ������ ���� � �����
function GetPath(dirName : string) : string;
var
    Path : string;
begin
    {$IFDEF MSWINDOWS}
      Path := ExtractFilePath(ParamStr(0));
    {$ELSE}
      Path := System.IOUtils.TPath.GetDocumentsPath;
    {$ENDIF}
    //Path := Path + System.SysUtils.PathDelim;
    if not dirName.IsEmpty then
        Path := Path + dirName + System.SysUtils.PathDelim;
    Result := Path;
end;
{------------------------------------------------------------------------------}
end.
