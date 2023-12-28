; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "ICORRECT PC"
#define MyAppVersion "1.5"
#define MyAppPublisher "My Company, Inc."
#define MyAppURL "https://www.example.com/"
#define MyAppExeName "icorrect_pc.exe"
#define MyAppAssocName MyAppName + " File"
#define MyAppAssocExt ".myp"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{4D84B7EA-3F27-471E-A85E-90B60EBCB747}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
ChangesAssociations=yes
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\installs
OutputBaseFilename=icorrect_pc
SetupIconFile=C:\Users\Van Luan Nguyen\Downloads\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\audioplayers_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\camera_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\chrome_100_percent.pak"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\chrome_200_percent.pak"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\chrome_elf.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\connectivity_plus_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\d3dcompiler_47.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\file_selector_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\flutter_desktop_audio_recorder_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\icudtl.dat"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\libcef.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\libEGL.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\libGLESv2.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\permission_handler_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\record_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\resources.pak"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\screen_retriever_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\v8_context_snapshot.bin"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\video_player_win_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\vk_swiftshader.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\vk_swiftshader_icd.json"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\vulkan-1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\webview_cef_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "D:\My WorkSpace - Projects\Flutter Project\icorrect_pc\build\windows\runner\Release\fmedia\*"; DestDir: "{app}\fmedia"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Registry]
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".myp"; ValueData: ""

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

