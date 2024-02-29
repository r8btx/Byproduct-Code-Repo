﻿<#
This script consists of two main parts:

1. Logging Received Window Messages:
    - This can be useful for identifying received messages.
      For instance, if you see `Received: WM_POWERBROADCAST, Msg = 536, WParam = 4, LParam = 0`,
      you can refer to https://learn.microsoft.com/en-us/windows/win32/power/wm-powerbroadcast
    - For unrecognized messages displayed as `Received: unknown, Msg = XXX, WParam = 0, LParam = 0`, check:
        - https://wiki.winehq.org/List_Of_Windows_Messages
        - https://web.archive.org/web/20230620212929/http://www.pinvoke.net/default.aspx/Constants/WM.html

2. Registering a Custom Action for a Specific Message:
    - Demonstrates how to associate the `WM_POWERBROADCAST` message (0x0218) with a `CustomFunction`.
    - Upon receiving the `WM_POWERBROADCAST` message, the script invokes `CustomFunction`, passing `WParam` and `LParam` as arguments.
#>

Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
using System.Collections.Generic;

public class MessageHandler : Form
{
    public delegate void CustomActionDelegate(long wParam, long lParam);
    private Dictionary<int, CustomActionDelegate> messageHandlers = new Dictionary<int, CustomActionDelegate>();

