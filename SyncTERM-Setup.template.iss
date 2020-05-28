; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "SyncTERM"
#define MyAppVerName "SyncTERM #{VERSION}#"
#define MyAppSetupName "SyncTERM-#{VERSION}#-Setup"
#define MyAppPublisher "SyncTERM.Net"
#define MyAppURL "http://syncterm.net/"
#define MyAppURLName "syncterm-website.url"
#define MyAppExeName "syncterm.exe"


[Setup]
AppName={#MyAppName}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=..\output
OutputBaseFilename={#MyAppSetupName}
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Tasks]
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
Name: telnethandler; Description: Make Default Telnet Handler (recommended); Languages: ; GroupDescription: Protocol Handlers:
Name: rloginhandler; Description: Make Default RLogin Handler (recommended); GroupDescription: Protocol Handlers:
Name: sshhandler; Description: Make Default SSH Handler; GroupDescription: Protocol Handlers:

[Files]
Source: syncterm\syncterm.exe; DestDir: {app}; Flags: ignoreversion
Source: syncterm\SDL2.dll; DestDir: {app}; Flags: ignoreversion
Source: syncterm\fonts\*; DestDir: {app}\fonts\; Flags: ignoreversion recursesubdirs createallsubdirs
Source: synchronet\syncterm.lst; DestDir: {userappdata}\SyncTERM\; Flags: confirmoverwrite comparetimestamp uninsneveruninstall

[INI]
Filename: {app}\{#MyAppUrlName}; Section: InternetShortcut; Key: URL; String: {#MyAppURL}; Tasks: ; Languages: 

[Icons]
Name: {group}\{#MyAppName}; Filename: {app}\{#MyAppExeName}
Name: {userdesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: desktopicon

;Website Shortcuts
Name: {group}\{cm:ProgramOnTheWeb,{#MyAppName}}; Filename: {app}\{#MyAppUrlName}; IconFilename: {app}\syncterm.exe; IconIndex: 0

[UninstallDelete]
Type: files; Name: {app}\{#MyAppUrlName}

[Code]
//set telnet handler to syncterm
procedure TelnetSet();
var
	OriginalTelnetHandler: String;
begin

	//check for telnet
	if WizardIsTaskSelected('telnethandler') then
	begin

		if not RegValueExists(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'telnet') then
		begin
			//save original telnet handler
			if RegQueryStringValue(HKEY_CLASSES_ROOT, 'telnet\shell\open\command', '', OriginalTelnetHandler) then
			begin
				RegWriteStringValue(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'telnet', OriginalTelnetHandler);
			end
			else
			begin
				//set to win32 default
				RegWriteStringValue(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'telnet', 'rundll32.exe url.dll,TelnetProtocolHandler %l');
			end;
		end;

		//set telnet handler
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'telnet', 'URL:Custom Protocol', '');
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'telnet', 'URL Protocol', '');
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'telnet\DefaultIcon', 'URL Protocol', ExpandConstant('{app}\syncterm.exe,0'));
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'telnet\shell\open\command', '', ExpandConstant('"{app}\syncterm.exe" %1'));
	end;

end;

//restore telnet handler
procedure TelnetRestore();
var
	OriginalTelnetHandler: String;
begin

	//check for telnet
	if RegQueryStringValue(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'telnet', OriginalTelnetHandler) then
	begin
		//restore telnet handler
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'telnet\shell\open\command', '', OriginalTelnetHandler);
	end

end;


//set rlogin handler to syncterm
procedure RloginSet();
var
	OriginalRloginHandler: String;
begin

	//check for rlogin
	if WizardIsTaskSelected('rloginhandler') then
	begin

		if not RegValueExists(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'rlogin') then
		begin
			//save original rlogin handler
			if RegQueryStringValue(HKEY_CLASSES_ROOT, 'rlogin\shell\open\command', '', OriginalRloginHandler) then
			begin
				//set to current value
				RegWriteStringValue(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'rlogin', OriginalRloginHandler);
			end
			else
			begin
				//set to win32 default
				RegWriteStringValue(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'rlogin', 'rundll32.exe url.dll,TelnetProtocolHandler %l');
			end;
		end;

		//set rlogin handler
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'rlogin', 'URL:Custom Protocol', '');
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'rlogin', 'URL Protocol', '');
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'rlogin\DefaultIcon', 'URL Protocol', ExpandConstant('{app}\syncterm.exe,0'));
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'rlogin\shell\open\command', '', ExpandConstant('"{app}\syncterm.exe" %1'));
	end;

