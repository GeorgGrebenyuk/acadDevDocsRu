# Разбивка блока на элементы

Используйте метод `Explode`, чтобы разбить Вхождение блока на набор примитивов (для удаления или добавления каких либо объектов в него). 

В примере ниже создается определение блока "CircleBlock", состоящее из простой окружности, для него создается Вхождение блока, которое разбивается на набор объектов, каждый из которых добавляется в пространство модели с красным цветом. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("ExplodingABlock")]
public void ExplodingABlock()
{
    // Get the current database and start a transaction
    Database acCurDb;
    acCurDb = Application.DocumentManager.MdiActiveDocument.Database;

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId, OpenMode.ForRead) as BlockTable;

        ObjectId blkRecId = ObjectId.Null;

        if (!acBlkTbl.Has("CircleBlock"))
        {
            using (BlockTableRecord acBlkTblRec = new BlockTableRecord())
            {
                acBlkTblRec.Name = "CircleBlock";

                // Set the insertion point for the block
                acBlkTblRec.Origin = new Point3d(0, 0, 0);

                // Add a circle to the block
                using (Circle acCirc = new Circle())
                {
                    acCirc.Center = new Point3d(0, 0, 0);
                    acCirc.Radius = 2;

                    acBlkTblRec.AppendEntity(acCirc);

                    acTrans.GetObject(acCurDb.BlockTableId, OpenMode.ForWrite);
                    acBlkTbl.Add(acBlkTblRec);
                    acTrans.AddNewlyCreatedDBObject(acBlkTblRec, true);
                }

                blkRecId = acBlkTblRec.Id;
            }
        }
        else
        {
            blkRecId = acBlkTbl["CircleBlock"];
        }

        // Insert the block into the current space
        if (blkRecId != ObjectId.Null)
        {
            using (BlockReference acBlkRef = new BlockReference(new Point3d(0, 0, 0), blkRecId))
            {
                BlockTableRecord acCurSpaceBlkTblRec;
                acCurSpaceBlkTblRec = acTrans.GetObject(acCurDb.CurrentSpaceId, OpenMode.ForWrite) as BlockTableRecord;

                acCurSpaceBlkTblRec.AppendEntity(acBlkRef);
                acTrans.AddNewlyCreatedDBObject(acBlkRef, true);

                using (DBObjectCollection dbObjCol = new DBObjectCollection())
                {
                    acBlkRef.Explode(dbObjCol);

                    foreach (DBObject dbObj in dbObjCol)
                    {
                        Entity acEnt = dbObj as Entity;

                        acCurSpaceBlkTblRec.AppendEntity(acEnt);
                        acTrans.AddNewlyCreatedDBObject(dbObj, true);

                        acEnt = acTrans.GetObject(dbObj.ObjectId, OpenMode.ForWrite) as Entity;

                        acEnt.ColorIndex = 1;
                        Application.ShowAlertDialog("Exploded Object: " + acEnt.GetRXClass().DxfName);
                    }
                }
            }
        }

        // Save the new object to the database
        acTrans.Commit();

        // Dispose of the transaction
    }
}
```
