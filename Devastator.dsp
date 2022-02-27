# Microsoft Developer Studio Project File - Name="Devastator" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=Devastator - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Devastator.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Devastator.mak" CFG="Devastator - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Devastator - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE "Devastator - Win32 Debug" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Devastator", ARDAAAAA"
# PROP Scc_LocalPath "."

!IF  "$(CFG)" == "Devastator - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Cmd_Line "NMAKE /f Devastator.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "Devastator.exe"
# PROP BASE Bsc_Name "Devastator.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Cmd_Line "nmake /f "Devastator.mak""
# PROP Rebuild_Opt "/a"
# PROP Target_File "Devastator.exe"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "$(CFG)" == "Devastator - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Cmd_Line "NMAKE /f Devastator.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "Devastator.exe"
# PROP BASE Bsc_Name "Devastator.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Cmd_Line "nmake /f "Devastator.mak""
# PROP Rebuild_Opt "/a"
# PROP Target_File "Devastator.exe"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ENDIF 

# Begin Target

# Name "Devastator - Win32 Release"
# Name "Devastator - Win32 Debug"

!IF  "$(CFG)" == "Devastator - Win32 Release"

!ELSEIF  "$(CFG)" == "Devastator - Win32 Debug"

!ENDIF 

# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\mou_dsp.s
# End Source File
# Begin Source File

SOURCE=.\mou_gpu.s
# End Source File
# Begin Source File

SOURCE=.\MOU_INIT.S
# End Source File
# Begin Source File

SOURCE=.\MOU_LIST.S
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\JAGUAR.H
# End Source File
# Begin Source File

SOURCE=.\MOU.INC
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\font12.cry
# End Source File
# Begin Source File

SOURCE=.\font12x16.tga
# End Source File
# Begin Source File

SOURCE=.\KRYSPRON.s
# End Source File
# Begin Source File

SOURCE=.\MAKEFILE
# End Source File
# Begin Source File

SOURCE=.\palette.inc
# End Source File
# Begin Source File

SOURCE=.\readme.txt
# End Source File
# Begin Source File

SOURCE=.\Technical.txt
# End Source File
# End Group
# Begin Group "d_star"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\d_star\base.cry
# End Source File
# Begin Source File

SOURCE=.\d_star\starbase.tga
# End Source File
# End Group
# Begin Group "earth"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\earth\earth.cry
# End Source File
# Begin Source File

SOURCE=.\earth\earth.tga
# End Source File
# End Group
# Begin Group "ships"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\ships\enemyshot.tga
# End Source File
# Begin Source File

SOURCE=.\ships\ship.cry
# End Source File
# Begin Source File

SOURCE=.\ships\ship.tga
# End Source File
# Begin Source File

SOURCE=.\ships\shots.cry
# End Source File
# End Group
# End Target
# End Project
