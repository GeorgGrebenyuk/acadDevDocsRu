# Подключение к приложению Renga
## Получение приложение из загруженного плагина

Для внутренних приложений, загружаемых в Renga в виде плагинов, вопрос получения COM-интерфейса, описывающего приложение Renga не стоит - просто вызывается соответствующий метод:
На C#:
```csharp
Renga.Application rengaApp = new Renga.Application();
```
На C++:
```cpp
Renga::IApplicationPtr rengaApp = Renga::CreateApplication();
```
## Получение приложения из внешнего процесса
Сложнее обстоит вопрос с доступом к приложению Renga из стороннего процесса. Так или иначе, способы будут завязаны на COM-методы, так как само API реализовано на COM-технологии.
Есть 2 сценария -- создать новый процесс Renga и подключиться к текущему процессу.
### C++
Для запуска нового процесса Renga создайте экземпляр COM-оболочки приложения, выполните с ней действия и закройте приложение. Листинг далее со [странички официальной документации](https://help.rengabim.com/api/how-to-local-server.html).
```cpp
CoInitialize(nullptr);
auto renga = Renga::CreateApplication(CLSCTX_LOCAL_SERVER);
renga->PutVisible(VARIANT_TRUE);
renga->OpenProject(bstr_t(argv[1]));
// use Renga someway
renga->CloseProject(VARIANT_TRUE);
// Quit explicitly:
renga->Quit();

CoUninitialize();
```
Как правило, пользовательские приложения на C++ существуют только в виде плагинов, для них не рационально делать логику работы с COM из стороннего процесса. Автору во всяком случае неизвестны плагины к Renga, написанные на C++ и обращающиеся к ней извне (возможно, только крупные СОД).
Тем более, что работа с COM в C++ мягко говоря плохая и очень сильно отдает "legacy" .
Автор не использовал в своей практике подобных обращений, если вам надо -- вы можете попросить ИИ-агента помочь с этой задачей, автор не имеет желания пробовать это сам и писать здесь километровые листинги 😬.

### C\#
#### Marshal.GetActiveObject
Наиболее простая реализация на C# (фактически, на .NET) - обратиться к методу `Marshal.GetActiveObject` из пространства имён `System.Runtime.InteropServices` и передать ему в аргумент идентификатор Renga-приложения `Renga.Application.1`. Если приложение не запущено, то оно будет создано

**Примечание**: начиная с .NET 5+ эта функциональность удалена из .NET, вместо этого можете воспользоваться вызовами нативного API через DllImport
```csharp
//From https://stackoverflow.com/a/65496277
public static class Marshal2
{
    internal const String OLEAUT32 = "oleaut32.dll";
    internal const String OLE32 = "ole32.dll";

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


    [DllImport("ole32.dll")]
    internal static extern void GetRunningObjectTable(int reserved, out IRunningObjectTable prot);

    [DllImport("ole32.dll")]
    private static extern int CreateBindCtx(uint reserved, out IBindCtx ppbc);

    public static List<string> GetAppMonikers(string appName)
    {
        IRunningObjectTable rot;
        GetRunningObjectTable(0, out rot);

        IEnumMoniker monikerEnumerator = null;
        rot.EnumRunning(out monikerEnumerator);
        if (monikerEnumerator == null)
            return null;

        monikerEnumerator.Reset();

        var registries = new List<IMoniker>();
        var registries2 = new List<string>();

        IntPtr pNumFetched = new IntPtr();
        IMoniker[] monikers = new IMoniker[1];
        while (monikerEnumerator.Next(1, monikers, pNumFetched) == 0)
        {
            IBindCtx bindCtx;
            CreateBindCtx(0, out bindCtx);
            if (bindCtx == null)
                continue;

            string displayName;
            monikers[0].GetDisplayName(bindCtx, null, out displayName);
            //registries2.Add(displayName);
            if (displayName.Contains(appName)) registries.Add(monikers[0]);
        }
        return registries2;
    }
}
```
После прекращения работы с приложением Renga извне, если оно более не нужно, закройте его и освободите COM-объект приложения (далее `renga`) с помощью стандартного метода: 
```csharp
System.Runtime.InteropServices.Marshal.ReleaseComObject(renga);
```
#### Running Object Table
Официальная справка предлагает также обратить внимание на Windows-специфичную технологию "Running Object Table". Переиначивая примеры со [справки](https://help.rengabim.com/api/how-to-rot.html) конструкция, позволяющая получить все запущенные в системе процессы Renga будет выглядеть так:
```csharp
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;

public static Renga.IApplication[] GetRengaApps()
{
    IRunningObjectTable rot;
    GetRunningObjectTable(0, out rot);

    List<Renga.IApplication> tmpApps = new List<Renga.IApplication>();
    var rengaMonikers = GetRengaMonikers();
    foreach (var moniker in rengaMonikers)
    {
        object comObject;
        // Get first Renga moniker in list
        rot.GetObject(moniker, out comObject);

        Renga.IApplication rengaApp = comObject as Renga.IApplication;
        if (rengaApp != null) tmpApps.Add(rengaApp);
    }
    return tmpApps.ToArray();
}

[DllImport("ole32.dll")]
private static extern void GetRunningObjectTable(int reserved, out IRunningObjectTable prot);
[DllImport("ole32.dll")]
private static extern int CreateBindCtx(uint reserved, out IBindCtx ppbc);
private static List<IMoniker> GetRengaMonikers()
{
    IRunningObjectTable rot;
    GetRunningObjectTable(0, out rot);

    IEnumMoniker monikerEnumerator = null;
    rot.EnumRunning(out monikerEnumerator);
    if (monikerEnumerator == null)
        return null;

    monikerEnumerator.Reset();

    var registries = new List<IMoniker>();

    IntPtr pNumFetched = new IntPtr();
    IMoniker[] monikers = new IMoniker[1];
    while (monikerEnumerator.Next(1, monikers, pNumFetched) == 0)
    {
        IBindCtx bindCtx;
        CreateBindCtx(0, out bindCtx);
        if (bindCtx == null)
            continue;

        string displayName;
        monikers[0].GetDisplayName(bindCtx, null, out displayName);
        if (displayName.Contains("!Renga"))
            registries.Add(monikers[0]);
    }
    return registries;
}
```
### Pyhton
Необходимо установить вспомогательный пакет `pywin32`
```python
import win32com.client  
rengaApp = win32com.client.GetActiveObject("Renga.Application.1")  
if rengaApp is not None:  
    print("Application received successfully!")
```
### Powershell
Ниже пример, как создать новый процесс Renga, вывести в консоль номер версии программы и закрыть приложение.
```powershell
# --- Вспомогательная функция для освобождения ресрусов от COM-объекта
function Release-ComObject([object]$obj) {
    if ($null -ne $obj -and $obj -is [System.__ComObject]) {
        [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($obj)
    }
}

# Создадим экземпляр приложения Renga
$rengaApp = $null
try {
    $rengaApp = New-Object -ComObject "Renga.Application.1" -ErrorAction Stop
} catch {
    Write-Warning "Не удалось создать COM-объект Renga.Application.1. Если Renga не зарегистрирована как COM-сервер, выполните из папки установки: RengaProfessional.exe /regserver"
    Read-Host "Нажмите Enter для выхода"
    exit
}

# Делаем приложение видимым
$rengaApp.Visible = $true

# Выполняем некоторые действия, например, получаем информацию о версии приложения
Write-Host $rengaApp.VersionS

try { $rengaApp.Quit() } catch {}
Release-ComObject $rengaApp

```
