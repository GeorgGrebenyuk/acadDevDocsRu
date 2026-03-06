# Об использовании динамической типизации

Существовавшая в AutoCAD .NET API динамическая типизация, позволявшая получать прямой доступ к объектам без их открытия для чтения, в nanoCAD .NET API не реализована. Использовать динамическую типизацию целесобразно использовать только для работы с COM-интерфейсами - в этом случае нет опасений обратиться к иной версии COM-библиотеки (так как версии nanoCAD Type Library меняются для каждого основного релиза).

В управляемом AutoCAD .NET API возможно использовать динамическую типизацию - Dynamic Language Runtime (DLR), введенную с .NET 4.0. Используя её, необходимо подключать к проекту "Microsoft.CSharp.dll"

Использование DLR позволяет получать прямой доступ к объектам без необходимости:

* Открывать объект для чтения или записи, а затем закрывать его после завершения работы;

* Использовать транзакции для сохранения внесенных изменений;

С использованием DLR вы можете получить прямой доступ к свойствам и методам объекта, получив его ObjectId. Получив ObjectId, вы можете присвоить объект переменной типа данных:

* Object в VB.NET;
* dynamic в C#;

Получение идентификатора объекта (ObjectId) зависит от того, как объект хранится в базе данных. Для объектов, сохраненных в таблице или словаре, вы можете получить ObjectId, используя:

* Метод ObjectId.Item для доступа к элементу в коллекции;
* Создание ссылки на ObjectId целевой таблицы или словаря путем присвоения её временной переменной и затем обращение к этой переменной для получения элемента массива
  Код ниже показывает оба способа получения доступа к объекту, сохраненному в таблице символов с использованием DLR 

```csharp
// Item method
dynamic acCurDb = HostApplicationServices.WorkingDatabase;
dynamic acMSpace = acCurDb.BlockTableId.Item(BlockTableRecord.ModelSpace);

// Reference an element directly from a collection
dynamic acCurDb = HostApplicationServices.WorkingDatabase;
dynamic acBlkTbl = acCurDb.BlockTableId;
dynamic acMSpace = acBlkTbl[BlockTableRecord.ModelSpace];
```

## Работа с методом GetEnumerator

При использовании метода GetEnumerator в DLR, необходимо будет избавиться от объекта перечисления после завершения работы с ним. Приведенный ниже код содержит это действие. 

```csharp
dynamic acCurDb = HostApplicationServices.WorkingDatabase;
var acLtypeTbl = acCurDb.LinetypeTableId;
var acTblEnum = acLtypeTbl.GetEnumerator();
```

## Использование LINQ-функций

Можно использовать LINQ для получения содержимого таблицы или словаря в чертеже с помощью DLR. Следующий пример демонстрирует использование LINQ-запросов для поиска отключенных и замороженных слоев.

```csharp
[CommandMethod("LINQ")]
public static void LINQExample()
{
    dynamic db = HostApplicationServices.WorkingDatabase;
    dynamic doc = Application.DocumentManager.MdiActiveDocument;

    var layers = db.LayerTableId;
    for (int i = 0; i < 2; i++)
    {
        var newrec = layers.Add(new LayerTableRecord());
        newrec.Name = "Layer" + i.ToString();
        if (i == 0)
            newrec.IsFrozen = true;
        if (i == 1)
            newrec.IsOff = true;
    }

    var OffLayers = from l in (IEnumerable<dynamic>)layers
                    where l.IsOff
                    select l;

    doc.Editor.WriteMessage("\nLayers Turned Off:");

    foreach (dynamic rec in OffLayers)
        doc.Editor.WriteMessage("\n - " + rec.Name);

    var frozenOrOffNames = from l in (IEnumerable<dynamic>)layers
                            where l.IsFrozen == true || l.IsOff == true
                            select l;

    doc.Editor.WriteMessage("\nLayers Frozen or Turned Off:");

    foreach (dynamic rec in frozenOrOffNames)
        doc.Editor.WriteMessage("\n - " + rec.Name);
}
```

## Прочие примеры

Приведенные ниже примеры используют следующие пространства имён

```csharp
using Autodesk.AutoCAD.Runtime
using Autodesk.AutoCAD.ApplicationServices
using Autodesk.AutoCAD.DatabaseServices
using Autodesk.AutoCAD.Colors
using Autodesk.AutoCAD.Geometry
```

Добавление отрезка в текущее пространство без DLR и с его помощью:

```csharp
[CommandMethod("ADDLINE_WITHOUT_DLR")]
public static void AddLine()
{
    // Get the current database
    Database acCurDb = HostApplicationServices.WorkingDatabase;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                     OpenMode.ForRead) as BlockTable;

        // Open the Block table record Model space for write
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;

        // Create a line that starts at 5,5 and ends at 12,3
        using (Line acLine = new Line(new Point3d(5, 5, 0),
                                      new Point3d(12, 3, 0)))
        {
            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acLine);
            acTrans.AddNewlyCreatedDBObject(acLine, true);
        }

        // Save the new object to the database
        acTrans.Commit();
    }
}
//
[CommandMethod("ADDLINE_WITH_DLR")]
public static void AddLine()
{
    // Get the current database
    dynamic acCurDb = HostApplicationServices.WorkingDatabase;

    // Create a dynamic reference to model or paper space
    dynamic acSpace = acCurDb.CurrentSpaceId;

    // Create a line that starts at 5,5 and ends at 12,3
    dynamic acLine = new Line(new Point3d(5, 5, 0),
                              new Point3d(12, 3, 0));

    // Add the new object to the current space
    acSpace.AppendEntity(acLine);
}
```

Перебор объектов в текущем пространстве без DLR и с его помощью:

```csharp
[CommandMethod("LISTOBJECTS_WITHOUT_DLR")]
public static void ListObjects()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = HostApplicationServices.WorkingDatabase;

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table record Model space for write
        BlockTableRecord acSpace;
        acSpace = acTrans.GetObject(acCurDb.CurrentSpaceId,
                                    OpenMode.ForRead) as BlockTableRecord;

        // Step through the current space
        foreach (ObjectId objId in acSpace)
        {
            // Display the class and current layer of the object
            Entity acEnt = (Entity)acTrans.GetObject(objId, OpenMode.ForRead);
            acDoc.Editor.WriteMessage("\nObject Class: " + acEnt.GetRXClass().Name +
                                      "\nCurrent Layer: " + acEnt.Layer + 
                                       "\n");
        }
        acTrans.Commit();
    }
}

[CommandMethod("LISTOBJECTS_WITH_DLR")]
public static void ListObjects()
{
    // Get the current document and database
    dynamic acDoc = Application.DocumentManager.MdiActiveDocument;
    dynamic acCurDb = HostApplicationServices.WorkingDatabase;

    // Create a dynamic reference to model or paper space
    dynamic acSpace = acCurDb.CurrentSpaceId;

    // Step through the current space
    foreach (dynamic acEnt in acSpace)
    {
        // Display the class and current layer of the object
        acDoc.Editor.WriteMessage("\nObject Class: " + acEnt.GetRXClass().Name +
                                  "\nCurrent Layer: " + acEnt.Layer +
                                  "\n");
    }
}
```
