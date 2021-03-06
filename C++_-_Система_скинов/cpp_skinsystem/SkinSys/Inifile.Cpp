///////////////////////////////////////////////////////////////
//
// Dosya Ad�: Inifile.cpp
// Yazan    : C�neyt EL�BOL
// A��klama : *.Ini Dosyalar� i�in Arabirim
// 
// Detayl� Bilgi i�in 
//       
//    www.celibol.freeservers.com  adresini ziyaret edin
//            veya
//    celibol@hotmail.com adresine mesaj at�n.
//
// Dikkat:
//    Bu program kodlar�n� kullan�rken Aciklama.txt dosyas�ndaki
//  gerekleri yerine getirmeniz gerekir.
//
///////////////////////////////////////////////////////////////

#include <Afx.h>
#include <AfxColl.h>

#include "IniFile.H"

CIniFile::CIniFile(CString m_FName)
{
	m_Name = m_FName;
}

CString CIniFile::ReadString(CString m_Sec, CString m_Ident, CString m_Def)
{
	char Buffer[2048];

	GetPrivateProfileString(m_Sec, m_Ident,m_Def, Buffer, sizeof(Buffer), m_Name);
	return Buffer;
}

BOOL CIniFile::WriteString(CString m_Sec, CString m_Ident, CString m_Val)
{
	return WritePrivateProfileString(m_Sec, m_Ident, m_Val, m_Name);
}

BOOL CIniFile::ReadSections(CStringArray& m_Secs)
{
	LPVOID pvData = NULL;
	HGLOBAL hGlobal = GlobalAlloc(GMEM_MOVEABLE, 16385);
	_ASSERTE(NULL != hGlobal);

	pvData = GlobalLock(hGlobal);
	_ASSERTE(NULL != pvData);

	m_Secs.RemoveAll();
	
	if (GetPrivateProfileString(NULL, NULL, NULL, (char*) pvData, 16384, m_Name))
	{
        char *P = (char*) pvData;
        while (*P != 0)
		{
			m_Secs.Add(P);
			P += strlen(P) + 1;
		}
	}
	GlobalUnlock(hGlobal);
	GlobalFree(hGlobal);
	return m_Secs.GetSize() > 0;
}

BOOL CIniFile::ReadSection(CString m_Sec, CStringArray& m_Secs)
{
	LPVOID pvData = NULL;
	HGLOBAL hGlobal = GlobalAlloc(GMEM_MOVEABLE, 16385);
	_ASSERTE(NULL != hGlobal);

	pvData = GlobalLock(hGlobal);
	_ASSERTE(NULL != pvData);

	m_Secs.RemoveAll();
	
	if (GetPrivateProfileString(m_Sec, NULL, NULL, (char*) pvData, 16384, m_Name))
	{
        char *P = (char*) pvData;
        while (*P != 0)
		{
			m_Secs.Add(P);
			P += strlen(P) + 1;
		}
	}
	GlobalUnlock(hGlobal);
	GlobalFree(hGlobal);
	return m_Secs.GetSize() > 0;
}
