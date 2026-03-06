# Создание слоя

Вы можете создавать новые слои и назначать им цвет, тип линии и прочие свойства. Каждый из слоев отображается в диалоговое окне "Слои". Имя слоя подчиняется правилам для неграфических элементов (см. [статью](\Topic_CreateAndEditNcObjects_EditNamedAnd2D_Named_Rename.md)). Пример ниже содержит код, создающий новый слой зеленого цвета и задающий его для окружности 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.Colors;

[CommandMethod("CreateAndAssignALayer")]
public static void CreateAndAssignALayer()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Layer table for read
        LayerTable acLyrTbl;
        acLyrTbl = acTrans.GetObject(acCurDb.LayerTableId,
                                        OpenMode.ForRead) as LayerTable;

        string sLayerName = "Center";

        if (acLyrTbl.Has(sLayerName) == false)
        {
            using (LayerTableRecord acLyrTblRec = new LayerTableRecord())
            {
                // Assign the layer the ACI color 3 and a name
                acLyrTblRec.Color = Color.FromColorIndex(ColorMethod.ByAci, 3);
                acLyrTblRec.Name = sLayerName;

                // Upgrade the Layer table for write
                acTrans.GetObject(acCurDb.LayerTableId, OpenMode.ForWrite);

                // Append the new layer to the Layer table and the transaction
                acLyrTbl.Add(acLyrTblRec);
                acTrans.AddNewlyCreatedDBObject(acLyrTblRec, true);
            }
        }

        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                        OpenMode.ForRead) as BlockTable;

        // Open the Block table record Model space for write
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;

        // Create a circle object
        using (Circle acCirc = new Circle())
        {
            acCirc.Center = new Point3d(2, 2, 0);
            acCirc.Radius = 1;
            acCirc.Layer = sLayerName;

            acBlkTblRec.AppendEntity(acCirc);
            acTrans.AddNewlyCreatedDBObject(acCirc, true);
        }

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
