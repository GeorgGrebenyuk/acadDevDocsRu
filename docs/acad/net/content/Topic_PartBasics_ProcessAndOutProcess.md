# Межпроцессорное взаимодействие

При разработке нового приложения (на поддерживаемых языках программирования) оно может выполняться как в основном процессе AutoCAD, так и вне процесса. Настоящее .NET API предназначено только для работы в одном процессе с AutoCAD; вместе с тем использование ActiveX Automation позволяет работать как в данном процессе, так и вне его. 

Для создания нового процесса AutoCAD необходимо создать новый экземпляр приложения AutoCAD или обратиться к уже запущенному приложению помимо данного. После получения ссылки на запущенный экземпляр nanoCAD, при помощи ActiveX Automation производим загрузку в него целевой .NET-библиотеки с помощью метода SendCommand, который является членом документа nanoCAD, возвращаемым через свойство ActiveDocument приложения AcadApplication. 

Пример ниже иллюстрирует такой подход - к примеру, библиотека загружена в AutoCAD 2022 и вызывает новое окно (либо пытается подключиться к уже имеющемуся) для AutoCAD 2023. После загрузки, в новый документ загружается через консоль некая .NET-библиотека, которой подается команда с целевыми параметрами обработки. 

```cs
using System;
using Autodesk.AutoCAD.Runtime;
using System.Runtime.InteropServices;
public class Loader
{
    [CommandMethod("ConnectToNcad")]
    public static void ConnectToNcad()
    {
        nanoCAD.Application acAppComObj = null;
        const string strProgId = "nanoCAD.Application.25.0";
        // Get a running instance of nanoCAD
        try
        {
            acAppComObj = (AutoCAD.Application)Marshal.GetActiveObject(strProgId);
        }
        catch // An error occurs if no instance is running
        {
            try
            {
                // Create a new instance of AutoCAD
                acAppComObj = (AutoCAD.Application)Activator.CreateInstance(Type.GetTypeFromProgID(strProgId), true);
            }
            catch
            {
                // If an instance of AutoCAD is not created then message and exit
                System.Windows.Forms.MessageBox.Show("Instance of 'AutoCAD.Application' could not be created.");
                return;
            }
        }
        // Display the application and return the name and version
        acAppComObj.Visible = true;
        System.Windows.Forms.MessageBox.Show("Now running " + acAppComObj.Name + "version " + acAppComObj.Version);
        // Get the active document
        AutoCAD.AcaCADDocument acDocComObj;
        acDocComObj = acAppComObj.ActiveDocument;
        // Optionally, load your assembly and start your command or if your assembly
        // is demandloaded, simply start the command of your in-process assembly.
        acDocComObj.SendCommand("(command " + (char)34 + "NETLOAD" + (char)34 + " " +
                                (char)34 + "c:/myapps/mycommands.dll" + (char)34 + ") ");
        acDocComObj.SendCommand("MyCommand ");
    }
}
```

<b>Примечание</b>: при использовании .NET 8+ метода System.Runtime.InteropServices.Marshal.GetActiveObject в системной библиотеке нет. Вместо него можно использовать различные реализации, например, код ниже: 

```cs
//From https://stackoverflow.com/a/65496277
public static class Marshal2
{
    \internal const String OLEAUT32 = "oleaut32.dll";
    \internal const String OLE32 = "ole32.dll";
    [System.Security.SecurityCritical]  // auto-generated_required
    public static Object GetActiveObject(String progID)
    {
        Object obj = null;
        Guid clsid;
        // Call CLSIDFromProgIDEx first then fall back on CLSIDFromProgID if
        // CLSIDFromProgIDEx doesn't exist.
        try
        {
            CLSIDFromProgIDEx(progID, out clsid);
        }
        //            catch
        catch (System.Exception)
        {
            CLSIDFromProgID(progID, out clsid);
        }
        GetActiveObject(ref clsid, IntPtr.Zero, out obj);
        return obj;
    }
    //[DllImport(Microsoft.Win32.Win32Native.OLE32, PreserveSig = false)]
    [DllImport(OLE32, PreserveSig = false)]
    [System.Runtime.Versioning.ResourceExposure(System.Runtime.Versioning.ResourceScope.None)]
    [System.Security.SuppressUnmanagedCodeSecurity]
    [System.Security.SecurityCritical]  // auto-generated
    private static extern void CLSIDFromProgIDEx([MarshalAs(UnmanagedType.LPWStr)] String progId, out Guid clsid);
    //[DllImport(Microsoft.Win32.Win32Native.OLE32, PreserveSig = false)]
    [DllImport(OLE32, PreserveSig = false)]
    [System.Runtime.Versioning.ResourceExposure(System.Runtime.Versioning.ResourceScope.None)]
    [System.Security.SuppressUnmanagedCodeSecurity]
    [System.Security.SecurityCritical]  // auto-generated
    private static extern void CLSIDFromProgID([MarshalAs(UnmanagedType.LPWStr)] String progId, out Guid clsid);
    //[DllImport(Microsoft.Win32.Win32Native.OLEAUT32, PreserveSig = false)]
    [DllImport(OLEAUT32, PreserveSig = false)]
    [System.Runtime.Versioning.ResourceExposure(System.Runtime.Versioning.ResourceScope.None)]
    [System.Security.SuppressUnmanagedCodeSecurity]
    [System.Security.SecurityCritical]  // auto-generated
    private static extern void GetActiveObject(ref Guid rclsid, IntPtr reserved, [MarshalAs(UnmanagedType.Interface)] out Object ppunk);
}
```
