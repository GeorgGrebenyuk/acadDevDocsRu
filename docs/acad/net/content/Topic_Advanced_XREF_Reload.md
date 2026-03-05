Для обновления внешних ссылок вызовите метод `ReloadXrefs` у объекта `Database`, передав ему в качестве аргумента `ObjectIdCollection` для идентификаторов определений блоков внешних ссылок (например, тех, что вернет метод `AttachXref`).

В примере ниже создается чертеж с простой графикой, добавляется в качестве внешней ссылки, а потом вызывается метод `AttachXref` для обновления связанной с ним внешней ссылки. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("ReloadingExternalReference")]
public void ReloadingExternalReference()
{
    string tmpDwg = @"C:\Temp\test.dwg";
    using (Database dbTmp = new Database())
    {
        using (Transaction acTrans = dbTmp.TransactionManager.StartTransaction())
        {
            // Open the Block table record for read
            BlockTable acBlkTbl;
            acBlkTbl = acTrans.GetObject(dbTmp.BlockTableId,
                                            OpenMode.ForRead) as BlockTable;
            // Open the Block table record Model space for write
            BlockTableRecord acBlkTblRec;
            acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                            OpenMode.ForWrite) as BlockTableRecord;
            using (Circle acCirc = new Circle(new Point3d(0, 0, 0), Vector3d.ZAxis, 2))
            {
                acBlkTblRec.AppendEntity(acCirc);
                acTrans.AddNewlyCreatedDBObject(acCirc, true);
            }
            acTrans.Commit();
        }
        dbTmp.SaveAs(tmpDwg, DwgVersion.Current);
    }
    // Get the current database and start a transaction
    Database acCurDb;
    acCurDb = Application.DocumentManager.MdiActiveDocument.Database;
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Create a reference to a DWG file
        ObjectId acXrefId = acCurDb.AttachXref(tmpDwg, "Test1");
        // If a valid reference is created then continue
        if (!acXrefId.IsNull)
        {
            // Attach the DWG reference to the current space
            Point3d insPt = new Point3d(1, 1, 0);
            using (BlockReference acBlkRef = new BlockReference(insPt, acXrefId))
            {
                BlockTableRecord acBlkTblRec;
                acBlkTblRec = acTrans.GetObject(acCurDb.CurrentSpaceId, OpenMode.ForWrite) as BlockTableRecord;
                acBlkTblRec.AppendEntity(acBlkRef);
                acTrans.AddNewlyCreatedDBObject(acBlkRef, true);
            }
            Application.ShowAlertDialog("The external reference is attached.");
            using (ObjectIdCollection acXrefIdCol = new ObjectIdCollection())
            {
                acXrefIdCol.Add(acXrefId);
                acCurDb.ReloadXrefs(acXrefIdCol);
            }
            Application.ShowAlertDialog("The external reference is reloaded.");
        }
        // Save the new objects to the database
        acTrans.Commit();
    }
}
```