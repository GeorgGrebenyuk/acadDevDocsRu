# Удаление слоя

Слой возможно удалить, если он не задан в качестве текущего, не содержит объектов, не является системным ("0", "DEFPOINTS"), не пришёл из внешних ссылок, не является одним из слоёв, где лежат определения блоков. 

Чтобы удалить слой, используйте метод `Erase`. Рекомендуется использовать функцию `Purge`, чтобы убедиться, что слой можно удалить, а также проверить, что это не системный или текущий слой. 

В примере ниже удаляется слой "ABC", если он имеется в чертеже. Транзакция закрывается в теле функции, поскольку ожидается удаление только одного объекта. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("EraseLayer")]
public static void EraseLayer()
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
        if (acLyrTbl.Has(sLayerName) == true)
        {
            // Check to see if it is safe to erase layer
            ObjectIdCollection acObjIdColl = new ObjectIdCollection();
            acObjIdColl.Add(acLyrTbl[sLayerName]);
            acCurDb.Purge(acObjIdColl);
            if (acObjIdColl.Count \> 0)
            {
                LayerTableRecord acLyrTblRec;
                acLyrTblRec = acTrans.GetObject(acObjIdColl[0],
                                                OpenMode.ForWrite) as LayerTableRecord;
                try
                {
                    // Erase the unreferenced layer
                    acLyrTblRec.Erase(true);
                    // Save the changes and dispose of the transaction
                    acTrans.Commit();
                }
                catch (Autodesk.AutoCAD.Runtime.Exception Ex)
                {
                    // Layer could not be deleted
                    Application.ShowAlertDialog("Error:\\n" + Ex.Message);
                }
            }
        }
    }
}
```
