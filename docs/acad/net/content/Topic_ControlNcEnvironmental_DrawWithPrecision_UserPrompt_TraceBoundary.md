Отдельного внимания заслуживает метод `TraceBoundary` класса Editor, позволяющий получить полилинию, внутри некоторого контура образованного одним или несколькими объектами. Метод возвращает набор полилиний в виде DBObjectCollection, объекты которых необходимо самостоятельно добавить в модель. Пример вызова данного метода приведен в коде ниже 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("InitBoundary")]
public void InitBoundary()
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
        var point = acDoc.Editor.GetPoint("Укажите точку внутри контура");
        if (point.Status != HostMgd.EditorInput.PromptStatus.OK) return;
        var plines = acDoc.Editor.TraceBoundary(point.Value, false);
        if (plines == null || plines.Count \< 1) return;
        foreach (DBObject createdPline in plines)
        {
            Polyline? boundaryAsPline = createdPline as Polyline;
            if (boundaryAsPline == null) continue;
            acBlkTblRec.AppendEntity(boundaryAsPline);
            acTrans.AddNewlyCreatedDBObject(boundaryAsPline, true);
        }
        acTrans.Commit();
    }
}
```