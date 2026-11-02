
#define MyAppName "Biggie"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "Room06Tech"
#define MyAppExeName "biggie.exe"

[Setup]
AppId={{5A1ECCA9-4C49-45FA-A5B2-9D21408E1AB7}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\Room06Tech\Biggie
DefaultGroupName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=windows\runner\resources\app_icon.ico
OutputDir=dist
OutputBaseFilename=Biggie-Setup-0.1.0
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Biggie"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\Biggie"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Biggie"; Flags: postinstall nowait skipifsilent
