# Переопределение блока

Используйте любой из методов и свойств класса `BlockTableRecord` для переопределения блока. При переопределении блока все ссылки на этот блок (Вхождения блока) на чертеже немедленно обновятся в соответствии с новым определением. 

Переопределение влияет на все существовавшие ранние объекты и будет влиять на новые вхождения блоков. Постоянные атрибуты (constant) полностью заменяются новыми постоянными атрибутами. Переменные атрибуты остаются неизменными, даже если у нового определения блока отсутствуют атрибуты. 

В примере ниже, если в чертеже есть определение блока с именем "CircleBlock", то для всех объектов-окружностей, составляющих блок, увеличивается радиус в 2 раза, после чего с помощью служебного метода RecordGraphicsModified обновляются все вхождения блока, чтобы они изменились вслед за редактированием определения. 

```cs
using Teigha.Runtime;
using HostMgd.ApplicationServices;
using Teigha.DatabaseServices;
using Teigha.Geometry;
[CommandMethod("RedefiningABlock")]
public void RedefiningABlock()
{
    // Get the current database and start a transaction
    Database acCurDb;
    acCurDb = Application.DocumentManager.MdiActiveDocument.Database;
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId, OpenMode.ForRead) as BlockTable;
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
                    // Insert the block into the current space
                    using (BlockReference acBlkRef = new BlockReference(new Point3d(0, 0, 0), acBlkTblRec.Id))
                    {
                        BlockTableRecord acModelSpace;
                        acModelSpace = acTrans.GetObject(acCurDb.CurrentSpaceId, OpenMode.ForWrite) as BlockTableRecord;
                        acModelSpace.AppendEntity(acBlkRef);
                        acTrans.AddNewlyCreatedDBObject(acBlkRef, true);
                        Application.ShowAlertDialog("CircleBlock has been created.");
                    }
                }
            }
        }
        else
        {
            // Redefine the block if it exists
            BlockTableRecord acBlkTblRec =
                acTrans.GetObject(acBlkTbl["CircleBlock"], OpenMode.ForWrite) as BlockTableRecord;
            // Step through each object in the block table record
            foreach (ObjectId objID in acBlkTblRec)
            {
                DBObject dbObj = acTrans.GetObject(objID, OpenMode.ForRead) as DBObject;
                // Revise the circle in the block
                if (dbObj is Circle)
                {
                    Circle acCirc = dbObj as Circle;
                    acTrans.GetObject(objID, OpenMode.ForWrite);
                    acCirc.Radius = acCirc.Radius * 2;
                }
            }
            // Update existing block references
            foreach (ObjectId objID in acBlkTblRec.GetBlockReferenceIds(false, true))
            {
                BlockReference acBlkRef = acTrans.GetObject(objID, OpenMode.ForWrite) as BlockReference;
                acBlkRef.RecordGraphicsModified(true);
            }
            Application.ShowAlertDialog("CircleBlock has been revised.");
        }
        // Save the new object to the database
        acTrans.Commit();
        // Dispose of the transaction
    }
}
```
