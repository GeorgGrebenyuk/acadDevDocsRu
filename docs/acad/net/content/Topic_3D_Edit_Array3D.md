# Создание 3D массивов

С помощью методов `TransformBy` и `Clone` объекта можно создать трехмерный прямоугольный массив. Помимо указания количества столбцов (по оси X) и строк (по оси Y), как для двумерного прямоугольного массива, вы также указываете количество уровней (по оси Z). 

Ниже приведен код, где создается прямоугольный массив из 4 строк и столбцов и 3 уровней, где единицей массива является плоская окружность. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
static Point2d PolarPoints(Point2d pPt, double dAng, double dDist)
{
    return new Point2d(pPt.X + dDist * Math.Cos(dAng),
                       pPt.Y + dDist * Math.Sin(dAng));
}
 
[CommandMethod("CreateRectangular3DArray")]
public static void CreateRectangular3DArray()
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

        // Create a circle that is at 2,2 with a radius of 0.5
        using (Circle acCirc = new Circle())
        {
            acCirc.Center = new Point3d(2, 2, 0);
            acCirc.Radius = 0.5;

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acCirc);
            acTrans.AddNewlyCreatedDBObject(acCirc, true);

            // Create a rectangular array with 4 rows, 4 columns, and 3 levels
            int nRows = 4;
            int nColumns = 4;
            int nLevels = 3;

            // Set the row, column, and level offsets along with the base array angle
            double dRowOffset = 1;
            double dColumnOffset = 1;
            double dLevelsOffset = 4;
            double dArrayAng = 0;

            // Get the angle from X for the current UCS 
            Matrix3d curUCSMatrix = acDoc.Editor.CurrentUserCoordinateSystem;
            CoordinateSystem3d curUCS = curUCSMatrix.CoordinateSystem3d;
            Vector2d acVec2dAng = new Vector2d(curUCS.Xaxis.X,
                                               curUCS.Xaxis.Y);

            // If the UCS is rotated, adjust the array angle accordingly
            dArrayAng = dArrayAng + acVec2dAng.Angle;

            // Use the upper-left corner of the objects extents for the array base point
            Extents3d acExts = acCirc.Bounds.GetValueOrDefault();
            Point2d acPt2dArrayBase = new Point2d(acExts.MinPoint.X,
                                                  acExts.MaxPoint.Y);

            // Track the objects created for each column
            DBObjectCollection acDBObjCollCols = new DBObjectCollection();
            acDBObjCollCols.Add(acCirc);

            // Create the number of objects for the first column
            int nColumnsCount = 1;
            while (nColumns > nColumnsCount)
            {
                Entity acEntClone = acCirc.Clone() as Entity;
                acDBObjCollCols.Add(acEntClone);

                // Caclucate the new point for the copied object (move)
                Point2d acPt2dTo = PolarPoints(acPt2dArrayBase,
                                               dArrayAng,
                                               dColumnOffset * nColumnsCount);

                Vector2d acVec2d = acPt2dArrayBase.GetVectorTo(acPt2dTo);
                Vector3d acVec3d = new Vector3d(acVec2d.X, acVec2d.Y, 0);
                acEntClone.TransformBy(Matrix3d.Displacement(acVec3d));

                acBlkTblRec.AppendEntity(acEntClone);
                acTrans.AddNewlyCreatedDBObject(acEntClone, true);

                nColumnsCount = nColumnsCount + 1;
            }

            // Set a value in radians for 90 degrees
            double dAng = 1.5708;

            // Track the objects created for each row and column
            DBObjectCollection acDBObjCollLvls = new DBObjectCollection();

            foreach (DBObject acObj in acDBObjCollCols)
            {
                acDBObjCollLvls.Add(acObj);
            }

            // Create the number of objects for each row
            foreach (Entity acEnt in acDBObjCollCols)
            {
                int nRowsCount = 1;

                while (nRows > nRowsCount)
                {
                    Entity acEntClone = acEnt.Clone() as Entity;
                    acDBObjCollLvls.Add(acEntClone);

                    // Caclucate the new point for the copied object (move)
                    Point2d acPt2dTo = PolarPoints(acPt2dArrayBase,
                                                   dArrayAng + dAng,
                                                   dRowOffset * nRowsCount);

                    Vector2d acVec2d = acPt2dArrayBase.GetVectorTo(acPt2dTo);
                    Vector3d acVec3d = new Vector3d(acVec2d.X, acVec2d.Y, 0);
                    acEntClone.TransformBy(Matrix3d.Displacement(acVec3d));

                    acBlkTblRec.AppendEntity(acEntClone);
                    acTrans.AddNewlyCreatedDBObject(acEntClone, true);

                    nRowsCount = nRowsCount + 1;
                }
            }

            // Create the number of levels for a 3D array
            foreach (Entity acEnt in acDBObjCollLvls)
            {
                int nLvlsCount = 1;

                while (nLevels > nLvlsCount)
                {
                    Entity acEntClone = acEnt.Clone() as Entity;

                    Vector3d acVec3d = new Vector3d(0, 0, dLevelsOffset * nLvlsCount);
                    acEntClone.TransformBy(Matrix3d.Displacement(acVec3d));

                    acBlkTblRec.AppendEntity(acEntClone);
                    acTrans.AddNewlyCreatedDBObject(acEntClone, true);

                    nLvlsCount = nLvlsCount + 1;
                }
            }
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```