    // Window Messages:
    private static readonly Dictionary<int, string> KnownMessages = new Dictionary<int, string>
    {
        { 0x0000, "WM_NULL" },
        { 0x0001, "WM_CREATE" },
        { 0x0002, "WM_DESTROY" },
        { 0x0003, "WM_MOVE" },
        { 0x0005, "WM_SIZE" },
        { 0x0006, "WM_ACTIVATE" },
        { 0x0007, "WM_SETFOCUS" },
        { 0x0008, "WM_KILLFOCUS" },
        { 0x000a, "WM_ENABLE" },
        { 0x000b, "WM_SETREDRAW" },
        { 0x000c, "WM_SETTEXT" },
        { 0x000d, "WM_GETTEXT" },
        { 0x000e, "WM_GETTEXTLENGTH" },
        { 0x000f, "WM_PAINT" },
        { 0x0010, "WM_CLOSE" },
        { 0x0011, "WM_QUERYENDSESSION" },
        { 0x0012, "WM_QUIT" },
        { 0x0013, "WM_QUERYOPEN" },
        { 0x0014, "WM_ERASEBKGND" },
        { 0x0015, "WM_SYSCOLORCHANGE" },
        { 0x0016, "WM_ENDSESSION" },
        { 0x0018, "WM_SHOWWINDOW" },
        { 0x0019, "WM_CTLCOLOR" },
        { 0x001a, "WM_WININICHANGE" },
        { 0x001b, "WM_DEVMODECHANGE" },
        { 0x001c, "WM_ACTIVATEAPP" },
        { 0x001d, "WM_FONTCHANGE" },
        { 0x001e, "WM_TIMECHANGE" },
        { 0x001f, "WM_CANCELMODE" },
        { 0x0020, "WM_SETCURSOR" },
        { 0x0021, "WM_MOUSEACTIVATE" },
        { 0x0022, "WM_CHILDACTIVATE" },
        { 0x0023, "WM_QUEUESYNC" },
        { 0x0024, "WM_GETMINMAXINFO" },
        { 0x0026, "WM_PAINTICON" },
        { 0x0027, "WM_ICONERASEBKGND" },
        { 0x0028, "WM_NEXTDLGCTL" },
        { 0x002a, "WM_SPOOLERSTATUS" },
        { 0x002b, "WM_DRAWITEM" },
        { 0x002c, "WM_MEASUREITEM" },
        { 0x002d, "WM_DELETEITEM" },
        { 0x002e, "WM_VKEYTOITEM" },
        { 0x002f, "WM_CHARTOITEM" },
        { 0x0030, "WM_SETFONT" },
        { 0x0031, "WM_GETFONT" },
        { 0x0032, "WM_SETHOTKEY" },
        { 0x0033, "WM_GETHOTKEY" },
        { 0x0037, "WM_QUERYDRAGICON" },
        { 0x0039, "WM_COMPAREITEM" },
        { 0x003d, "WM_GETOBJECT" },
        { 0x0041, "WM_COMPACTING" },
        { 0x0044, "WM_COMMNOTIFY" },
        { 0x0046, "WM_WINDOWPOSCHANGING" },
        { 0x0047, "WM_WINDOWPOSCHANGED" },
        { 0x0048, "WM_POWER" },
        { 0x0049, "WM_COPYGLOBALDATA" },
        { 0x004a, "WM_COPYDATA" },
        { 0x004b, "WM_CANCELJOURNAL" },
        { 0x004e, "WM_NOTIFY" },
        { 0x0050, "WM_INPUTLANGCHANGEREQUEST" },
        { 0x0051, "WM_INPUTLANGCHANGE" },
        { 0x0052, "WM_TCARD" },
        { 0x0053, "WM_HELP" },
        { 0x0054, "WM_USERCHANGED" },
        { 0x0055, "WM_NOTIFYFORMAT" },
        { 0x007b, "WM_CONTEXTMENU" },
        { 0x007c, "WM_STYLECHANGING" },
        { 0x007d, "WM_STYLECHANGED" },
        { 0x007e, "WM_DISPLAYCHANGE" },
        { 0x007f, "WM_GETICON" },
        { 0x0080, "WM_SETICON" },
        { 0x0081, "WM_NCCREATE" },
        { 0x0082, "WM_NCDESTROY" },
        { 0x0083, "WM_NCCALCSIZE" },
        { 0x0084, "WM_NCHITTEST" },
        { 0x0085, "WM_NCPAINT" },
        { 0x0086, "WM_NCACTIVATE" },
        { 0x0087, "WM_GETDLGCODE" },
        { 0x0088, "WM_SYNCPAINT" },
        { 0x00a0, "WM_NCMOUSEMOVE" },
        { 0x00a1, "WM_NCLBUTTONDOWN" },
        { 0x00a2, "WM_NCLBUTTONUP" },
        { 0x00a3, "WM_NCLBUTTONDBLCLK" },
        { 0x00a4, "WM_NCRBUTTONDOWN" },
        { 0x00a5, "WM_NCRBUTTONUP" },
        { 0x00a6, "WM_NCRBUTTONDBLCLK" },
        { 0x00a7, "WM_NCMBUTTONDOWN" },
        { 0x00a8, "WM_NCMBUTTONUP" },
        { 0x00a9, "WM_NCMBUTTONDBLCLK" },
        { 0x00ab, "WM_NCXBUTTONDOWN" },
        { 0x00ac, "WM_NCXBUTTONUP" },
        { 0x00ad, "WM_NCXBUTTONDBLCLK" },
        { 0x00ff, "WM_INPUT" },
        { 0x0100, "WM_KEYDOWN / WM_KEYFIRST" },
        { 0x0101, "WM_KEYUP" },
        { 0x0102, "WM_CHAR" },
        { 0x0103, "WM_DEADCHAR" },
        { 0x0104, "WM_SYSKEYDOWN" },
        { 0x0105, "WM_SYSKEYUP" },
        { 0x0106, "WM_SYSCHAR" },
        { 0x0107, "WM_SYSDEADCHAR" },
        { 0x0109, "WM_UNICHAR / WM_WNT_CONVERTREQUESTEX" },
        { 0x010a, "WM_CONVERTREQUEST" },
        { 0x010b, "WM_CONVERTRESULT" },
        { 0x010c, "WM_INTERIM" },
        { 0x010d, "WM_IME_STARTCOMPOSITION" },
        { 0x010e, "WM_IME_ENDCOMPOSITION" },
        { 0x010f, "WM_IME_COMPOSITION / WM_IME_KEYLAST" },
        { 0x0110, "WM_INITDIALOG" },
        { 0x0111, "WM_COMMAND" },
        { 0x0112, "WM_SYSCOMMAND" },
        { 0x0113, "WM_TIMER" },
        { 0x0114, "WM_HSCROLL" },
        { 0x0115, "WM_VSCROLL" },
        { 0x0116, "WM_INITMENU" },
        { 0x0117, "WM_INITMENUPOPUP" },
        { 0x0118, "WM_SYSTIMER" },
        { 0x011f, "WM_MENUSELECT" },
        { 0x0120, "WM_MENUCHAR" },
        { 0x0121, "WM_ENTERIDLE" },
        { 0x0122, "WM_MENURBUTTONUP" },
        { 0x0123, "WM_MENUDRAG" },
        { 0x0124, "WM_MENUGETOBJECT" },
        { 0x0125, "WM_UNINITMENUPOPUP" },
        { 0x0126, "WM_MENUCOMMAND" },
        { 0x0127, "WM_CHANGEUISTATE" },
        { 0x0128, "WM_UPDATEUISTATE" },
        { 0x0129, "WM_QUERYUISTATE" },
        { 0x0131, "WM_LBTRACKPOINT" },
        { 0x0132, "WM_CTLCOLORMSGBOX" },
        { 0x0133, "WM_CTLCOLOREDIT" },
        { 0x0134, "WM_CTLCOLORLISTBOX" },
        { 0x0135, "WM_CTLCOLORBTN" },
        { 0x0136, "WM_CTLCOLORDLG" },
        { 0x0137, "WM_CTLCOLORSCROLLBAR" },
        { 0x0138, "WM_CTLCOLORSTATIC" },
        { 0x0200, "WM_MOUSEMOVE / WM_MOUSEFIRST" },
        { 0x0201, "WM_LBUTTONDOWN" },
        { 0x0202, "WM_LBUTTONUP" },
        { 0x0203, "WM_LBUTTONDBLCLK" },
        { 0x0204, "WM_RBUTTONDOWN" },
        { 0x0205, "WM_RBUTTONUP" },
        { 0x0206, "WM_RBUTTONDBLCLK" },
        { 0x0207, "WM_MBUTTONDOWN" },
        { 0x0208, "WM_MBUTTONUP" },
        { 0x0209, "WM_MBUTTONDBLCLK / WM_MOUSELAST" },
        { 0x020a, "WM_MOUSEWHEEL" },
        { 0x020b, "WM_XBUTTONDOWN" },
        { 0x020c, "WM_XBUTTONUP" },
        { 0x020d, "WM_XBUTTONDBLCLK" },
        { 0x020e, "WM_MOUSEHWHEEL" },
        { 0x0210, "WM_PARENTNOTIFY" },
        { 0x0211, "WM_ENTERMENULOOP" },
        { 0x0212, "WM_EXITMENULOOP" },
        { 0x0213, "WM_NEXTMENU" },
        { 0x0214, "WM_SIZING" },
        { 0x0215, "WM_CAPTURECHANGED" },
        { 0x0216, "WM_MOVING" },
        { 0x0218, "WM_POWERBROADCAST" },
        { 0x0219, "WM_DEVICECHANGE" },
        { 0x0220, "WM_MDICREATE" },
        { 0x0221, "WM_MDIDESTROY" },
        { 0x0222, "WM_MDIACTIVATE" },
        { 0x0223, "WM_MDIRESTORE" },
        { 0x0224, "WM_MDINEXT" },
        { 0x0225, "WM_MDIMAXIMIZE" },
        { 0x0226, "WM_MDITILE" },
        { 0x0227, "WM_MDICASCADE" },
        { 0x0228, "WM_MDIICONARRANGE" },
        { 0x0229, "WM_MDIGETACTIVE" },
        { 0x0230, "WM_MDISETMENU" },
        { 0x0231, "WM_ENTERSIZEMOVE" },
        { 0x0232, "WM_EXITSIZEMOVE" },
        { 0x0233, "WM_DROPFILES" },
        { 0x0234, "WM_MDIREFRESHMENU" },
        { 0x0280, "WM_IME_REPORT" },
        { 0x0281, "WM_IME_SETCONTEXT" },
        { 0x0282, "WM_IME_NOTIFY" },
        { 0x0283, "WM_IME_CONTROL" },
        { 0x0284, "WM_IME_COMPOSITIONFULL" },
        { 0x0285, "WM_IME_SELECT" },
        { 0x0286, "WM_IME_CHAR" },
        { 0x0288, "WM_IME_REQUEST" },
        { 0x0290, "WM_IME_KEYDOWN" },
        { 0x0291, "WM_IME_KEYUP" },
        { 0x02a0, "WM_NCMOUSEHOVER" },
        { 0x02a1, "WM_MOUSEHOVER" },
        { 0x02a2, "WM_NCMOUSELEAVE" },
        { 0x02a3, "WM_MOUSELEAVE" },
        { 0x0300, "WM_CUT" },
        { 0x0301, "WM_COPY" },
        { 0x0302, "WM_PASTE" },
        { 0x0303, "WM_CLEAR" },
        { 0x0304, "WM_UNDO" },
        { 0x0305, "WM_RENDERFORMAT" },
        { 0x0306, "WM_RENDERALLFORMATS" },
        { 0x0307, "WM_DESTROYCLIPBOARD" },
        { 0x0308, "WM_DRAWCLIPBOARD" },
        { 0x0309, "WM_PAINTCLIPBOARD" },
        { 0x030a, "WM_VSCROLLCLIPBOARD" },
        { 0x030b, "WM_SIZECLIPBOARD" },
        { 0x030c, "WM_ASKCBFORMATNAME" },
        { 0x030d, "WM_CHANGECBCHAIN" },
        { 0x030e, "WM_HSCROLLCLIPBOARD" },
        { 0x030f, "WM_QUERYNEWPALETTE" },
        { 0x0310, "WM_PALETTEISCHANGING" },
        { 0x0311, "WM_PALETTECHANGED" },
        { 0x0312, "WM_HOTKEY" },
        { 0x0317, "WM_PRINT" },
        { 0x0318, "WM_PRINTCLIENT" },
        { 0x0319, "WM_APPCOMMAND" },
        { 0x0358, "WM_HANDHELDFIRST" },
        { 0x035f, "WM_HANDHELDLAST" },
        { 0x0360, "WM_AFXFIRST" },
        { 0x037f, "WM_AFXLAST" },
        { 0x0380, "WM_PENWINFIRST" },
        { 0x0381, "WM_RCRESULT" },
        { 0x0382, "WM_HOOKRCRESULT" },
        { 0x0383, "WM_GLOBALRCCHANGE / WM_PENMISCINFO" },
        { 0x0384, "WM_SKB" },
        { 0x0385, "WM_HEDITCTL / WM_PENCTL" },
        { 0x0386, "WM_PENMISC" },
        { 0x0387, "WM_CTLINIT" },
        { 0x0388, "WM_PENEVENT" },
        { 0x038f, "WM_PENWINLAST" },
        { 0x0400, "WM_USER / WM_PSD_PAGESETUPDLG" },
        { 0x0401, "WM_PSD_FULLPAGERECT / WM_CHOOSEFONT_GETLOGFONT" },
        { 0x0402, "WM_PSD_MINMARGINRECT" },
        { 0x0403, "WM_PSD_MARGINRECT" },
        { 0x0404, "WM_PSD_GREEKTEXTRECT" },
        { 0x0405, "WM_PSD_ENVSTAMPRECT" },
        { 0x0406, "WM_PSD_YAFULLPAGERECT" },
        { 0x0464, "WM_CAP_UNICODE_START" },
        { 0x0465, "WM_CHOOSEFONT_SETLOGFONT" },
        { 0x0466, "WM_CAP_SET_CALLBACK_ERRORW / WM_CHOOSEFONT_SETFLAGS" },
        { 0x0467, "WM_CAP_SET_CALLBACK_STATUSW" },
        { 0x0470, "WM_CAP_DRIVER_GET_NAMEW" },
        { 0x0471, "WM_CAP_DRIVER_GET_VERSIONW" },
        { 0x0478, "WM_CAP_FILE_SET_CAPTURE_FILEW" },
        { 0x0479, "WM_CAP_FILE_GET_CAPTURE_FILEW" },
        { 0x047b, "WM_CAP_FILE_SAVEASW" },
        { 0x047d, "WM_CAP_FILE_SAVEDIBW" },
        { 0x04a6, "WM_CAP_SET_MCI_DEVICEW" },
        { 0x04a7, "WM_CAP_GET_MCI_DEVICEW" },
        { 0x04b4, "WM_CAP_PAL_OPENW" },
        { 0x04b5, "WM_CAP_PAL_SAVEW" },
        { 0x0659, "WLX_WM_SAS" },
        { 0x07e8, "WM_CPL_LAUNCH" },
        { 0x07e9, "WM_CPL_LAUNCHED" },
        { 0x8000, "WM_APP" },
        { 0xcccd, "WM_RASDIALEVENT" },
    };