end;

//restore rlogin handler
procedure RloginRestore();
var
	OriginalRloginHandler: String;
begin

	if RegQueryStringValue(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'rlogin', OriginalRloginHandler) then
	begin
		//restore rlogin handler
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'rlogin\shell\open\command', '', OriginalRloginHandler);
	end;

end;


// ****** SSH *****************************************************
//set rlogin handler to syncterm
procedure SshSet();
var
	OriginalSshHandler: String;
begin

	//check for rlogin
	if WizardIsTaskSelected('sshhandler') then
	begin
		if not RegValueExists(HKEY_CLASSES_ROOT, 'ssh', '') then
		begin
			RegWriteStringValue(HKEY_CLASSES_ROOT, 'ssh', '', 'URL:SSH Protocol');
			RegWriteDWordValue(HKEY_CLASSES_ROOT, 'ssh', 'EditFlags', 2);
			RegWriteStringValue(HKEY_CLASSES_ROOT, 'ssh', 'FriendlyTypeName', 'ieframe.dll,-907');
			RegWriteStringValue(HKEY_CLASSES_ROOT, 'ssh', 'URL Protocol', '');
		end;

		if not RegValueExists(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'ssh') then
		begin
			//save original rlogin handler
			if RegQueryStringValue(HKEY_CLASSES_ROOT, 'rlogin\shell\open\command', '', OriginalSshHandler) then
			begin
				//set to current value
				RegWriteStringValue(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'ssh', OriginalSshHandler);
			end
			else
			begin
				//set to win32 default
				RegWriteStringValue(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'ssh', 'rundll32.exe url.dll,TelnetProtocolHandler %l');
			end
		end;

		//set ssh handler
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'ssh', 'URL:Custom Protocol', '');
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'ssh', 'URL Protocol', '');
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'ssh\DefaultIcon', 'URL Protocol', ExpandConstant('{app}\syncterm.exe,0'));
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'ssh\shell\open\command', '', ExpandConstant('"{app}\syncterm.exe" -h %1'));
	end

end;

//restore ssh handler
procedure SshRestore();
var
	OriginalSshHandler: String;
begin

	if RegQueryStringValue(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm\install', 'ssh', OriginalSshHandler) then
	begin
		//restore rlogin handler
		RegWriteStringValue(HKEY_CLASSES_ROOT, 'ssh\shell\open\command', '', OriginalSshHandler);
	end

end;
// ****** SSH *****************************************************



//fix NT Colors
procedure FixColors();
begin

	if (UsingWinNT() = true) then
	begin
		if WizardIsTaskSelected('ntcolorfix') then
		begin
			//Ansi colors for current user
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ScreenColors', 7);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'PopupColors', 31);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable00', 0);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable01', 11010048);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable02', 43008);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable03', 11053056);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable04', 168);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable05', 11010216);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable06', 21672);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable07', 11053224);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable08', 5526612);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable09', 16536660);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable10', 5569620);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable11', 16579668);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable12', 5526780);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable13', 16536828);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable14', 5569788);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ColorTable15', 16579836);
		end

	end

end;
// ****** NT Colors *****************************************************


//run during install process
procedure CurStepChanged(CurStep: TSetupStep);
begin

	if (CurStep = ssPostInstall) then
	begin

		RegWriteDWordValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_TELNET_PROTOCOL', 'iexplore.exe', 0);
		TelnetSet();
		RLoginSet();
		SshSet();

	end

end;

//run during uninstall process
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin

	if (CurUninstallStep = usPostUninstall) then
	begin

		//check for telnet
		TelnetRestore()

		//check for rlogin
		RloginRestore()

		//check for ssh
		SshRestore()

		//delete key for future
		RegDeleteKeyIncludingSubkeys(HKEY_CURRENT_USER, 'SOFTWARE\bbsdev.net\syncterm');

	end

end;


