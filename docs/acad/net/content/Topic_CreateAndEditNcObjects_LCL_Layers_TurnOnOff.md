Процедура РЕГЕН распространяется на объекты на отключенных слоях, но они не отображаются пользователю и не выводятся на печать. Отключение слоя позволяет избежать принудительной перерисовки чертежа при разморозке слоя. 

При включении слоя, nanoCAD запускает отрисовку объектов на данном слое. Для управления видимостью слоя (описываемого классом LayerTableRecord) используйте свойство IsOff. Если ввести значение true, то слой будет выключен; если false - то включен. 

Пример ниже содержит создание нового слоя "ABC" и его отключение, затем создание окружности на данном слое, которую не будет видно, пока слой не будет вновь включен. 

```cs
using Teigha.Runtime;
using HostMgd.ApplicationServices;
using Teigha.DatabaseServices;
using Teigha.Geometry;
[CommandMethod("TurnLayerOff")]
public static void TurnLayerOff()
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
        string sLayerName = "ABC";
        if (acLyrTbl.Has(sLayerName) == false)
        {
            using (LayerTableRecord acLyrTblRec = new LayerTableRecord())
            {
                // Assign the layer a name
                acLyrTblRec.Name = sLayerName;
                // Turn the layer off
                acLyrTblRec.IsOff = true;
                // Upgrade the Layer table for write
                acTrans.GetObject(acCurDb.LayerTableId, OpenMode.ForWrite);
                // Append the new layer to the Layer table and the transaction
                acLyrTbl.Add(acLyrTblRec);
                acTrans.AddNewlyCreatedDBObject(acLyrTblRec, true);
            }
        }
        else
        {
            LayerTableRecord acLyrTblRec = acTrans.GetObject(acLyrTbl[sLayerName],
                                            OpenMode.ForWrite) as LayerTableRecord;
            // Turn the layer off
            acLyrTblRec.IsOff = true;
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