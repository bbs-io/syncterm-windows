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
OutputDir=output
OutputBaseFilename={#MyAppSetupName}
Compression=lzma
SolidCompression=yes

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Tasks]
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
Name: quicklaunchicon; Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
Name: telnethandler; Description: Make Default Telnet Handler (recommended); Languages: ; GroupDescription: Protocol Handlers:
Name: rloginhandler; Description: Make Default RLogin Handler (recommended); GroupDescription: Protocol Handlers:
Name: sshhandler; Description: Make Default SSH Handler; GroupDescription: Protocol Handlers:
Name: fixie7telnet; Description: Fix IE7 Telnet (recommended); GroupDescription: Other:; MinVersion: 99,5.01.2600sp2; Check: HasIE7
Name: ntcolorfix; Description: Fix DOS Colors; GroupDescription: Other:; MinVersion: 99,1

[Files]
Source: input\syncterm.exe; DestDir: {app}; Flags: ignoreversion
Source: input\SDL.dll; DestDir: {app}; Flags: ignoreversion
Source: input\fonts\*; DestDir: {app}\fonts\; Flags: ignoreversion recursesubdirs createallsubdirs
Source: input\syncterm.lst; DestDir: {userappdata}\SyncTERM\; Flags: confirmoverwrite comparetimestamp uninsneveruninstall
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[INI]
Filename: {app}\{#MyAppUrlName}; Section: InternetShortcut; Key: URL; String: {#MyAppURL}; Tasks: ; Languages: 

[Icons]
Name: {group}\{#MyAppName}; Filename: {app}\{#MyAppExeName}
Name: {userdesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: desktopicon
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: quicklaunchicon

;Website Shortcuts
Name: {group}\{cm:ProgramOnTheWeb,{#MyAppName}}; Filename: {app}\{#MyAppUrlName}; IconFilename: {app}\syncterm.exe; IconIndex: 0

[UninstallDelete]
Type: files; Name: {app}\{#MyAppUrlName}

[Code]
//Is IE7 Installed?
function HasIE7():Boolean;
var
	Response:Boolean;
	Build:String;
begin
	Response := False;

	if RegValueExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Internet Explorer', 'Build') then
	begin
		//get build version
		RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Internet Explorer', 'Build', Build)

		//nuke the fraction portion of the build.. :)
		if Pos('.', Build) > 0 then
			SetLength(Build, Pos('.', Build) - 1);

		//test against IE7 release
		if (StrToInt(Build) >= 70000) then
			Response := True;
	end;

	Result  := Response
end;

//fix ie7 telnet handler to allow telnet
procedure IE7Telnet();
begin
	//fixie7telnet
	if IsTaskSelected('fixie7telnet') then
	begin
		// HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_TELNET_PROTOCOL
		// "iexplore.exe"=dword:00000000
		RegWriteDWordValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_TELNET_PROTOCOL', 'iexplore.exe', 0);
	end
end;

//set telnet handler to syncterm
procedure TelnetSet();
var
	OriginalTelnetHandler: String;
begin

	//check for telnet
	if IsTaskSelected('telnethandler') then
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
	if IsTaskSelected('rloginhandler') then
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
	if IsTaskSelected('sshhandler') then
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
		if IsTaskSelected('ntcolorfix') then
		begin
			//Ansi colors for current user
			RegWriteStringValue(HKEY_CURRENT_USER, 'Console', 'FaceName', 'Terminal');
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
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'InsertMode', 1);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'QuickEdit', 2048);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'FullScreen', 0);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'ScreenBufferSize', 1638480);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'WindowSize', 1638480);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'FontSize', 786440);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'FontFamily', 48);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'FontWeight', 400);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'CursorSize', 100);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'HistoryBufferSize', 50);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'NumberOfHistoryBuffers', 4);
			RegWriteDWordValue(HKEY_CURRENT_USER, 'Console', 'HistoryNoDup', 0);

			//Ansi colors for default user
			RegWriteStringValue(HKEY_USERS, '.DEFAULT\Console', 'FaceName', 'Terminal');
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ScreenColors', 7);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'PopupColors', 31);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable00', 0);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable01', 11010048);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable02', 43008);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable03', 11053056);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable04', 168);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable05', 11010216);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable06', 21672);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable07', 11053224);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable08', 5526612);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable09', 16536660);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable10', 5569620);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable11', 16579668);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable12', 5526780);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable13', 16536828);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable14', 5569788);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ColorTable15', 16579836);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'InsertMode', 1);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'QuickEdit', 2048);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'FullScreen', 0);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'ScreenBufferSize', 1638480);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'WindowSize', 1638480);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'FontSize', 786440);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'FontFamily', 48);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'FontWeight', 400);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'CursorSize', 100);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'HistoryBufferSize', 50);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'NumberOfHistoryBuffers', 4);
			RegWriteDWordValue(HKEY_USERS, '.DEFAULT\Console', 'HistoryNoDup', 0);


		end

	end

end;
// ****** NT Colors *****************************************************


//run during install process
procedure CurStepChanged(CurStep: TSetupStep);
begin

	if (CurStep = ssPostInstall) then
	begin

		IE7Telnet();
		TelnetSet();
		RLoginSet();
		SshSet();
		FixColors();

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