    public void AddMessageHandler(int messageId, CustomActionDelegate handler)
    {
        if (!messageHandlers.ContainsKey(messageId))
        {
            messageHandlers.Add(messageId, handler);
        }
        else
        {
            messageHandlers[messageId] += handler;
        }
    }

    protected override void WndProc(ref Message message)
    {
        LogMessage(message);
        InvokeCustomHandler(message);
        base.WndProc(ref message);
    }

    private void LogMessage(Message message)
    {
        string messageName;
        if (KnownMessages.TryGetValue(message.Msg, out messageName))
        {
            Console.WriteLine(String.Format("Received: {0}, Msg = {1}, WParam = {2}, LParam = {3}", 
                messageName, message.Msg, message.WParam.ToInt32(), message.LParam.ToInt64()));
        }
        else
        {
            Console.WriteLine(String.Format("Received: unknown, Msg = {0}, WParam = {1}, LParam = {2}", 
                message.Msg, message.WParam.ToInt32(), message.LParam.ToInt64()));
        }
    }

    private void InvokeCustomHandler(Message message)
    {
        CustomActionDelegate handler;
        if (messageHandlers.TryGetValue(message.Msg, out handler) && handler != null)
        {
            handler.Invoke(message.WParam.ToInt64(), message.LParam.ToInt64());
        }
    }
}
"@ -ReferencedAssemblies "System.Windows.Forms"

# Define your custom function here
function CustomFunction {
    param([long]$wParam, [long]$lParam)

    $PBT_APMSUSPEND = 0x0004
    $PBT_APMRESUMEAUTOMATIC = 0x0012

    switch ($wParam) {
        $PBT_APMSUSPEND { Write-Host "I'm falling asleep!" }
        $PBT_APMRESUMEAUTOMATIC { Write-Host "I'm waking up!" }
    }
}


$MessageHandler = New-Object MessageHandler

# Registering the WM_POWERBROADCAST message (0x0218) with CustomFunction
$MessageHandler.AddMessageHandler(0x0218, { param($w, $l) CustomFunction $w $l })

$MessageHandler.ShowDialog()
