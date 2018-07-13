unit FMX.Permissions.Android;

interface

uses
  System.Classes, System.generics.collections, System.Messaging, System.TypInfo, FMX.Dialogs, Androidapi.JNI.App, System.SysUtils, Androidapi.JNI.Embarcadero,
  Androidapi.JNI.JavaTypes, FMX.Platform.Android, Androidapi.JNI.GraphicsContentViewText, Androidapi.JNIBridge, Androidapi.Helpers;

type

  TAndroidPermission = (apREAD_CALENDAR, apWRITE_CALENDAR, apCAMERA, apCONTACTS, apREAD_CONTACTS, apWRITE_CONTACTS, apGET_ACCOUNTS, apLOCATION,
    apACCESS_FINE_LOCATION, apACCESS_COARSE_LOCATION, apMICROPHONE, apRECORD_AUDIO, apPHONE, apREAD_PHONE_STATE, apREAD_PHONE_NUMBERS, apCALL_PHONE,
    apANSWER_PHONE_CALLS, apREAD_CALL_LOG, apWRITE_CALL_LOG, apADD_VOICEMAIL, apUSE_SIP, apPROCESS_OUTGOING_CALLS, apSENSORS, apBODY_SENSORS, apSMS,
    apSEND_SMS, apRECEIVE_SMS, apREAD_SMS, apRECEIVE_WAP_PUSH, apRECEIVE_MMS, apSTORAGE, apREAD_EXTERNAL_STORAGE, apWRITE_EXTERNAL_STORAGE);

  TRequestPermissionsResultEvent = procedure(AAndroidPermission: TAndroidPermission; APermissions: TJavaObjectArray<JString>; AGrantResults: TJavaArray<Integer>) of object;

  TAndroidPermissions = class(TObject)
  private
    FonRequestPermissionsResult: TRequestPermissionsResultEvent;
    function AndroidPermissionToStr(AAndroidPermission: TAndroidPermission): string;
    procedure SetonRequestPermissionsResult(const Value: TRequestPermissionsResultEvent);
    procedure onReceivePermissionsResult(const ASender: TObject; const AMessage: TMessage);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function CheckPermission(AAndroidPermission: TAndroidPermission): Boolean;
    function checkSelfPermission(AAndroidPermission: TAndroidPermission): Integer;
    procedure requestPermissions(AAndroidPermission: TAndroidPermission);
    function shouldShowRequestPermissionRationale(AAndroidPermission: TAndroidPermission): Boolean;
    property onRequestPermissionsResult: TRequestPermissionsResultEvent read FonRequestPermissionsResult write SetonRequestPermissionsResult;
  end;

var
  AndroidPermissions: TAndroidPermissions;

implementation

{ TAndroidPermissions }

function TAndroidPermissions.AndroidPermissionToStr(AAndroidPermission: TAndroidPermission): string;
var
  LEnumStr: string;
begin
  LEnumStr := GetEnumName(TypeInfo(TAndroidPermission), Integer(AAndroidPermission));
  Result := 'android.permission.' + Copy(LEnumStr, 3, Length(LEnumStr) - 1);
end;

function TAndroidPermissions.CheckPermission(AAndroidPermission: TAndroidPermission): Boolean;
begin
  Result := checkSelfPermission(AAndroidPermission) = TJPackageManager.JavaClass.PERMISSION_GRANTED;
end;

function TAndroidPermissions.checkSelfPermission(AAndroidPermission: TAndroidPermission): Integer;
begin
  Result := TAndroidHelper.Context.checkSelfPermission(StringToJString(AndroidPermissionToStr(AAndroidPermission)));
end;

constructor TAndroidPermissions.Create;
begin
  TMessageManager.DefaultManager.SubscribeToMessage(TMessageResultPermissions, onReceivePermissionsResult);
end;

destructor TAndroidPermissions.Destroy;
begin

  inherited;
end;

procedure TAndroidPermissions.onReceivePermissionsResult(const ASender: TObject; const AMessage: TMessage);
var
  LRequestCode: Integer;
  LPermissions: TJavaObjectArray<JString>;
  LGrantResults: TJavaArray<Integer>;
begin
  if (AMessage <> nil) and (AMessage is TMessageResultPermissions) then
  begin
    LRequestCode := TMessageResultPermissions(AMessage).Value;
    LPermissions := TMessageResultPermissions(AMessage).Permissions;
    LGrantResults := TMessageResultPermissions(AMessage).GrantResults;
    if Assigned(FonRequestPermissionsResult) then
      FonRequestPermissionsResult(TAndroidPermission(LRequestCode), LPermissions, LGrantResults);
  end;
end;

procedure TAndroidPermissions.requestPermissions(AAndroidPermission: TAndroidPermission);
var
  JavaObjectArray: TJavaObjectArray<JString>;
begin
  JavaObjectArray := TJavaObjectArray<JString>.Create(1);
  JavaObjectArray.Items[0] := StringToJString(AndroidPermissionToStr(AAndroidPermission));
  MainActivity.requestPermissions(JavaObjectArray, Integer(AAndroidPermission));
end;

procedure TAndroidPermissions.SetonRequestPermissionsResult(const Value: TRequestPermissionsResultEvent);
begin
  FonRequestPermissionsResult := Value;
end;

function TAndroidPermissions.shouldShowRequestPermissionRationale(AAndroidPermission: TAndroidPermission): Boolean;
begin
  Result := MainActivity.shouldShowRequestPermissionRationale(StringToJString(AndroidPermissionToStr(AAndroidPermission)))
end;

initialization

AndroidPermissions := TAndroidPermissions.Create;

finalization

AndroidPermissions.Free;

end.
