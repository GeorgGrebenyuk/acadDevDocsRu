# Блокировка и разблокировка слоя

Объекты на заблокированном слое нельзя изменить (они видимы и заморожены). 

Объекты на заблокированном слое нельзя изменить, однако они по-прежнему будут видны, если слой включен и не заморожен. Вы можете сделать заблокированный слой текущим и добавлять в него объекты. Вы можете заморозить и отключить заблокированные слои, а также изменить их общие свойства. 

Используйте свойство `IsLocked` для управления блокировкой слоя. Если ввести значение true, то слой будет заблокирован; если false, то слой будет разблокирован. В примере ниже создается новый слой "ABC" при его отсутствии и ему задается блокировка 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
 
[CommandMethod("LockLayer")]
public static void LockLayer()
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

        if (acLyrTbl.Has(sLayerName) == false)
        {
            using (LayerTableRecord acLyrTblRec = new LayerTableRecord())
            {
                // Assign the layer a name
                acLyrTblRec.Name = sLayerName;

                // Lock the layer
                acLyrTblRec.IsLocked = true;

                // Upgrade the Layer table for write
                acTrans.GetObject(acCurDb.LayerTableId, OpenMode.ForWrite);

                // Append the new layer to the Layer table and the transaction
                acLyrTbl.Add(acLyrTblRec);
                acTrans.AddNewlyCreatedDBObject(acLyrTblRec, true);
            }
        }
        else
        {
            LayerTableRecord acLyrTblRec = acTrans.GetObject(acLyrTbl[sLayerName],
                                            OpenMode.ForWrite) as LayerTableRecord;

            // Lock the layer
            acLyrTblRec.IsLocked = true;
        }

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
