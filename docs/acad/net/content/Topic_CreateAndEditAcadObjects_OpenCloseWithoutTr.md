# Открытие и закрытие объектов без транзакций

Транзакции облегчают процесс получения и работы с несколькими объектами, но они не являются единственным способом обеспечения доступа к объектам. Кроме использования транзакций, вы также можете открывать и закрывать объекты с помощью методов Open и Close. 

Для использования метода `Open` вам, также как и для транзакций, необходимо получить идентификатор объекта ObjectId. Как и в методе GetObject, используемом с транзакциями, вам нужно указать режим открытия и осуществить приведение возвращаемого объекта DBObject к целевому типу. 

Если вы внесли изменения в объект после того, как открыли его с помощью метода Open, вы можете использовать метод `Cancel` для отката всех изменений, сделанных с момента открытия объекта. `Cancel` следует вызывать для каждого объекта, в котором вы хотите сделать откат. После закрытия объекта также обязательно надо освободить от них память с помощью метода `Dispose`, либо вы можете использовать оператор `using` для закрытия и освобождение памяти от объекта. 

**Примечание**: Открытые объекты должны быть закрыты. Если вы используете метод `Open` без оператора Using, то для открытого объекта необходимо вызвать метод `Close` или `Cancel`. Если не закрыть объект, это приведет к нарушению доступа объекта для чтения и дальнейшей нестабильной работе приложения. Если вам нужно работать с одним объектом, использование методов `Open` и `Close` может сократить количество строк кода, которые в противном случае пришлось бы писать, по сравнению с работой с менеджером транзакций. Тем не менее, использование транзакций предпочтительнее для открытия и закрытия объектов. 

**Важно**: При использовании транзакций не следует использовать методы `Open` и `Close`, так как объекты могут открыться и/или закрыться менеджером транзакций не корректно, что может привести к нестабильной работе AutoCAD. Вместо этого используйте метод StartOpenCloseTransation для создания объекта OpenCloseTransaction, который позволяет безопасно работать с методами Open и Close. 

**Примечание**: в AutoCAD и nanoCAD .NET API методы `Open` и `Close` помечены как устаревшие (Obsolete), вместо них рекомендуется использовать транзакции. Тем не менее их использование всё же возможно, но для некоторых случаев они не реализованы -- например, закрытие таблицы объектов в nanoCAD.

## Запрос объектов (открытие и закрытие вручную)

В примере ниже показано, как вручную открыть и закрыть объекты без использования транзакции и метода GetObject. 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("OpenCloseObjectId")]
public static void OpenCloseObjectId()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Open the Block table for read
    BlockTable acBlkTbl = null;

    try
    {
        acBlkTbl = acCurDb.BlockTableId.Open(OpenMode.ForRead) as BlockTable;

        // Open the Block table record Model space for read
        BlockTableRecord acBlkTblRec = null;

        try
        {
            acBlkTblRec = acBlkTbl[BlockTableRecord.ModelSpace].Open(OpenMode.ForRead) as BlockTableRecord;

            // Step through the Block table record
            foreach (ObjectId acObjId in acBlkTblRec)
            {
                acDoc.Editor.WriteMessage("\nDXF name: " + acObjId.ObjectClass.DxfName);
                acDoc.Editor.WriteMessage("\nObjectID: " + acObjId.ToString());
                acDoc.Editor.WriteMessage("\nHandle: " + acObjId.Handle.ToString());
                acDoc.Editor.WriteMessage("\n");
            }
        }
        catch (Autodesk.AutoCAD.Runtime.Exception es)
        {
            System.Windows.Forms.MessageBox.Show(es.Message);
        }
        finally
        {
            // Close the Block table
            if (!acBlkTblRec.ObjectId.IsNull)
            {
                // Close the Block table record
                acBlkTblRec.Close();
                acBlkTblRec.Dispose();
            }
        }
    }
    catch (Autodesk.AutoCAD.Runtime.Exception es)
    {
        System.Windows.Forms.MessageBox.Show(es.Message);
    }
    finally
    {
        // Close the Block table
        if (!acBlkTbl.ObjectId.IsNull)
        {
            acBlkTbl.Close();
            acBlkTbl.Dispose();
        }
    }
}
```

## Запрос объектов (использование конструкции using)

Пример ниже использует конструкцию using, чтобы избежать закрытия и освобождения ресурсов от объектов после их использования: 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("OpenCloseObjectIdWithUsing")]
public static void OpenCloseObjectIdWithUsing()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Open the Block table for read
    using (BlockTable acBlkTbl = acCurDb.BlockTableId.Open(OpenMode.ForRead) as BlockTable)
    {
        // Open the Block table record Model space for read
        using (BlockTableRecord acBlkTblRec = acBlkTbl[BlockTableRecord.ModelSpace].Open(OpenMode.ForRead)
                                                as BlockTableRecord)
        {
            // Step through the Block table record
            foreach (ObjectId acObjId in acBlkTblRec)
            {
                acDoc.Editor.WriteMessage("\nDXF name: " + acObjId.ObjectClass.DxfName);
                acDoc.Editor.WriteMessage("\nObjectID: " + acObjId.ToString());
                acDoc.Editor.WriteMessage("\nHandle: " + acObjId.Handle.ToString());
                acDoc.Editor.WriteMessage("\n");
            }

        // Close the Block table record
        }

        // Close the Block table
    }
}
```

## Добавление нового объекта в БД чертежа

Пример ниже показывает, как создать новый объект и добавить его в пространство модели чертежа без использования менеджера транзакций. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("AddNewCircleOpenClose")]
public static void AddNewCircleOpenClose()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Open the Block table for read
    using (BlockTable acBlkTbl = acCurDb.BlockTableId.Open(OpenMode.ForRead) as BlockTable)
    {
        // Open the Block table record Model space for write
        using (BlockTableRecord acBlkTblRec = acBlkTbl[BlockTableRecord.ModelSpace].Open(OpenMode.ForWrite)
                                                as BlockTableRecord)
        {
            // Create a circle with a radius of 3 at 5,5
            using (Circle acCirc = new Circle())
            {
                acCirc.Center = new Point3d(5, 5, 0);
                acCirc.Radius = 3;

                // Add the new object to Model space and the transaction
                acBlkTblRec.AppendEntity(acCirc);

                // Close and dispose the circle object
            }

            // Close the Block table record
        }

        // Close the Block table
    }
}
```
