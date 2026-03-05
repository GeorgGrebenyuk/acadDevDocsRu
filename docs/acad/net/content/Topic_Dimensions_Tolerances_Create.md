Геометрический допуск создается путем создания экземпляра класса FeatureControlFrame. У класса имеется конструктор без параметров и со всеми возможными параметрами, позже их можно отредактировать через свойства класса:

- Text - Текстовая строка, содержащая символ допуска;

- Location - Точка вставки;

- Normal - Вектор нормали;

- Direction - Вектор направления;

В примере ниже создается допуск в пространстве модели 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("CreateGeometricTolerance")]
public static void CreateGeometricTolerance()
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

        // Create the Geometric Tolerance (Feature Control Frame)
        using (FeatureControlFrame acFcf = new FeatureControlFrame())
        {
            acFcf.Text = "{\\Fgdt;j}%%v{\\Fgdt;n}0.001%%v%%v%%v%%v";
            acFcf.Location = new Point3d(5, 5, 0);

            // Add the new object to Model space and the transaction
            acBlkTblRec.AppendEntity(acFcf);
            acTrans.AddNewlyCreatedDBObject(acFcf, true);
        }

        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
