# Создание и открытие чертежей

Для создания нового чертежа или открытия существующего используйте методы класса DocumentCollection (возвращается как свойство HostMgd.ApplicationServices.Application.DocumentManager). Метод Add создает новый чертеж из файла шаблона DWT, перегрузки методов Open предназначены для открытия существующего DWG-файла. 

## Создание нового чертежа

В примере ниже новый чертеж создается и становится активным. Если указанный шаблон в аргументе templateFileName не был найден, то чертеж будет создан на базе шаблона по умолчанию. 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Runtime;
 
[CommandMethod("NewDrawing", CommandFlags.Session)]
public static void NewDrawing()
{
    // Specify the template to use, if the template is not found
    // the default settings are used.
    string strTemplatePath = "acad.dwt";

    DocumentCollection acDocMgr = Application.DocumentManager;
    Document acDoc = acDocMgr.Add(strTemplatePath);

    acDocMgr.MdiActiveDocument = acDoc;
}
```

## Открытие существующего чертежа

Код в примере открывает существующий файл чертежа, проверяя перед этим, существует ли файл по указанному пути: 

```cs
using System.IO;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Runtime;
 
[CommandMethod("OpenDrawing", CommandFlags.Session)]
public static void OpenDrawing()
{
    string strFileName = "C:\\campus.dwg";
    DocumentCollection acDocMgr = Application.DocumentManager;

    if (File.Exists(strFileName))
    {
        acDocMgr.Open(strFileName, false);
    }
    else
    {
        acDocMgr.MdiActiveDocument.Editor.WriteMessage("File " + strFileName +
                                                        " does not exist.");
    }
}
```
