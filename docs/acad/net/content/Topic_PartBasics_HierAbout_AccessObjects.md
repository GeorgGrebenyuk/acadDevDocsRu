# Доступ к объектам в иерархии

При работе с объектами в AutoCAD .NET API возможно обращаться к некоторым объектам напрямую или использовать пользовательские переменные для целевого объекта. Например, для вставки в данный чертеж внешней ссылки необходимо последовательно пройтись от Приложения, Документа, Базы данных модели к методу, позволяющему осуществить вставку внешней ссылки. Либо можно сократить часть вызовов, работая с переменной, содержащей информацию о текущей базе данных. 

```cs
string strFName = "C:\\Work\\drawing.dwg";
Autodesk.AutoCAD.DatabaseServices.ObjectId objId;
//Прямой вызов методов
objId = Application.DocumentManager.MdiActiveDocument.Database.AttachXref(strFName, "drawing1");
//Вызов с использованием переменных
Autodesk.AutoCAD.DatabaseServices.Database db = Application.DocumentManager.MdiActiveDocument.Database;
objId = db.AttachXref(strFName, "drawing1");
```

Для получения объектов в пространстве модели (или любого из листов) необходимо обратиться получить запись таблицы блоков (BlockTableRecord) для целевого пространства и пройтись по ней в цикле. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("ListEntities")]
public static void ListEntities()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table record for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                     OpenMode.ForRead) as BlockTable;
        // Open the Block table record Model space for read
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForRead) as BlockTableRecord;
        int nCnt = 0;
        acDoc.Editor.WriteMessage("\\nModel space objects: ");
        // Step through each object in Model space and
        // display the type of object found
        foreach (ObjectId acObjId in acBlkTblRec)
        {
            acDoc.Editor.WriteMessage("\\n" + acObjId.ObjectClass.DxfName);
            nCnt = nCnt + 1;
        }
        // If no objects are found then display a message
        if (nCnt == 0)
        {
            acDoc.Editor.WriteMessage("\\n  No objects found");
        }
        // Dispose of the transaction
    }
}
```
