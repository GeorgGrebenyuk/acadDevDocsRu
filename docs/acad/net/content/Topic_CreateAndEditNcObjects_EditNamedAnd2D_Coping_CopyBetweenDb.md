# Копирование объектов между разными Database

Вы можете копировать объекты между двумя различными базами данных (объектами класса Database). Функция Clone используется для копирования объектов в пределах одной базы данных, а метод `WblockCloneObjects` — для копирования объектов из одной базы данных в другую. Метод `WblockCloneObjects` является членом объекта Database. Метод `WblockCloneObjects` требует следующих параметров: 

* ObjectIdCollection : Перечень идентификаторов копируемых объектов; 
* ObjectId : Идентификатор нового родительского объекта, куда объекты будут копироваться; 
* IdMapping : Сопоставление текущих идентификаторов объектов с их новыми идентификаторами (заполнятся после работы метода WblockCloneObjects); 
* DuplicateRecordCloning : Задаёт правило обработки дублирующихся объектов (в виде enum Teigha.DatabaseServices.DuplicateRecordCloning); 
* deferTranslation : Флаг, отложить ли заполнение IdMapping идентификаторами для новых объектов (по умолчанию false - т.е. заполнить сразу); 
  Код ниже содержит операцию создания двух новых окружностей, затем с помощью метода WblockCloneObjects они копируются в новый чертёж, который создается автоматически на базе стандартного шаблона 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("CopyObjectsBetweenDatabases", CommandFlags.Session)]
public static void CopyObjectsBetweenDatabases()
{
    ObjectIdCollection acObjIdColl = new ObjectIdCollection();

    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Lock the current document
    using (DocumentLock acLckDocCur = acDoc.LockDocument())
    {
        // Start a transaction
        using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
        {
            // Open the Block table record for read
            BlockTable acBlkTbl;
            acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                            OpenMode.ForRead) as BlockTable;

            // Open the Block table record Model space for write
            BlockTableRecord acBlkTblRec;
            acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                            OpenMode.ForWrite) as BlockTableRecord;

            // Create a circle that is at (0,0,0) with a radius of 5
            using (Circle acCirc1 = new Circle())
            {
                acCirc1.Center = new Point3d(0, 0, 0);
                acCirc1.Radius = 5;

                // Add the new object to the block table record and the transaction
                acBlkTblRec.AppendEntity(acCirc1);
                acTrans.AddNewlyCreatedDBObject(acCirc1, true);

                // Create a circle that is at (0,0,0) with a radius of 7
                using (Circle acCirc2 = new Circle())
                {
                    acCirc2.Center = new Point3d(0, 0, 0);
                    acCirc2.Radius = 7;

                    // Add the new object to the block table record and the transaction
                    acBlkTblRec.AppendEntity(acCirc2);
                    acTrans.AddNewlyCreatedDBObject(acCirc2, true);

                    // Add all the objects to copy to the new document
                    acObjIdColl = new ObjectIdCollection();
                    acObjIdColl.Add(acCirc1.ObjectId);
                    acObjIdColl.Add(acCirc2.ObjectId);
                }
            }

            // Save the new objects to the database
            acTrans.Commit();
        }

        // Unlock the document
    }

    // Change the file and path to match a drawing template on your workstation
    string sLocalRoot = Application.GetSystemVariable("LOCALROOTPREFIX") as string;
    string sTemplatePath = sLocalRoot + "Template\\acad.dwt";

    // Create a new drawing to copy the objects to
    DocumentCollection acDocMgr = Application.DocumentManager;
    Document acNewDoc = acDocMgr.Add(sTemplatePath);
    Database acDbNewDoc = acNewDoc.Database;

    // Lock the new document
    using (DocumentLock acLckDoc = acNewDoc.LockDocument())
    {
        // Start a transaction in the new database
        using (Transaction acTrans = acDbNewDoc.TransactionManager.StartTransaction())
        {
            // Open the Block table for read
            BlockTable acBlkTblNewDoc;
            acBlkTblNewDoc = acTrans.GetObject(acDbNewDoc.BlockTableId,
                                                OpenMode.ForRead) as BlockTable;

            // Open the Block table record Model space for read
            BlockTableRecord acBlkTblRecNewDoc;
            acBlkTblRecNewDoc = acTrans.GetObject(acBlkTblNewDoc[BlockTableRecord.ModelSpace],
                                                    OpenMode.ForRead) as BlockTableRecord;

            // Clone the objects to the new database
            IdMapping acIdMap = new IdMapping();
            acCurDb.WblockCloneObjects(acObjIdColl, acBlkTblRecNewDoc.ObjectId, acIdMap,
                                        DuplicateRecordCloning.Ignore, false);

            // Save the copied objects to the database
            acTrans.Commit();
        }

        // Unlock the document
    }

    // Set the new document current
    acDocMgr.MdiActiveDocument = acNewDoc;
}
```
