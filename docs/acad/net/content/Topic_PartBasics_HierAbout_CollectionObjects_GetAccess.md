Как видно из таблицы в родительском разделе, почти все коллекции получаются из данных, хранящихся на уровне Document или Database. К примеру, рассмотрим, как получить коллекцию слоев LayerTable чертежа: 

```cs
// Get the current document and start the Transaction Manager
Database acCurDb = Application.DocumentManager.MdiActiveDocument.Database;
using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
{
    // This example returns the layer table for the current database
    LayerTable acLyrTbl;
    acLyrTbl = acTrans.GetObject(acCurDb.LayerTableId,
                                 OpenMode.ForRead) as LayerTable;
 
     // Dispose of the transaction
}
```