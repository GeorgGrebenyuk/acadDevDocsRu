# Удаление внешней ссылки

Вы можете отсоединить одну или несколько внешних ссылок, удалив все их экземпляры (вхождения) из чертежа. Отсоединение внешней ссылки приводит к удалению из чертежа всех связанных с ссылкой ресурсов. 

Для отсоединения внешней ссылки используйте метод `DetachXref`. Отсоединить вложенную внешнюю ссылку невозможно (только из-под Database вложенного чертежа). 

В примере ниже создается временный файл чертежа, в котором присутствует одна окружность и сохраняется в папку "C:\\Temp". Далее он добавляется в качестве внешней ссылки в данный чертеж, выводится информационное окно, после чего ссылка на данный файл удаляется. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("DetachingExternalReference")]
public void DetachingExternalReference()
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
        Application.ShowAlertDialog("The external reference is attached.");
        acCurDb.DetachXref(acXrefId);//тут может быть ошибка eXRefDependent
        Application.ShowAlertDialog("The external reference is detached.");
        // Save the new objects to the database
        acTrans.Commit();
        // Dispose of the transaction
    }
}
```

**Примечание**: в некоторых случаях в nanoCAD данный метод DetachXref может не сработать, возвращая ошибку eXRefDependent.
