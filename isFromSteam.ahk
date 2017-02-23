#include _Struct.ahk

f4::
WinGet, swPID, PID, A
Msgbox % hasSteamDll( swPID )
Return

hasSteamDll(PID) ;Thanks to HotkeyIt ( I just stole and modified his function from: https://github.com/HotKeyIt/_Struct/blob/master/_Struct.Example.ahk )
{
	static TH32CS_SNAPMODULE:=0x00000008,INVALID_HANDLE_VALUE:=-1
	global _Struct
	hModuleSnap := new _Struct("HANDLE")
	MAX_PATH:=260
	MAX_MODULE_NAME32:=255
	_MODULEENTRY32:="
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

	while(A_Index=1 || DllCall("Module32Next" (A_IsUnicode?"W":""),"PTR",hModuleSnap,"PTR", me32[""] ) )
	{
		if  (StrGet(me32.szModule[""]) = "Steam.dll" )
		{
			DllCall("CloseHandle","PTR",hModuleSnap)
			return 1
		}
	}
	DllCall("CloseHandle","PTR",hModuleSnap)
	return 0
}
