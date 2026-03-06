# Удаление объектов

С помощью метода Erase можно удалять графические и неграфические объекты. 
<b>Внимание</b>: Хотя многие неграфические объекты, такие как таблица слоев (LayerTable) и записи таблицы блоков (BlockTableRecord), имеют метод Erase, его не следует вызывать. Если вызвать Erase для одного из этих объектов, произойдет ошибка. Ниже приведен пример создания и удаления полилинии 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("EraseObject")]
public static void EraseObject()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

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

        // Create a lightweight polyline
        using (Polyline acPoly = new Polyline())
        {
            acPoly.AddVertexAt(0, new Point2d(2, 4), 0, 0, 0);
            acPoly.AddVertexAt(1, new Point2d(4, 2), 0, 0, 0);
            acPoly.AddVertexAt(2, new Point2d(6, 4), 0, 0, 0);

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acPoly);
            acTrans.AddNewlyCreatedDBObject(acPoly, true);

            // Update the display and display an alert message
            acDoc.Editor.Regen();
            Application.ShowAlertDialog("Erase the newly added polyline.");

            // Erase the polyline from the drawing
            acPoly.Erase(true);
        }

        // Save the new object to the database
        acTrans.Commit();
    }
}
```
