
#define MyAppName "MuxTune Player"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "Room06Tech"
#define MyAppExeName "MuxTune Player.exe"
#define MyAppId "{{B87C91A2-5E61-4D21-9A30-7B4C3D8E21F0}"

[Setup]
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\Room06Tech\MuxTune Player
DefaultGroupName=MuxTune Player

UninstallDisplayName=MuxTune Player
UninstallDisplayIcon={app}\{#MyAppExeName}

SetupIconFile=windows\runner\resources\app_icon.ico

OutputDir=dist
OutputBaseFilename=MuxTunePlayer-Setup-{#MyAppVersion}

Compression=lzma2
SolidCompression=yes
WizardStyle=modern

ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin

DisableProgramGroupPage=yes

[Tasks]
Name: "desktopicon"; \
    Description: "Create a desktop shortcut"; \
    GroupDescription: "Additional shortcuts:"; \
    Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; \
    DestDir: "{app}"; \
    Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\MuxTune Player"; \
    Filename: "{app}\{#MyAppExeName}"

Name: "{autodesktop}\MuxTune Player"; \
    Filename: "{app}\{#MyAppExeName}"; \
    Tasks: desktopicon

[Registry]

; Application capabilities

Root: HKCU; \
    Subkey: "Software\Room06Tech\MuxTune Player\Capabilities"; \
    ValueType: string; \
    ValueName: "ApplicationName"; \
    ValueData: "MuxTune Player"; \
    Flags: uninsdeletekey

Root: HKCU; \
    Subkey: "Software\Room06Tech\MuxTune Player\Capabilities"; \
    ValueType: string; \
    ValueName: "ApplicationDescription"; \
    ValueData: "MuxTune Player - Desktop Music Player"

; Register application with Windows

Root: HKCU; \
    Subkey: "Software\RegisteredApplications"; \
    ValueType: string; \
    ValueName: "MuxTune Player"; \
    ValueData: "Software\Room06Tech\MuxTune Player\Capabilities"; \
    Flags: uninsdeletevalue

; MP3 association

Root: HKCU; \
    Subkey: "Software\Room06Tech\MuxTune Player\Capabilities\FileAssociations"; \
    ValueType: string; ValueName: ".mp3"; \
    ValueData: "MuxTunePlayer.mp3"

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.mp3"; \
    ValueType: string; ValueName: ""; \
    ValueData: "MuxTune Player MP3 File"; \
    Flags: uninsdeletekey

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.mp3\DefaultIcon"; \
    ValueType: string; ValueName: ""; \
    ValueData: "{app}\{#MyAppExeName},0"

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.mp3\shell\open\command"; \
    ValueType: string; ValueName: ""; \
    ValueData: """{app}\{#MyAppExeName}"" ""%1"""

; WAV association

Root: HKCU; \
    Subkey: "Software\Room06Tech\MuxTune Player\Capabilities\FileAssociations"; \
    ValueType: string; ValueName: ".wav"; \
    ValueData: "MuxTunePlayer.wav"

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.wav"; \
    ValueType: string; ValueName: ""; \
    ValueData: "MuxTune Player WAV File"; \
    Flags: uninsdeletekey

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.wav\DefaultIcon"; \
    ValueType: string; ValueName: ""; \
    ValueData: "{app}\{#MyAppExeName},0"

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.wav\shell\open\command"; \
    ValueType: string; ValueName: ""; \
    ValueData: """{app}\{#MyAppExeName}"" ""%1"""

; FLAC association

Root: HKCU; \
    Subkey: "Software\Room06Tech\MuxTune Player\Capabilities\FileAssociations"; \
    ValueType: string; ValueName: ".flac"; \
    ValueData: "MuxTunePlayer.flac"

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.flac"; \
    ValueType: string; ValueName: ""; \
    ValueData: "MuxTune Player FLAC File"; \
    Flags: uninsdeletekey

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.flac\DefaultIcon"; \
    ValueType: string; ValueName: ""; \
    ValueData: "{app}\{#MyAppExeName},0"

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.flac\shell\open\command"; \
    ValueType: string; ValueName: ""; \
    ValueData: """{app}\{#MyAppExeName}"" ""%1"""

; M4A association

Root: HKCU; \
    Subkey: "Software\Room06Tech\MuxTune Player\Capabilities\FileAssociations"; \
    ValueType: string; ValueName: ".m4a"; \
    ValueData: "MuxTunePlayer.m4a"

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.m4a"; \
    ValueType: string; ValueName: ""; \
    ValueData: "MuxTune Player M4A File"; \
    Flags: uninsdeletekey

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.m4a\shell\open\command"; \
    ValueType: string; ValueName: ""; \
    ValueData: """{app}\{#MyAppExeName}"" ""%1"""

; AAC association

Root: HKCU; \
    Subkey: "Software\Room06Tech\MuxTune Player\Capabilities\FileAssociations"; \
    ValueType: string; ValueName: ".aac"; \
    ValueData: "MuxTunePlayer.aac"

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.aac"; \
    ValueType: string; ValueName: ""; \
    ValueData: "MuxTune Player AAC File"; \
    Flags: uninsdeletekey

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.aac\shell\open\command"; \
    ValueType: string; ValueName: ""; \
    ValueData: """{app}\{#MyAppExeName}"" ""%1"""

; OGG association

Root: HKCU; \
    Subkey: "Software\Room06Tech\MuxTune Player\Capabilities\FileAssociations"; \
    ValueType: string; ValueName: ".ogg"; \
    ValueData: "MuxTunePlayer.ogg"

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.ogg"; \
    ValueType: string; ValueName: ""; \
    ValueData: "MuxTune Player OGG File"; \
    Flags: uninsdeletekey

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.ogg\shell\open\command"; \
    ValueType: string; ValueName: ""; \
    ValueData: """{app}\{#MyAppExeName}"" ""%1"""

; OPUS association

Root: HKCU; \
    Subkey: "Software\Room06Tech\MuxTune Player\Capabilities\FileAssociations"; \
    ValueType: string; ValueName: ".opus"; \
    ValueData: "MuxTunePlayer.opus"

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.opus"; \
    ValueType: string; ValueName: ""; \
    ValueData: "MuxTune Player OPUS File"; \
    Flags: uninsdeletekey

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.opus\shell\open\command"; \
    ValueType: string; ValueName: ""; \
    ValueData: """{app}\{#MyAppExeName}"" ""%1"""

; WMA association

Root: HKCU; \
    Subkey: "Software\Room06Tech\MuxTune Player\Capabilities\FileAssociations"; \
    ValueType: string; ValueName: ".wma"; \
    ValueData: "MuxTunePlayer.wma"

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.wma"; \
    ValueType: string; ValueName: ""; \
    ValueData: "MuxTune Player WMA File"; \
    Flags: uninsdeletekey

Root: HKCU; \
    Subkey: "Software\Classes\MuxTunePlayer.wma\shell\open\command"; \
    ValueType: string; ValueName: ""; \
    ValueData: """{app}\{#MyAppExeName}"" ""%1"""

[Run]

; Launch application checkbox (checked by default)

Filename: "{app}\{#MyAppExeName}"; \
    Description: "Launch MuxTune Player"; \
    Flags: postinstall nowait skipifsilent

; Default audio player checkbox (unchecked by default)

Filename: "{win}\explorer.exe"; \
    Parameters: "ms-settings:defaultapps"; \
    Description: "Set MuxTune Player as default audio player"; \
    Flags: postinstall unchecked skipifsilent
