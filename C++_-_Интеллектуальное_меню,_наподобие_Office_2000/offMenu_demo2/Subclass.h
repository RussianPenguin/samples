////////////////////////////////////////////////////////////////
// PixieLib(TM) Copyright 1997-1998 Paul DiLascia
// If this code works, it was written by Paul DiLascia.
// If not, I don't know who wrote it.
//
#ifndef _SUBCLASSW_H
#define _SUBCLASSW_H

//////////////////
// The message hook map is derived from CMapPtrToPtr, which associates
// a pointer with another pointer. It maps an HWND to a CSubclassWnd, like
// the way MFC's internal maps map HWND's to CWnd's. The first CSubclassWnd
// attached to a window is stored in the map; all other CSubclassWnd's for that
// window are then chained via CSubclassWnd::m_pNext.
//

class CSubclassWnd;

class CSubclassWndMap : private CMapPtrToPtr {
public:
	CSubclassWndMap();
	~CSubclassWndMap();
	static CSubclassWndMap& GetHookMap();
	void Add(HWND hwnd, CSubclassWnd* pSubclassWnd);
	void Remove(CSubclassWnd* pSubclassWnd);
	void RemoveAll(HWND hwnd);
	CSubclassWnd* Lookup(HWND hwnd);
};

//////////////////
// Generic class to hook messages on behalf of a CWnd.
// Once hooked, all messages go to CSubclassWnd::WindowProc before going
// to the window. Specific subclasses can trap messages and do something.
//
// To use:
//
// * Derive a class from CSubclassWnd.
//
// * Override CSubclassWnd::WindowProc to handle messages. Make sure you call
//   CSubclassWnd::WindowProc if you don't handle the message, or your
//   window will never get messages. If you write seperate message handlers,
//   you can call Default() to pass the message to the window.
//
// * Instantiate your derived class somewhere and call HookWindow(pWnd)
//   to hook your window, AFTER it has been created.
//	  To unhook, call HookWindow(NULL).
//
// This is a very important class, crucial to many of the widgets Window
// widgets implemented in PixieLib. To see how it works, look at the HOOK
// sample program.
//

class /*AFX_EXT_CLASS*/ CSubclassWnd : public CObject {
public:
	CSubclassWndMap& GetHookMap();
	DECLARE_DYNAMIC(CSubclassWnd);
	CSubclassWnd();
	~CSubclassWnd();

	// Subclass a window. Hook(NULL) to unhook (automatic on WM_NCDESTROY)
	BOOL	HookWindow(HWND  hwnd);
	BOOL	HookWindow(CWnd* pWnd)	{ return HookWindow(pWnd->GetSafeHwnd()); }
	BOOL	IsHooked()					{ return m_hWnd!=NULL; }

	friend LRESULT CALLBACK HookWndProc(HWND, UINT, WPARAM, LPARAM);
	friend class CSubclassWndMap;

#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:
	HWND				m_hWnd;				// the window hooked
	WNDPROC			m_pOldWndProc;		// ..and original window proc
	CSubclassWnd*	m_pNext;				// next in chain of hooks for this window

	// Override this to handle messages in specific handlers
	virtual LRESULT WindowProc(UINT msg, WPARAM wp, LPARAM lp);
	LRESULT Default();				// call this at the end of handler fns
};

#endif // _SUBCLASSW_H

