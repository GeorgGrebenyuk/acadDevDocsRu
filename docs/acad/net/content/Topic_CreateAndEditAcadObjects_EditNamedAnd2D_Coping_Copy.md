# Копирование объекта

Чтобы скопировать объект, вызовите функцию Clone у копируемого объекта (внимание: копируемый объектдолжен быть в режиме OpenMode.ForWrite). Этот метод создаст новый объект, который является дубликатом исходного объекта. После создания дубликата объекта вы можете внести в него какие-либо изменения перед добавлением в базу данных модели. Если не производить каких-либо изменений, то скопированный объект будет находиться и иметь те же свойства, что и исходный объект.

## Копирование одного объекта

Код ниже содержит пример копирования созданной окружности 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("SingleCopy")]
public static void SingleCopy()
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

        // Create a circle that is at 2,3 with a radius of 4.25
        using (Circle acCirc = new Circle())
        {
            acCirc.Center = new Point3d(2, 3, 0);
            acCirc.Radius = 4.25;

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acCirc);
            acTrans.AddNewlyCreatedDBObject(acCirc, true);

            // Create a copy of the circle and change its radius
            Circle acCircClone = acCirc.Clone() as Circle;
            acCircClone.Radius = 1;

            // Add the cloned circle
            acBlkTblRec.AppendEntity(acCircClone);
            acTrans.AddNewlyCreatedDBObject(acCircClone, true);
        }

        // Save the new object to the database
        acTrans.Commit();
    }
}
```

## Копирование нескольких объектов

Если у вас есть большое количество объектов, которые вы хотите скопировать, вы можете использовать коллекцию `DBObjectCollection`. Код ниже содержит пример её использования

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("MultipleCopy")]
public static void MultipleCopy()
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

                // Add all the objects to clone
                DBObjectCollection acDBObjColl = new DBObjectCollection();
                acDBObjColl.Add(acCirc1);
                acDBObjColl.Add(acCirc2);

                foreach (Entity acEnt in acDBObjColl)
                {
                    Entity acEntClone;
                    acEntClone = acEnt.Clone() as Entity;
                    acEntClone.ColorIndex = 1;

                    // Create a matrix and move each copied entity 15 units
                    acEntClone.TransformBy(Matrix3d.Displacement(new Vector3d(15, 0, 0)));

                    // Add the cloned object
                    acBlkTblRec.AppendEntity(acEntClone);
                    acTrans.AddNewlyCreatedDBObject(acEntClone, true);
                }
            }
        }

        // Save the new object to the database
        acTrans.Commit();
    }
}
```
