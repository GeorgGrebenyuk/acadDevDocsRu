# Редактирование трехмерных солидов

После создания твердого тела (солида) можно создавать более сложные фигуры, комбинируя несколько солидов: производя булевые операции объединения, вычитания, пересечения тел. Для выполнения этих комбинаций используйте метод BooleanOperation. Метод CheckInterference позволяет определить, пересекаются ли два твердых тела. Также можно находить сечения тел с помощью метода GetSection и разрещать тела на 2 части используя метод Slice. 

## Поиск пересечения двух тел

В примере ниже создаются параллелепипед и цилиндр. Затем создается копия цинидра и находится объём пересечения его с параллепипедом, новое тело добавляется в модель с красным цветом. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("FindInterferenceBetweenSolids")]
public static void FindInterferenceBetweenSolids()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

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

        // Create a 3D solid box
        using (Solid3d acSol3DBox = new Solid3d())
        {
            acSol3DBox.CreateBox(5, 7, 10);
            acSol3DBox.ColorIndex = 7;

            // Position the center of the 3D solid at (5,5,0) 
            acSol3DBox.TransformBy(Matrix3d.Displacement(new Point3d(5, 5, 0) -
                                                            Point3d.Origin));

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acSol3DBox);
            acTrans.AddNewlyCreatedDBObject(acSol3DBox, true);

            // Create a 3D solid cylinder
            // 3D solids are created at (0,0,0) so there is no need to move it
            using (Solid3d acSol3DCyl = new Solid3d())
            {
                acSol3DCyl.CreateFrustum(20, 5, 5, 5);
                acSol3DCyl.ColorIndex = 4;

                // Add the new object to the block table record and the transaction
                acBlkTblRec.AppendEntity(acSol3DCyl);
                acTrans.AddNewlyCreatedDBObject(acSol3DCyl, true);

                // Create a 3D solid from the interference of the box and cylinder
                Solid3d acSol3DCopy = acSol3DCyl.Clone() as Solid3d;

                // Check to see if the 3D solids overlap
                if (acSol3DCopy.CheckInterference(acSol3DBox) == true)
                {
                    acSol3DCopy.BooleanOperation(BooleanOperationType.BoolIntersect,
                                                    acSol3DBox.Clone() as Solid3d);

                    acSol3DCopy.ColorIndex = 1;
                }

                // Add the new object to the block table record and the transaction
                acBlkTblRec.AppendEntity(acSol3DCopy);
                acTrans.AddNewlyCreatedDBObject(acSol3DCopy, true);
            }
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```

## Разрезание солида на 2 солида

В примере ниже создается солид в виде параллепипеда, затем он разрезается на 2 солида плоскостью, заданной тремя точками, а исходный солид удаляется. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("SliceABox")]
public static void SliceABox()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

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

        // Create a 3D solid box
        using (Solid3d acSol3D = new Solid3d())
        {
            acSol3D.CreateBox(5, 7, 10);
            acSol3D.ColorIndex = 7;

            // Position the center of the 3D solid at (5,5,0) 
            acSol3D.TransformBy(Matrix3d.Displacement(new Point3d(5, 5, 0) -
                                                        Point3d.Origin));

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acSol3D);
            acTrans.AddNewlyCreatedDBObject(acSol3D, true);

            // Define the mirror plane
            Plane acPlane = new Plane(new Point3d(1.5, 7.5, 0),
                                        new Point3d(1.5, 7.5, 10),
                                        new Point3d(8.5, 2.5, 10));

            Solid3d acSol3DSlice = acSol3D.Slice(acPlane, true);
            acSol3DSlice.ColorIndex = 1;

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acSol3DSlice);
            acTrans.AddNewlyCreatedDBObject(acSol3DSlice, true);
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```
