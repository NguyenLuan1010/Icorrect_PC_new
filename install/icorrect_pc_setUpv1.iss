; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Icorrect PC "
#define MyAppVersion "1.0"
#define MyAppPublisher "CSUPPORTER "
#define MyAppURL "https://icorrect.vn/"
#define MyAppExeName "icorrect_pc.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{991D41BC-52D2-4B5F-B0A3-E7D8E4B45824}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=D:\My WorkSpace - Projects\icorrect_pc\install
OutputBaseFilename=icorrect_pc_v1
SetupIconFile=C:\Users\Van Luan Nguyen\Downloads\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\audioplayers_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\connectivity_plus_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\file_selector_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\flutter_desktop_audio_recorder_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\permission_handler_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\record_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\screen_retriever_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\video_player_win_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "D:\My WorkSpace - Projects\icorrect_pc\build\windows\runner\Release\fmedia\*"; DestDir: "{app}\fmedia"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
