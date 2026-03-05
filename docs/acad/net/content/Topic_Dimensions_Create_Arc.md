Размеры длины дуги измеряют длину вдоль дуги и отображают текст размера с символом дуги, который находится либо выше текста, либо перед ним. Размер длины дуги используются, когда необходимо подсчитать фактическую длину дуги, а не только расстояние между ее начальной и конечной точками. Размер длины дуги создается путем создания экземпляра класса `ArcDimension`. Конструктор класса может принимать либо перегрузку с указанием всех параметров, либо перегрузку без параметров: все параметры задаются через свойства класса после создания экземпляра. 

* Center : точка центра; 
* Линия продолжения от первой точке к измеряемому объекту (свойство XLine1Point); 
* Линия продолжения от второй точке к измеряемому объекту (свойство XLine2Point); 
* Точка на дуге, где будет создан текст (свойство ArcPoint); 
* Текст размера (свойство DimensionText); 
* Стиль размера (свойство DimensionStyleName или DimensionStyle); 

Системная переменная `DIMARCSYM` определяет, отображается ли символ дуги и где он будет размещён относительно текста размера. 

В примере ниже создается размер для длины дуги в пространстве модели 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("CreateArcLengthDimension")]
public static void CreateArcLengthDimension()
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

        // Create an arc length dimension
        using (ArcDimension acArcDim = new ArcDimension(new Point3d(4.5, 1.5, 0),
                                                        new Point3d(8, 4.25, 0),
                                                        new Point3d(0, 2, 0),
                                                        new Point3d(5, 7, 0),
                                                        "<>",
                                                        acCurDb.Dimstyle))
        {

            // Add the new object to Model space and the transaction
            acBlkTblRec.AppendEntity(acArcDim);
            acTrans.AddNewlyCreatedDBObject(acArcDim, true);
        }

        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```