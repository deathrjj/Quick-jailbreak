#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

IfNotExist,Files/Impactor/Impactor.exe
{
	Gui Add, Text, x8 y19 w422 h18 +0x200, Downloading Latest Cydia Impactor from  https://cydia.saurik.com/api/latest/2
	Gui Show, w500 h45, Downloading
	UrlDownloadToFile, https://cydia.saurik.com/api/latest/2, Files/Impactor.zip

	Zip := A_ScriptDir . "\Files\Impactor.zip"
	Unz := A_ScriptDir . "\Files\Impactor\"

	fso := ComObjCreate("Scripting.FileSystemObject")
	If Not fso.FolderExists(Unz)
	   fso.CreateFolder(Unz)
	psh  := ComObjCreate("Shell.Application")
	zippedItems := psh.Namespace( Zip ).items().count
	psh.Namespace( Unz ).CopyHere( psh.Namespace( Zip ).items, 4|16 )
	Loop {
		sleep 100
		unzippedItems := psh.Namespace( Unz ).items().count
		IfEqual,zippedItems,%unzippedItems%
			break
			}
	FileDelete, Files/Impactor.zip
	
	Gui, Destroy
}
	
	
IfNotExist, Files/yalu102_beta7.ipa
{
	Gui Add, Text,, There is currently a glitch and this script cannot download Yalu 
	Gui, Add, Text, cBlue gYalu,https://yalu.qwertyoruiop.com/yalu102_beta7.ipa
	Gui Add, Text,, Click the link and download the ipa file.
	Gui Add, Text,, Then move it into the Files directory
	Gui Show, w444 h150, Missing Yalu
	
	Sleep 1000000
	ExitApp
}

IfNotExist, Files/Login.txt
{
	Gui, Add, Text,,Enter AppleID
	Gui, Add, Edit,vID,
	Gui, Add, Text,,Enter Password
	Gui, Add, Edit,Password vPassword
	Gui, Add, Button,x25 y100 w150 gSaveDetails, OK
	Gui,Show,w200 h150 Center,Enter Details
	Return									
	
	
SaveDetails:
	Gui, Submit
	Gui, Destroy
	Login_File = %ID%:%Password%
	FileAppend, %Login_File%,Files/Login.txt
	gosub InstallIPA
	Return
	
}

InstallIPA:
	FileRead, Login_File, Files/Login.txt
	Login:=StrSplit(Login_File,":")
					
	Run Files/Impactor/Impactor.exe
		

	SetWorkingDir, Files

	Sleep 3000 

	Send {ALT}
	Send {D}
	Send {I}

	Sleep 1000

	Send {TAB}
	Send {TAB}
	Send {TAB}
	Send {TAB}
	Send {TAB}
	Send {TAB}
	Send {TAB}
	Send {TAB}
	Send {TAB}

	Send {Down}
	Send {Down}
	Send {Enter}

	Sleep 500

	Send % Login[1]
	Send {Enter}
	Sleep 500
	Send % Login[2]
	Send {Enter}

	Sleep 2000
	ExitApp
	
Yalu:
	Run https://yalu.qwertyoruiop.com/yalu102_beta7.ipa
	Return
	
	
_download_to_file(u,s){
	static r:=false,request:=comobjcreate("WinHttp.WinHttpRequest.5.1")
	if(!r||request.option(1)!=u)
		request.open("GET",u)
    ;request.SetProxy(2, "XXX.XXX.XXX.XXX:PORT") ; IF YOU NEED TO SET YOUR PROXY
	request.send()
	if(request.responsetext="failed"||request.status!=200||comobjtype(request.responsestream)!=0xd)
		return false
	p:=comobjquery(request.responsestream,"{0000000c-0000-0000-C000-000000000046}")
	f:=fileopen(s,"w")
	loop{
		varsetcapacity(b,8192)
		r:=dllcall(numget(numget(p+0)+3*a_ptrsize),ptr,p,ptr,&b,uint,8192, "ptr*",c)
		f.rawwrite(&b,c)
	}until (c=0)
	objrelease(p)
	f.close()
	return request.responsetext
}