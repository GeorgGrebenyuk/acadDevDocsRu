Для добавления нового объекта используйте метод Add для коллекций-таблиц или метод SetAt для словарей. Код ниже создает новый слой в таблицу LayerTable: 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
 
[CommandMethod("AddMyLayer")]
public static void AddMyLayer()
{
  // Get the current document and database, and start a transaction
  Document acDoc = Application.DocumentManager.MdiActiveDocument;
  Database acCurDb = acDoc.Database;
 
  using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
  {
      // Returns the layer table for the current database
      LayerTable acLyrTbl;
      acLyrTbl = acTrans.GetObject(acCurDb.LayerTableId,
                                   OpenMode.ForRead) as LayerTable;
 
      // Check to see if MyLayer exists in the Layer table
      if (acLyrTbl.Has("MyLayer") != true)
      {
          // Open the Layer Table for write
          acTrans.GetObject(acCurDb.LayerTableId, OpenMode.ForWrite);
 
          // Create a new layer table record and name the layer "MyLayer"
          using (LayerTableRecord acLyrTblRec = new LayerTableRecord())
          {
              acLyrTblRec.Name = "MyLayer";
 
              // Add the new layer table record to the layer table and the transaction
              acLyrTbl.Add(acLyrTblRec);
              acTrans.AddNewlyCreatedDBObject(acLyrTblRec, true);
          }

          // Commit the changes
          acTrans.Commit();
      }
 
      // Dispose of the transaction
  }
}
```