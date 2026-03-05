Операция разбивки (расчленения) объекта с помощью функции `Explode` преобразует его в составные части при том условии, если в классе объекта реализована данная процедура (например, разбить Вхождение блока можно, а отдельную 3D-грань -- нельзя). Функция возвращает объект `DBObjectCollection`, в котором содержатся все полученные составные объекты. Например, разбивка полилинии может вернуть несколько отрезков и дуг. 

Если разбивается Вхождение блока, возвращаемая коллекция объектов содержит графические объекты, которые определяют Блок. После разбиения объекта исходный объект остается неизменным. Если вы хотите, чтобы возвращаемые объекты заменили исходный объект, исходный объект необходимо удалить, а затем добавить возвращаемые объекты в целевую запись таблицы блоков. 

## Разбивка полилинии

Код ниже создает простую плоскую полилинию из прямых сегментов, а затем разбивает её на простые объекты. После того, как полилиния была разбита, она уничтожается (не добавляется в модель), а все составлявшие её объекты добавляются к пространству Модели. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("ExplodeObject")]
public static void ExplodeObject()
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
            acPoly.AddVertexAt(0, new Point2d(1, 1), 0, 0, 0);
            acPoly.AddVertexAt(1, new Point2d(1, 2), 0, 0, 0);
            acPoly.AddVertexAt(2, new Point2d(2, 2), 0, 0, 0);
            acPoly.AddVertexAt(3, new Point2d(3, 2), 0, 0, 0);
            acPoly.AddVertexAt(4, new Point2d(4, 4), 0, 0, 0);
            acPoly.AddVertexAt(5, new Point2d(4, 1), 0, 0, 0);

            // Sets the bulge at index 3
            acPoly.SetBulgeAt(3, -0.5);

            // Explodes the polyline
            DBObjectCollection acDBObjColl = new DBObjectCollection();
            acPoly.Explode(acDBObjColl);

            foreach (Entity acEnt in acDBObjColl)
            {
                // Add the new object to the block table record and the transaction
                acBlkTblRec.AppendEntity(acEnt);
                acTrans.AddNewlyCreatedDBObject(acEnt, true);
            }

            // Dispose of the in memory polyline
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```