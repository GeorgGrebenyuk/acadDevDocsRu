Вы можете создать полярный или прямоугольный массив для объекта или группы объектов. 

Массивы объектов создаются не с помощью специального набора функций (как в пользовательском интерфейсе), а путем комбинации операций копирования объектов, а затем использования матрицы преобразования для поворота и перемещения скопированного объекта. После создания каждой копии ее необходимо самостоятельно добавить в базу данных чертежа (и таблицу записи целевого блока). 

Ниже приведена основная логика для каждого из типов массивов. 

## Полярный массив

Скопируйте объект, который необходимо расположить в массиве, и переместите в позицию, соответствующую текущему полярному углу. Код ниже формирует полярный массив на основе окружности, в массиве 4 элемента, заполнение на 180 градусов относительно базовой точки (4, 4, 0) 

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
 
[CommandMethod("PolarArrayObject")]
public static void PolarArrayObject()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

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

        // Create a circle that is at 2,2 with a radius of 1
        using (Circle acCirc = new Circle())
        {
            acCirc.Center = new Point3d(2, 2, 0);
            acCirc.Radius = 1;

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acCirc);
            acTrans.AddNewlyCreatedDBObject(acCirc, true);

            // Create a 4 object polar array that goes a 180
            int nCount = 1;

            // Set a value in radians for 60 degrees
            double dAng = 1.0472;

            // Use (4,4,0) as the base point for the array
            Point2d acPt2dArrayBase = new Point2d(4, 4);

            while (nCount < 4)
            {
                Entity acEntClone = acCirc.Clone() as Entity;

                Extents3d acExts;
                Point2d acPtObjBase;

                // Typically the upper-left corner of an object's extents is used
                // for the point on the object to be arrayed unless it is
                // an object like a circle.
                Circle acCircArrObj = acEntClone as Circle;

                if (acCircArrObj != null)
                {
                    acPtObjBase = new Point2d(acCircArrObj.Center.X,
                                                acCircArrObj.Center.Y);
                }
                else
                {
                    acExts = acEntClone.Bounds.GetValueOrDefault();
                    acPtObjBase = new Point2d(acExts.MinPoint.X,
                                                acExts.MaxPoint.Y);
                }

                double dDist = acPt2dArrayBase.GetDistanceTo(acPtObjBase);
                double dAngFromX = acPt2dArrayBase.GetVectorTo(acPtObjBase).Angle;

                Point2d acPt2dTo = PolarPoints(acPt2dArrayBase,
                                                (nCount * dAng) + dAngFromX,
                                                dDist);

                Vector2d acVec2d = acPtObjBase.GetVectorTo(acPt2dTo);
                Vector3d acVec3d = new Vector3d(acVec2d.X, acVec2d.Y, 0);
                acEntClone.TransformBy(Matrix3d.Displacement(acVec3d));

                /*
                // The following code demonstrates how to rotate each object like
                // the ARRAY command does.
                acExts = acEntClone.Bounds.GetValueOrDefault();
                acPtObjBase = new Point2d(acExts.MinPoint.X,
                                            acExts.MaxPoint.Y);
                
                // Rotate the cloned entity around its upper-left extents point
                Matrix3d curUCSMatrix = acDoc.Editor.CurrentUserCoordinateSystem;
                CoordinateSystem3d curUCS = curUCSMatrix.CoordinateSystem3d;
                acEntClone.TransformBy(Matrix3d.Rotation(nCount * dAng,
                                                            curUCS.Zaxis,
                                                            new Point3d(acPtObjBase.X,
                                                                        acPtObjBase.Y, 0)));
                */

                acBlkTblRec.AppendEntity(acEntClone);
                acTrans.AddNewlyCreatedDBObject(acEntClone, true);

                nCount = nCount + 1;
            }
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```

## Прямоугольный массив

Сперва удобно заполнить одну из строк или столбец массива. Расстояние, на которое копируются объекты, зависит от заданного расстояния между строками и столбцами. После создания первой строки или столбца можно их раскопировать по аналогии. Код ниже формирует прямоугольный массив на основе окружности, состоящий из 5 строк и 5 колонок. 

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
 
[CommandMethod("RectangularArrayObject")]
public static void RectangularArrayObject()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

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

        // Create a circle that is at 2,2 with a radius of 0.5
        using (Circle acCirc = new Circle())
        {
            acCirc.Center = new Point3d(2, 2, 0);
            acCirc.Radius = 0.5;

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acCirc);
            acTrans.AddNewlyCreatedDBObject(acCirc, true);

            // Create a rectangular array with 5 rows and 5 columns
            int nRows = 5;
            int nColumns = 5;

            // Set the row and column offsets along with the base array angle
            double dRowOffset = 1;
            double dColumnOffset = 1;
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
            double dAng = Math.PI / 2;

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
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```