# Приложение Navisworks

Navisworks, как приложение, описывается отдельной библиотекой типов под названием "NavisworksAutomation". Её необходимо подключить к проекту вручную. Также необходимо подключить Intergated API.
![[Pasted image 20260418201504.png]]

Приложение Navisworks описывается COM-оболочкой `NavisworksAutomationAPI18.Document` (где 18 - номер версии Navisworks, в данном случае 2021; приведение нужно скорее для знакомства с API, можно использовать и dynamic, *прим. автора*). У любого приложения Navisworks процесс имеет постоянный префикс `Navisworks.Document`. По нему можно идентифицировать запущенные процессы, либо создать новый процесс. В табличке ниже приведена информация о соответствии версии NW и ProgId - она фактически "линейная".

| Версия NW       | Соответствующий ProgId | Примечание    |
| --------------- | ---------------------- | ------------- |
| Navisworks 2015 | Navisworks.Document.12 |               |
| Navisworks 2016 | Navisworks.Document.13 |               |
| Navisworks 2017 | Navisworks.Document.14 |               |
| Navisworks 2018 | Navisworks.Document.15 |               |
| Navisworks 2019 | Navisworks.Document.16 |               |
| Navisworks 2020 | Navisworks.Document.17 |               |
| Navisworks 2021 | Navisworks.Document.18 |               |
| Navisworks 2022 | Navisworks.Document.19 | 19.1 : 2022.1 |
| Navisworks 2023 | Navisworks.Document.20 | 20.1 : 2023.1 |
| Navisworks 2024 | Navisworks.Document.21 |               |
| Navisworks 2025 | Navisworks.Document.22 |               |
| Navisworks 2026 | Navisworks.Document.23 |               |
| Navisworks 2027 | Navisworks.Document.24 |               |
## Подключение к Navisworks

Рассмотрим случай подключения к Navisworks из-под стороннего процесса, создания нового процесса и переходу к COM из-под .NET API
### Подключение к запущенному Navisworks

Для подключения к приложению Navisworks (если оно запущено) из внешнего процесса необходимо найти среди запущенных процессов начинающиеся на `Navisworks.Document` и далее использовать его.

