# Запрос точки

Метод `GetPoint `позволяет указать точку в пространстве чертежа. Настройки PromptPointOptions позволяют контролировать вводимое значение. Свойства `UseBasePoint`и `BasePoint `определяют, будет ли строится пунктирная линия от UseBasePoint к BasePoint. Свойство `Keywords` позволяет определить ключевые слова (см. следующую статью "Запрос ключевых слов", которые можно вводить в командной строке в дополнение к указанию точки. 

Пример ниже показывает, как у Пользователя запрашиваются 2 точки, затем по ним рисуется отрезок 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.Runtime;

[CommandMethod("GetPointsFromUser")]
public static void GetPointsFromUser()
{
    // Get the current database and start the Transaction Manager
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    PromptPointResult pPtRes;
    PromptPointOptions pPtOpts = new PromptPointOptions("");

    // Prompt for the start point
    pPtOpts.Message = "\nEnter the start point of the line: ";
    pPtRes = acDoc.Editor.GetPoint(pPtOpts);
    Point3d ptStart = pPtRes.Value;

    // Exit if the user presses ESC or cancels the command
    if (pPtRes.Status == PromptStatus.Cancel) return;

    // Prompt for the end point
    pPtOpts.Message = "\nEnter the end point of the line: ";
    pPtOpts.UseBasePoint = true;
    pPtOpts.BasePoint = ptStart;
    pPtRes = acDoc.Editor.GetPoint(pPtOpts);
    Point3d ptEnd = pPtRes.Value;

    if (pPtRes.Status == PromptStatus.Cancel) return;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        BlockTable acBlkTbl;
        BlockTableRecord acBlkTblRec;

        // Open Model space for write
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                        OpenMode.ForRead) as BlockTable;

        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;

        // Define the new line
        using (Line acLine = new Line(ptStart, ptEnd))
        {
            // Add the line to the drawing
            acBlkTblRec.AppendEntity(acLine);
            acTrans.AddNewlyCreatedDBObject(acLine, true);
        }

        // Zoom to the extents or limits of the drawing
        acDoc.SendStringToExecute("._zoom _all ", true, false, false);

        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
