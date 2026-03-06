# Вставка Вхождения блока

Вставить блок в чертеж можно, создав экземпляр класса `BlockReference` и передав ему в конструкторе точку вставки и идентификатор определения блока (`BlockTableRecord.ObjectId`). 

Вы также можете вставить в виде блока какой-либо иной чертеж (сперва получить содержимое его базы данных с помощью метода `ReadDwgFile`, а затем в метод `Insert` текущей базы передать `Database` для другого чертежа). Если вы внесете изменения в исходный чертеж после его вставки, эти изменения не повлияют на вставленный блок. Если вы хотите, чтобы вставленный блок отражал внесенные вами изменения в исходный чертеж, вы можете переопределить блок, повторно вставив измененный чертеж чертеж. 

По умолчанию AutoCAD использует координаты (0, 0, 0) в качестве базовой точки при вставке файла чертежа в виде определения блока. Вы можете изменить базовую точку чертежа, открыв его и установив через метод `SetSystemVariable` новое значение переменной `INSBASE`. AutoCAD будет использовать её значение при следующей вставке чертежа в виде блока. 

Объекты, входящие в состав вхождения блока нельзя считать, это можно сделать только для определения блока, либо разбив данное вхождение блока на составляющие примитивы (метод `Explode`). 

Вы также можете вставлять массивы блоков, используя класс `MInsertBlock`. Этот тип вставляет в чертеж не отдельный блок, как это делает `BlockReference`, а вместо этого вставляет группу из нескольких вхождений блоков. 

В примере ниже создается определение блока с именем "CircleBlock", состоящего из простой окружности, и далее этот блок вставляется в пространство модели в виде Вхождение блока (BlockReference) 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("InsertingABlock")]
public void InsertingABlock()
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
            }
        }

        // Save the new object to the database
        acTrans.Commit();

        // Dispose of the transaction
    }
}
```
