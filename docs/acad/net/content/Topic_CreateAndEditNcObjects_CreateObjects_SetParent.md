# Определение родительского объекта

Графические объекты добавляются к целевому блоку BlockTableRecord (элементу таблицы BlockTable), например, пространству модели или листа. Если вы хотите работать в текущем активном пространстве, вы можете получить его ObjectId из текущей базы данных с помощью свойства `CurrentSpaceId` (полученный ObjectId надо будет самостоятельно привести к объекту BlockTableRecord). ObjectId для записей таблицы блоков (BlockTableRecord) пространства модели и листа можно получить из коллекции BlockTable, используя статические свойства класса BlockTableRecord или методы GetBlockModelSpaceId и GetBlockPaperSpaceId класса `SymbolUtilityServices` из пространства имен DatabaseServices. 

## Доступ к пространству модели, пространству листа или текущему Блоку

Приведенный ниже код запрашивает у Пользователя, в каком из пространств (Модели, Листа или Текущем) создать отрезок. При выборе соответствующего варианта в выбранном пространстве создается объект. Запрос ObjectId для нужного BlockTableRecord осуществляется двумя способами. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.EditorInput;
 
[CommandMethod("AccessSpace")]
public static void AccessSpace()
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

        // Open the Block table record for read
        BlockTableRecord acBlkTblRec;

        // Request which table record to open
        PromptKeywordOptions pKeyOpts = new PromptKeywordOptions("");
        pKeyOpts.Message = "\nEnter which space to create the line in ";
        pKeyOpts.Keywords.Add("Model");
        pKeyOpts.Keywords.Add("Paper");
        pKeyOpts.Keywords.Add("Current");
        pKeyOpts.AllowNone = false;
        pKeyOpts.AppendKeywordsToMessage = true;

        PromptResult pKeyRes = acDoc.Editor.GetKeywords(pKeyOpts);

        if (pKeyRes.StringResult == "Model")
        {
            // Get the ObjectID for Model space from the Block table
            acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                            OpenMode.ForWrite) as BlockTableRecord;
        }
        else if (pKeyRes.StringResult == "Paper")
        {
            // Get the ObjectID for Paper space from the Block table
            acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.PaperSpace],
                                            OpenMode.ForWrite) as BlockTableRecord;
        }
        else
        {
            // Get the ObjectID for the current space from the database
            acBlkTblRec = acTrans.GetObject(acCurDb.CurrentSpaceId,
                                            OpenMode.ForWrite) as BlockTableRecord;
        }

        // Create a line that starts at 2,5 and ends at 10,7
        using (Line acLine = new Line(new Point3d(2, 5, 0),
                                new Point3d(10, 7, 0)))
        {
            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acLine);
            acTrans.AddNewlyCreatedDBObject(acLine, true);
        }

        // Save the new line to the database
        acTrans.Commit();
    }
}
```
