# Создание областей

Как и остальные объекты, области создаются путем создания экземпляра класса Region и последующего добавления его к объекту BlockTableRecord. Прежде чем добавить область к объекту BlockTableRecord, необходимо сформировать её границу на основе объектов, образующих замкнутый контур. Статический метод `Region.CreateFromCurves` создает область из каждого замкнутого контура, образованного входным массивом объектов. Метод `CreateFromCurves` возвращает объект `DBObjectCollection` (одну или несколько областей, каждую из которых необходимо добавить в целевой BlockTableRecord). 

AutoCAD преобразует замкнутые 2D и плоские 3D полилинии в отдельные области, а затем преобразует полилинии, линии и кривые, образующие замкнутые плоские контуры. Если более двух кривых имеют общую конечную точку, результирующий регион может иметь разные варианты: из-за этого с помощью метода CreateFromCurves может быть создано несколько областей. 

## Создание простой области

Код ниже формирует область из окружности 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("AddRegion")]
public static void AddRegion()
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

        // Create an in memory circle
        using (Circle acCirc = new Circle())
        {
            acCirc.Center = new Point3d(2, 2, 0);
            acCirc.Radius = 5;

            // Adds the circle to an object array
            DBObjectCollection acDBObjColl = new DBObjectCollection();
            acDBObjColl.Add(acCirc);

            // Calculate the regions based on each closed loop
            DBObjectCollection myRegionColl = new DBObjectCollection();
            myRegionColl = Region.CreateFromCurves(acDBObjColl);
            Region acRegion = myRegionColl[0] as Region;

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acRegion);
            acTrans.AddNewlyCreatedDBObject(acRegion, true);

            // Dispose of the in memory circle not appended to the database
        }

        // Save the new object to the database
        acTrans.Commit();
    }
}
```
