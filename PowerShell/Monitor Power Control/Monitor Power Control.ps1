# Definition
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class DisplayController {
    private const int SC_MONITORPOWER = 0xF170;
    private const int WM_SYSCOMMAND = 0x0112;
    private const int MONITOR_ON = -1;
    private const int MONITOR_STANDBY = 1;
    private const int MONITOR_OFF = 2;

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    private static extern IntPtr SendMessage(
        IntPtr hWnd,
        uint Msg,
        IntPtr wParam,
        IntPtr lParam
    );

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr CreateWindowEx(
        uint dwExStyle,
        string lpClassName,
        string lpWindowName,
        uint dwStyle,
        int x,
        int y,
        int nWidth,
        int nHeight,
        IntPtr hWndParent,
        IntPtr hMenu,
        IntPtr hInstance,
        IntPtr lpParam
    );

    [DllImport("user32.dll")]
    private static extern bool DestroyWindow(IntPtr hWnd);

    private static void ChangeMonitorPowerState(int powerState) {
        IntPtr dummyWindowHandle = CreateDummyWindow();
        if (dummyWindowHandle != IntPtr.Zero) {
            SendMessage(dummyWindowHandle, WM_SYSCOMMAND, (IntPtr)SC_MONITORPOWER, (IntPtr)powerState);
            DestroyWindow(dummyWindowHandle);
        }
    }

    public static void PowerOn() {
        ChangeMonitorPowerState(MONITOR_ON);
    }

    public static void PowerStandby() {
        ChangeMonitorPowerState(MONITOR_STANDBY);
    }

    public static void PowerOff() {
        ChangeMonitorPowerState(MONITOR_OFF);
    }


    private static IntPtr CreateDummyWindow() {
        return CreateWindowEx(
            0,
            "Message",
            null,
            0,
            0, 0, 0, 0,
            IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero
        );
    }
}
"@


# How to use
# [DisplayController]::PowerOn()
# [DisplayController]::PowerStandby()
[DisplayController]::PowerOff()
