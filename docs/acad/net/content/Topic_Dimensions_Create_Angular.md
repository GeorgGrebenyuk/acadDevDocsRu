Угловые размеры измеряют угол между двумя линиями или тремя точками. Например, их можно использовать для измерения угла между двумя радиусами окружности. Линия измерения угла образует дугу. Угловые размеры создаются путем создания экземпляров классов `LineAngularDimension2` или `Point3AngularDimension`. 

* LineAngularDimension2. Представляет угловой размер, задаваемый двумя линиями; 
* Point3AngularDimension. Представляет угловой размер, задаваемый тремя точками; 

При создании экземпляра классов LineAngularDimension2 или Point3AngularDimension их конструкторы могут принимать ряд необязательных параметров (с предопределенными значениями). При создании углового размера между двумя линиями (LineAngularDimension2) можно указать следующие параметры: 

* Линия продолжения 1 от начала размерной линии к измеряемому объекту (свойство XLine1Start); 
* Линия продолжения 1 от конца размерной линии к измеряемому объекту (свойство XLine1End); 
* Линия продолжения 2 от начала размерной линии к измеряемому объекту (свойство XLine2Start); 
* Линия продолжения 2 от конца размерной линии к измеряемому объекту (свойство XLine2End); 

При создании углового размера, заданного тремя точками (Point3AngularDimension) можно указать следующие параметры: 

* Точка центра (пересечения измеряемых отрезков), свойство CenterPoint; 
* Линия продолжения от первой точке к измеряемому объекту (свойство XLine1Point); 
* Линия продолжения от второй точке к измеряемому объекту (свойство XLine2Point); 
  Общими для обоих подвидов угловых размеров являются: 
* Точка на дуге, где будет размещен текст размера (свойство ArcPoint); 
* Текст размера (свойство DimensionText); 
* Стиль размера (свойство DimensionStyleName или DimensionStyle); 

В примере ниже создается угловой размер в пространстве модели 

```cs
using Teigha.Runtime;
using HostMgd.ApplicationServices;
using Teigha.DatabaseServices;
using Teigha.Geometry;
[CommandMethod("CreateAngularDimension")]
public static void CreateAngularDimension()
{
    // Get the current database
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
        // Create an angular dimension
        using (LineAngularDimension2 acLinAngDim = new LineAngularDimension2())
        {
            acLinAngDim.XLine1Start = new Point3d(0, 5, 0);
            acLinAngDim.XLine1End = new Point3d(1, 7, 0);
            acLinAngDim.XLine2Start = new Point3d(0, 5, 0);
            acLinAngDim.XLine2End = new Point3d(1, 3, 0);
            acLinAngDim.ArcPoint = new Point3d(3, 5, 0);
            acLinAngDim.DimensionStyle = acCurDb.Dimstyle;
            // Add the new object to Model space and the transaction
            acBlkTblRec.AppendEntity(acLinAngDim);
            acTrans.AddNewlyCreatedDBObject(acLinAngDim, true);
        }
        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```