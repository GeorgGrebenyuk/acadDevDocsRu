Размеры с изломом измеряют радиус объекта и отображают текст размера с символом радиуса перед ним. Вы можете использовать размер с изломом вместо радиального размера в следующих случаях: 

* Центр объекта расположен за пределами листа или находится над областью модели, в которой недостаточно места для размещения радиального размера; 
* Объект имеет большой радиус; 

Размер с изломом создается путем создания экземпляра класса RadialDimensionLarge. При создании экземпляра класса RadialDimensionLarge его конструкторы могут дополнительно принимать некоторый набор параметров, которые также можно задать с помощью свойств класса:

* Center : точка центра; 
* ChordPoint : точка на окружности; 
* OverrideCenter : переопределение точки центра; 
* JogPoint : точка, где рисуется излом; 
* JogAngle : угол линии излома; 
* Текст размера (свойство DimensionText); 
* Стиль размера (свойство DimensionStyleName или DimensionStyle); 

В примере ниже создается размер с изломом 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("CreateJoggedDimension")]
public static void CreateJoggedDimension()
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

        // Create a large radius dimension
        using (RadialDimensionLarge acRadDimLrg = new RadialDimensionLarge())
        {
            acRadDimLrg.Center = new Point3d(-3, -4, 0);
            acRadDimLrg.ChordPoint = new Point3d(2, 7, 0);
            acRadDimLrg.OverrideCenter = new Point3d(0, 2, 0);
            acRadDimLrg.JogPoint = new Point3d(1, 4.5, 0);
            acRadDimLrg.JogAngle = 0.707;
            acRadDimLrg.DimensionStyle = acCurDb.Dimstyle;

            // Add the new object to Model space and the transaction
            acBlkTblRec.AppendEntity(acRadDimLrg);
            acTrans.AddNewlyCreatedDBObject(acRadDimLrg, true);
        }

        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```