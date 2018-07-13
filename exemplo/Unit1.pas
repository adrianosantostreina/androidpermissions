unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls,

  FMX.Permissions.Android,
  Androidapi.JNIBridge,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.GraphicsContentViewText;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure RequestPermissionReadContacts;
    procedure PermissionCallback(
      AAndroidPermission: TAndroidPermission;
      APermissions: TJavaObjectArray<JString>;
      AGrantResults: TJavaArray<Integer>
    );
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  RequestPermissionReadContacts;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  AndroidPermissions.onRequestPermissionsResult := PermissionCallback;
end;

procedure TForm1.PermissionCallback(AAndroidPermission: TAndroidPermission; APermissions:
  TJavaObjectArray<JString>; AGrantResults: TJavaArray<Integer>);
begin
  case AAndroidPermission of
    apREAD_CONTACTS:
    begin
      if (AGrantResults.Length > 0 ) and (AGrantResults[0]=
        TJPackageManager.JavaClass.PERMISSION_GRANTED) then
      begin

      end
      else
      begin

      end;
    end;
  end;
end;

procedure TForm1.RequestPermissionReadContacts;
begin
  if (AndroidPermissions.checkSelfPermission(apREAD_CONTACTS)<>
     TJPackageManager.JavaClass.PERMISSION_GRANTED ) then
  begin
    if (AndroidPermissions.shouldShowRequestPermissionRationale(apREAD_CONTACTS)) then
    begin

    end
    else
    begin
      AndroidPermissions.requestPermissions(apREAD_CONTACTS);
    end;
  end;
end;

end.
