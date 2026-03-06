# Изменение режима открытия объектов

Режим открытия объекта (OpenMode) может быть изменен с чтения на запись и наоборот. Методы ниже можно использовать для этих целей: 

* Transaction.GetObject : если объект был открыт с использованием транзакции, используйте этот же метод для открытия объекта ещё раз с нужным режимом; 
* Методы UpgradeOpen и DowngradeOpen : если объект был открыт при помощи метода Open или OpenCloseTransaction.GetObject используйте метод `UpgradeOpen` для изменения режима доступа к объекту с чтения на запись или метод `DowngradeOpen` для перевода режима с записи на чтение. Вам не потребуется выполнять вручную вызов DowngradeOpen вместе с каждым UpgradeOpen, поскольку закрытие объекта (Close) или удаление объекта транзакции (Dispose) сотрет информацию об измененном режиме доступа к объекту. 

Рекомендуется изначально открывать объект сразу в том режиме, в котором требуется, поскольку эффективнее открыть объект для чтения и запросить его свойства, чем открыть объект для записи и также запросить его свойства. Если вы не уверены, что объект потребуется изменить, лучше открыть объект для чтения, а затем обновить его для записи, так как это поможет снизить аппаратные издержки на лишние действия. Пример ниже получает для чтения таблицу слоев и в ней каждый из слоев (LayerTableRecord) также для чтения. Если имя слоя начинается с "Door" и он не является активным, то режим получения объекта изменяется на запись и у него задается флаг заморозки IsFrozen = true. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("FreezeDoorLayer")]
public static void FreezeDoorLayer()
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

        // Step through each layer and update those that start with 'Door'
        foreach (ObjectId acObjId in acLyrTbl)
        {
            // Open the Layer table record for read
            LayerTableRecord acLyrTblRec;
            acLyrTblRec = acTrans.GetObject(acObjId,
                                            OpenMode.ForRead) as LayerTableRecord;

            // Check to see if the layer's name starts with 'Door' 
            if (acLyrTblRec.Name.StartsWith("Door",
                                            StringComparison.OrdinalIgnoreCase) == true)
            {
                // Check to see if the layer is current, if so then do not freeze it
                if (acLyrTblRec.ObjectId != acCurDb.Clayer)
                {
                    // Change from read to write mode
                    acTrans.GetObject(acObjId, OpenMode.ForWrite);

                    // Freeze the layer
                    acLyrTblRec.IsFrozen = true;
                }
            }
        }

        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
