# Загрузка и установка активного типа линии

Чтобы вновь создаваемые объекты имели заданный тип линии, его необходимо задать в качестве значения по умолчанию. Существует два различных способа установки типа линии к объекту: напрямую (перезаписать тип линии слоя) или унаследованный от слоя (объект наследует тип линии слоя, на котором он находится, путем установки свойства Linetype или LinetypeId, для типа линии ByLayer).

**Примечание**: типы линий из внешних ссылок не могут использоваться в данном чертеже.

В каждом чертеже обязательно существует как минимум три типа линий: BYBLOCK, BYLAYER и CONTINUOUS. Доступ к каждому из этих типов линий можно получить из таблицы типов линий LinetypeTable или с помощью статических методов вспомогательного SymbolUtilityServices из пространства имён Teigha.DatabaseServices. Следующие методы позволяют получить идентификатор объекта для этих типов линий по умолчанию:

* GetLinetypeByBlockId — возвращает идентификатор объекта для типа линии BYBLOCK;
* GetLinetypeByLayerId — возвращает идентификатор объекта для типа линии BYLAYER;
* GetLinetypeContinuousId — возвращает идентификатор объекта для типа линии CONTINUOUS;

Пример ниже содержит код, задающий тип линии "Осевая" новому объекту - окружности. Если такого типа линий в таблице типов линий нет, то его можно загрузить из файла определения типов линий. 

```csharp
string sLineTypName = "Center";
Database acCurDb;
acCurDb.LoadLineTypeFile(sLineTypName, "acad.lin");
```

**Примечание**: в nanoCAD .NET API и вероятно в прочих .NET API, основанных на ODA, в реализации метода `LoadLineTypeFile` допущена ошибка, для корректной работы ему необходимо подавать _полный путь_ к файлу с линиями, иначе выбросится ошибка eFileAccessErr или иная.

Для установки объекту типа линии желательно использовать свойство LinetypeId, вместо свойства Linetype.

**Примечание**: в nanoCAD .NET API при попытке задания типа линии через Linetype может выброситься ошибка eNoDatabase. 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("SetObjectLinetype")]
public static void SetObjectLinetype()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Linetype table for read
        LinetypeTable acLineTypTbl;
        acLineTypTbl = acTrans.GetObject(acCurDb.LinetypeTableId,
                                            OpenMode.ForRead) as LinetypeTable;

        string sLineTypName = "Center";

        if (acLineTypTbl.Has(sLineTypName) == false)
        {
            acCurDb.LoadLineTypeFile(sLineTypName, "acad.lin");
        }

        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                        OpenMode.ForRead) as BlockTable;

        // Open the Block table record Model space for write
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;

        // Create a circle object
        using (Circle acCirc = new Circle())
        {
            acCirc.Center = new Point3d(2, 2, 0);
            acCirc.Radius = 1;
            acCirc.Linetype = sLineTypName;

            acBlkTblRec.AppendEntity(acCirc);
            acTrans.AddNewlyCreatedDBObject(acCirc, true);
        }

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```

## Задание активного типа линии через свойство Database.Celtype

В примере ниже тип линии "Осевая" задается активным, если он присутсвует в таблице типов линии чертежа. Имейте в виду также о свойстве масштаба типа линии, который задается через свойство Celtscale. 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("SetLinetypeCurrent")]
public static void SetLinetypeCurrent()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Linetype table for read
        LinetypeTable acLineTypTbl;
        acLineTypTbl = acTrans.GetObject(acCurDb.LinetypeTableId,
                                            OpenMode.ForRead) as LinetypeTable;

        string sLineTypName = "Center";

        if (acLineTypTbl.Has(sLineTypName) == true)
        {
            // Set the linetype Center current
            acCurDb.Celtype = acLineTypTbl[sLineTypName];

            // Save the changes
            acTrans.Commit();
        }

        // Dispose of the transaction
    }
}
```

## Задание активного типа линии через переменную CELTYPE

Пример ниже задает активный тип линии = Осевая с помощью задания системной переменной CELTYPE. Если типа линий с таким названием не существует, то будет выброшено исключение eInvalidInput. 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;

[CommandMethod("SetLineTypeCurrent")]
public static void SetLineTypeCurrent()
{
    Application.SetSystemVariable("CELTYPE", "1");
}
```
