# Добавление внешних ссылок

Вы можете создать столько копий внешних ссылок на один и тот же, либо различные файлы, сколько требуется. У каждого вставленного чертежа можно задать уникальное положение, поворот и масштаб. Вы также можете управлять видимостью слоев вставленных ссылками чертежей и типами линий. 

Для загрузки чертежа в качестве внешней ссылки используйте метод `AttachXref`, он требует указания пути к чертежу, а также имени внешней ссылки в качестве второго аргумента. Метод вернёт `ObjectId` на `BlockTableRecord` (блок, которым станет внешняя ссылка). Далее необходимо вставить блок в модель, подав в конструктор BlockReference вторым аргументом возвращённый идентификатор блока и указав точку и параметры вставки. В примере ниже создается временный файл чертежа, в котором присутствует одна окружность и сохраняется в папку "C:\\Temp". Далее он добавляется в качестве внешней ссылки в данный чертеж. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("AttachingExternalReference")]
public void AttachingExternalReference()
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
        ObjectId acXrefId = acCurDb.AttachXref(tmpDwg, "Test Srawing");
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
        }
        // Save the new objects to the database
        acTrans.Commit();
        // Dispose of the transaction
    }
}
```