Хорошая реализация процесса получения запущенных COM-приложений приведена [тут](https://stackoverflow.com/a/7738455). На всякий случай приведу её листинг ниже:

```cs
using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Text;

public class COM_Interaction
{
    private COM_Interaction() { }

    public static List<string> GetCOMProcesses()
    {
        StringBuilder SB = new StringBuilder();
        List<string> processes = new List<string>();
        foreach (var moniker in EnumRunningObjects())
        {
            List<string> t1 = GetMonikerString(moniker).Split('\t').ToList();
            processes = processes.Concat(t1).ToList();
        }
        return processes;
    }
    private const int S_OK = 0x00000000;

    [DllImport("ole32.dll")]
    private static extern int GetRunningObjectTable(uint reserved, out IRunningObjectTable pprot);

    [DllImport("ole32.dll")]
    private static extern int CreateBindCtx(uint reserved, out IBindCtx ppbc);

    private static void OleCheck(string message, int result)
    {
        if (result != S_OK)
            throw new COMException(message, result);
    }

    private static IEnumerable<IMoniker> EnumRunningObjects()
    {
        IRunningObjectTable objTbl;
        OleCheck("GetRunningObjectTable failed", GetRunningObjectTable(0, out objTbl));
        IEnumMoniker enumMoniker;
        IMoniker[] monikers = new IMoniker[1];
        objTbl.EnumRunning(out enumMoniker);
        enumMoniker.Reset();
        while (enumMoniker.Next(1, monikers, IntPtr.Zero) == S_OK)
        {
            yield return monikers[0];
        }
    }

    private static bool TryGetCLSIDFromDisplayName(string displayName, out string clsid)
    {
        var bBracket = displayName.IndexOf("{");
        var eBracket = displayName.IndexOf("}");
        if (bBracket > 0 && eBracket > 0 && eBracket > bBracket)
        {
            clsid = displayName.Substring(bBracket, eBracket - bBracket + 1);
            return true;
        }
        else
        {
            clsid = string.Empty;
            return false;
        }
    }

    private static string ReadSubKeyValue(string keyName, RegistryKey key)
    {
        var subKey = key.OpenSubKey(keyName);
        if (subKey != null)
        {
            using (subKey)
            {
                var value = subKey.GetValue("");
                return value == null ? string.Empty : value.ToString();
            }
        }
        return string.Empty;
    }

    private static string GetMonikerString(IMoniker moniker)
    {
        IBindCtx ctx;
        OleCheck("CreateBindCtx failed", CreateBindCtx(0, out ctx));
        var sb = new StringBuilder();
        string displayName;
        moniker.GetDisplayName(ctx, null, out displayName);
        sb.Append(displayName);
        sb.Append('\t');
        string clsid;
        if (TryGetCLSIDFromDisplayName(displayName, out clsid))
        {
            var regClass = Registry.ClassesRoot.OpenSubKey("\\CLSID\\" + clsid);
            if (regClass != null)
            {
                using (regClass)
                {
                    sb.Append(regClass.GetValue(""));
                    sb.Append('\t');
                    sb.Append(ReadSubKeyValue("ProgID", regClass));
                    sb.Append('\t');
                    sb.Append(ReadSubKeyValue("LocalServer32", regClass));
                }
            }
        }
        return sb.ToString();
    }
}

```

Пример работы с листингом выше может выглядеть так (для метода `GetNWInstance`):

```cs
using System.Runtime.InteropServices;

[DllImport("ole32.dll")]
public static extern int GetActiveObjectExt(ref Guid rclsid, IntPtr reserved, [MarshalAs(UnmanagedType.Interface)] out object ppunk);

public static object? GetNWInstance()
{
    foreach (string comProcId in COM_Interaction.GetCOMProcesses())
    {
        if (comProcId.Contains("Navisworks.Document."))
        {
            var type = Type.GetTypeFromProgID(comProcId);
            var guid = type.GUID;

            object obj;
            int result = GetActiveObjectExt(ref guid, IntPtr.Zero, out obj);

            return obj;
        }
    }
    return null;
}
```
**Примечание**: в листинге выше используется обращение к GetActiveObjectExt, это универсальная конструкция для .NET5+ и .NET Framework.

### Запуск нового экземпляра Navisworks

Если на данном ПК установлен любой Navisworks, то можно запустить его экземпляр для заданной версии ProgID (см. табличку в начале раздела).

```cs
string nwProgID = "Navisworks.Document.18"; // for NW 2021
var type = System.Type.GetTypeFromProgID(nwProgID);
object nwApp = System.Activator.CreateInstance(type);
```

### Подключение к COM из-под .NET API

Для этого в .NET API имеется специальный класс `Autodesk.Navisworks.Api.ComApi.ComApiBridge` (из `Autodesk.Navisworks.ComApi.dll`), а само COM API доступно через пространство имён `Autodesk.Navisworks.Api.Interop`. Тогда переход к COM-оболочки модели будет выглядеть как:

```cs
using ComBridge = Autodesk.Navisworks.Api.ComApi.ComApiBridge;
using COMApi = Autodesk.Navisworks.Api.Interop.ComApi;

COMApi.InwOpState oState = ComBridge.State;
```

## Действия с приложением

По существу, доступная функциональность COM-оболочки приложения Navisworks ограничивается следующими действиями:
- открыть проект Navisworks (\*.nwd; \*.nwf);
- подключить к проекту данные (аналог команды "Главная - Добавить - ... ");
- сохранить проект в файл;
- получить доступ к содержимому проекту (COM-оболочка `InwOpState`);

**Примечание**: добиться работы метода AppendFile у меня не получилось - выбрасывало странное исключение про файл. 

Наиболее важное доступное действие - это получение доступа к содержимому проекту (COM-оболочка `InwOpState`), т.к. именно с ней идут все остальные действия с COM API.