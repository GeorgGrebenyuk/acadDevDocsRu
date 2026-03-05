Для задания направления текста имеются 2 специальных метода \-- `IsMirroredInX` и `IsMirroredInY`. Если задать `IsMirroredInX` = true, то текст будет отображен в обратном направлении (справа налево); если задать `IsMirroredInY` = true, то текст будет перевернутым (снизу вверх). На уровне стиля текста регулируются с помощью флагов (FlagBits). 

В примере ниже методу IsMirroredInX задается значение true, чтобы текст отобразился справа-налево 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("BackwardsText")]
public static void BackwardsText()
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

        // Create a single-line text object
        using (DBText acText = new DBText())
        {
            acText.Position = new Point3d(3, 3, 0);
            acText.Height = 0.5;
            acText.TextString = "Hello, World.";

            // Display the text backwards
            acText.IsMirroredInX = true;

            acBlkTblRec.AppendEntity(acText);
            acTrans.AddNewlyCreatedDBObject(acText, true);
        }

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```