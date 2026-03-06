# Создание однострочного текста

При использовании однострочного текста каждая отдельная строка текста будет являться отдельным объектом. Чтобы создать однострочный текст, необходимо создать экземпляр класса DBText, а затем добавить его в запись таблицы блоков, представляющую пространство модели или листа. При создании нового экземпляра объекта DBText конструктору не передаются никакие параметры, информация о текстовой строке, её стиле, положении задается с помощью свойств класса.
В примере ниже создается однострочный текст в пространстве модели в точке (2, 2, 0), с высотой 0.5 и текстовой строкой "Hello, AutoCAD!" 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("CreateText")]
public static void CreateText()
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

        // Create a single-line text object
        using (DBText acText = new DBText())
        {
            acText.Position = new Point3d(2, 2, 0);
            acText.Height = 0.5;
            acText.TextString = "Hello, AutoCAD!";

            acBlkTblRec.AppendEntity(acText);
            acTrans.AddNewlyCreatedDBObject(acText, true);
        }

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```