Члены объекта коллекции могут быть удалены с помощью метода Erase. Например, следующий код стирает слой MyLayer из объекта LayerTable. Прежде чем стирать слой с чертежа, необходимо убедиться, что его можно безопасно удалить. Чтобы определить, можно ли стирать слой или другой именованный объект, например блок или текстовый стиль, следует использовать метод Purge (на стороне UI). 

```cs

```

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
 
[CommandMethod("RemoveMyLayer")]
public static void RemoveMyLayer()
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
      if (acLyrTbl.Has("MyLayer") == true)
      {
          LayerTableRecord acLyrTblRec;
          acLyrTblRec = acTrans.GetObject(acLyrTbl["MyLayer"],
                                          OpenMode.ForWrite) as LayerTableRecord;
 
          try
          {
              acLyrTblRec.Erase();
              acDoc.Editor.WriteMessage("\n'MyLayer' was erased");
 
              // Commit the changes
              acTrans.Commit();
          }
          catch
          {
              acDoc.Editor.WriteMessage("\n'MyLayer' could not be erased");
          }
      }
      else
      {
          acDoc.Editor.WriteMessage("\n'MyLayer' does not exist");
      }
 
      // Dispose of the transaction
  }
}
```