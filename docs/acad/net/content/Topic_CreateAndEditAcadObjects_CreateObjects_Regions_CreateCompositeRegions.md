# Создание составных областей

Вы можете создавать составные области путем вычитания, объединения или нахождения пересечения областей или трехмерных тел. Затем вы можете выдавливать или вращать полученные области для дальнейшего создания сложных трехмерных тел. Для создания составной области используйте метод `BooleanOperation`. 


**Вычитание областей** При вычитании одной области из другой вызывается метод `BooleanOperation` из первой области. Например, чтобы рассчитать чистую площадь помещения, вызовите метод `BooleanOperation` для внутренней границы помещения, а в качестве вычитаемого используйте контуры, сформированные колоннами, технологическими отверстиями в полу и т.д. -- которые образуют в комплексе вычитаемую область. 


**Объединение областей** Для объединения областей вызовите метод BooleanOperation и используйте константу `BooleanOperationType.BoolUnite` вместо BooleanOperationType.BoolSubtract. Вы можете объединять области в любом порядке. 


**Нахождение пересечения двух областей** Для нахождения пересечения двух областей используйте `BooleanOperationType.BoolIntersect`. Вы можете объединять области в любом порядке для поиска их пересечения. 

## Создание составной области

Ниже приведен код, создающий 2 области для двух окружностей, затем область, сформированная для меньшей окружности, вычитается из большей и формируется область с фигурой "колеса". 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("CreateCompositeRegions")]
public static void CreateCompositeRegions()
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

        // Create two in memory circles
        using (Circle acCirc1 = new Circle())
        {
            acCirc1.Center = new Point3d(4, 4, 0);
            acCirc1.Radius = 2;

            using (Circle acCirc2 = new Circle())
            {
                acCirc2.Center = new Point3d(4, 4, 0);
                acCirc2.Radius = 1;

                // Adds the circle to an object array
                DBObjectCollection acDBObjColl = new DBObjectCollection();
                acDBObjColl.Add(acCirc1);
                acDBObjColl.Add(acCirc2);

                // Calculate the regions based on each closed loop
                DBObjectCollection myRegionColl = new DBObjectCollection();
                myRegionColl = Region.CreateFromCurves(acDBObjColl);
                Region acRegion1 = myRegionColl[0] as Region;
                Region acRegion2 = myRegionColl[1] as Region;

                // Subtract region 1 from region 2
                if (acRegion1.Area > acRegion2.Area)
                {
                    // Subtract the smaller region from the larger one
                    acRegion1.BooleanOperation(BooleanOperationType.BoolSubtract, acRegion2);
                    acRegion2.Dispose();

                    // Add the final region to the database
                    acBlkTblRec.AppendEntity(acRegion1);
                    acTrans.AddNewlyCreatedDBObject(acRegion1, true);
                }
                else
                {
                    // Subtract the smaller region from the larger one
                    acRegion2.BooleanOperation(BooleanOperationType.BoolSubtract, acRegion1);
                    acRegion1.Dispose();

                    // Add the final region to the database
                    acBlkTblRec.AppendEntity(acRegion2);
                    acTrans.AddNewlyCreatedDBObject(acRegion2, true);
                }

                // Dispose of the in memory objects not appended to the database
            }
        }

        // Save the new object to the database
        acTrans.Commit();
    }
}
```
