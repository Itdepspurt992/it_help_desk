#define MyAppName "IT Help Desk"
#define MyAppVersion "6.0.0"
#define MyAppPublisher "IT Help Desk"
#define MyAppExeName "IT_Help_Desk.exe"

[Setup]
AppId={{A6A4A1C4-4C74-4E40-BB89-123456789006}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\IT Help Desk
DefaultGroupName=IT Help Desk
DisableProgramGroupPage=yes
OutputDir=output
OutputBaseFilename=IT_Help_Desk_Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=icon.ico

[Files]
Source: "..\dist\IT_Help_Desk\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Dirs]
Name: "{app}\database"
Name: "{app}\backups"
Name: "{app}\uploads"

[Icons]
Name: "{autodesktop}\IT Help Desk"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{group}\IT Help Desk"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{group}\إلغاء تثبيت IT Help Desk"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "تشغيل IT Help Desk الآن"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\uploads"
Type: filesandordirs; Name: "{app}\backups"
