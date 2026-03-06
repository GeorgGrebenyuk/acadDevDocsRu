# Создание многострочного текста

Для создания многострочного текста сперва необходимо создать объект класса MText (конструктор MText не принимает никаких параметров), далее с помощью полей и методов класса задать текстовую строку, точку вставки и иные параметры. В конце созданный объект необходимо добавить в целевой блок по аналогии с прочими графическими объектами.
В примере ниже создается экземпляр многострочного текста в пространстве модели в точке (2, 2, 0) и содержимым "This is a text string for the MText object." 
```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("CreateMText")]
public static void CreateMText()
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

        // Create a multiline text object
        using (MText acMText = new MText())
        {
            acMText.Location = new Point3d(2, 2, 0);
            acMText.Width = 4;
            acMText.Contents = "This is a text string for the MText object.";

            acBlkTblRec.AppendEntity(acMText);
            acTrans.AddNewlyCreatedDBObject(acMText, true);
        }

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```