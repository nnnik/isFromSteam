﻿#include _Struct.ahk

f4::
WinGet, swPID, PID, A
Msgbox % isFromSteam( swPID )
Return

isFromSteam( dwPID )
{
	return isSteamChild( dwPID )
}
/* VAC unsafe
hasSteamDll(dwPID) ;Thanks to HotkeyIt ( I just stole and modified his function from: https://github.com/HotKeyIt/_Struct/blob/master/_Struct.Example.ahk )
{
	static TH32CS_SNAPMODULE:=0x00000008,INVALID_HANDLE_VALUE:=-1,hModuleSnap := new _Struct("HANDLE"), MAX_PATH:=260,MAX_MODULE_NAME32:=255,_MODULEENTRY32:="
        (Q
          DWORD   dwSize;
          DWORD   th32ModuleID;
          DWORD   th32ProcessID;
          DWORD   GlblcntUsage;
          DWORD   ProccntUsage;
          BYTE    *modBaseAddr;
          DWORD   modBaseSize;
          HMODULE hModule;
          TCHAR   szModule[" MAX_MODULE_NAME32 + 1 "];
          TCHAR   szExePath[" MAX_PATH "];
        )"
		
	me32 := new _Struct( _MODULEENTRY32 )
	me32.dwSize := sizeof( _MODULEENTRY32 )
	
	hModuleSnap := DllCall("CreateToolhelp32Snapshot","UInt", TH32CS_SNAPMODULE,"PTR", dwPID )
	if( hModuleSnap = INVALID_HANDLE_VALUE )
		return FALSE
	
	if( !DllCall("Module32First" (A_IsUnicode?"W":""),"PTR", hModuleSnap,"PTR", me32[""] ) )
	{
		DllCall("CloseHandle","PTR", hModuleSnap ) ;     // Must clean up the snapshot object!
		return  FALSE
	}

	Loop 
	{
		if  ( StrGet(me32.szModule[""]) = "Steam.dll" )
		{
			DllCall("CloseHandle","PTR",hModuleSnap)
			return 1
		}
	}Until !DllCall("Module32Next" (A_IsUnicode?"W":""),"PTR",hModuleSnap,"PTR", me32[""] ) 
	
	DllCall("CloseHandle","PTR",hModuleSnap)
	return 0
}*/

isSteamChild( dwPID )
{
	Process,Exist,Steam.exe
	steamPID := ErrorLevel
	if !steamPID
		return 0
	else
		return steamPID = getParentPID( dwPID )
}

getParentPID( dwPID ) ;Thanks to HotkeyIt ( I just stole and modified his function from: https://github.com/HotKeyIt/_Struct/blob/master/_Struct.Example.ahk )
{
	static TH32CS_SNAPPROCESS:=0x00000002,INVALID_HANDLE_VALUE:=-1,hModuleSnap := new _Struct("HANDLE"), MAX_PATH:=260,_PROCESSENTRY32:="
        (Q
			DWORD     dwSize;
			DWORD     cntUsage;
			DWORD     th32ProcessID;
			ULONG_PTR th32DefaultHeapID;
			DWORD     th32ModuleID;
			DWORD     cntThreads;
			DWORD     th32ParentProcessID;
			LONG      pcPriClassBase;
			DWORD     dwFlags;
			TCHAR     szExeFile[" MAX_PATH "];
        )"
		
	pe32 := new _Struct( _PROCESSENTRY32 )
	pe32.dwSize := sizeof( _PROCESSENTRY32 )
	
	hModuleSnap := DllCall("CreateToolhelp32Snapshot","UInt", TH32CS_SNAPPROCESS,"PTR", 0 )
	if( hModuleSnap = INVALID_HANDLE_VALUE )
		return FALSE
	
	if( !DllCall("Process32First" (A_IsUnicode?"W":""),"PTR", hModuleSnap,"PTR", pe32[""] ) )
	{
		DllCall("CloseHandle","PTR", hModuleSnap ) ;     // Must clean up the snapshot object!
		return  FALSE
	}
	
	Loop 
	{
		if  ( pe32.th32ProcessID = dwPID )
		{
			DllCall("CloseHandle","PTR",hModuleSnap)
			return pe32.th32ParentProcessID
		}
	}Until !DllCall("Process32Next" (A_IsUnicode?"W":""),"PTR",hModuleSnap,"PTR", pe32[""] )
	
	DllCall("CloseHandle","PTR",hModuleSnap)
	return 0
}