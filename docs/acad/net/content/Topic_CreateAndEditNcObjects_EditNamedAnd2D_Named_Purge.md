# Удаление несвязанных элементов

Несвязанные именованные объекты можно удалить из базы данных в любое время. Невозможно удалить именованные объекты, на которые ссылаются другие объекты. Например, на определение Шрифта может ссылаться стиль текста, а на слой могут ссылаться объекты на этом слое. Удаление объектов уменьшает размер файла чертежа при сохранении на диск.
Несвязанные объекты удаляются из базы данных чертежа с помощью метода Purge. Метод Purge требует список объектов, которые необходимо удалить, в виде `ObjectIdCollection` или `ObjectIdGraph`. Объекты `ObjectIdCollection` или `ObjectIdGraph`, переданные в метод `Purge`, возращают после его отработки те идентификаторы, связанные объекты с которыми, которые можно безопасно удалить самостоятельно (см. пример ниже для удаления пустых слоёв). 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("PurgeUnreferencedLayers")]
public static void PurgeUnreferencedLayers()
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

        // Create an ObjectIdCollection to hold the object ids for each table record
        ObjectIdCollection acObjIdColl = new ObjectIdCollection();

        // Step through each layer and add iterator to the ObjectIdCollection
        foreach (ObjectId acObjId in acLyrTbl)
        {
            acObjIdColl.Add(acObjId);
        }

        // Remove the layers that are in use and return the ones that can be erased
        acCurDb.Purge(acObjIdColl);

        // Step through the returned ObjectIdCollection
        // and erase each unreferenced layer
        foreach (ObjectId acObjId in acObjIdColl)
        {
            SymbolTableRecord acSymTblRec;
            acSymTblRec = acTrans.GetObject(acObjId,
                                            OpenMode.ForWrite) as SymbolTableRecord;

            try
            {
                // Erase the unreferenced layer
                acSymTblRec.Erase(true);
            }
            catch (Autodesk.AutoCAD.Runtime.Exception Ex)
            {
                // Layer could not be deleted
                Application.ShowAlertDialog("Error:\n" + Ex.Message);
            }
        }

        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
