Чтобы создать новый блок, создайте экземпляр класса `BlockTableRecord` и используйте метод `Add` для добавления его к таблице `BlockTable`. После создания BlockTableRecord используйте свойство Name, чтобы присвоить имя (в дальнейшем при вставке в модель Вхождений блоков у них будет данное имя). 

Затем, после создания `BlockTableRecord`, добавьте к блоку один или несколько объектов с помощью метода `AppendEntity`. После этого вы сможете создать Вхождение блока (`BlockReference`), разместив его в пространстве модели, или на любом из листов (в соответствующем листе `BlockTableRecord`). Вы также можете создать блок, используя метод `WBlock` для сохранения набора объектов в отдельный файл чертежа, который затем вставить в данный в виде внешней ссылки или определения блока. 

В примере ниже создается новое определение блока с именем "CircleBlock", если оно ещё не существует, в определение блока добавляется окружность. 

```cs
using Teigha.Runtime;
using HostMgd.ApplicationServices;
using Teigha.DatabaseServices;
using Teigha.Geometry;
[CommandMethod("CreatingABlock")]
public void CreatingABlock()
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
                }
            }
        }
        // Save the new object to the database
        acTrans.Commit();
        // Dispose of the transaction
    }
}
```