# Заморозка и размораживание слоя

Вы можете заморозить слой, чтобы ускорить процессы регенерации объемных чертежей, увеличить общую производительность чертежа и скорость выделения объектов. Объекты на замороженных слоях не отображаются, не выводятся на печать, к ним не применяется регенерация. При размораживании слоя происходит регенрация объектов на нем и включение их отображения. 

Используйте свойство `IsFrozen` для заморозки или размораживания слоя. Если ввести значение true, слой будет заморожен; если false, то слой будет разморожен. 

В примере ниже создается новый слой "ABC" при его отсутствии, после чего он замораживается. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
 
[CommandMethod("FreezeLayer")]
public static void FreezeLayer()
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

                // Freeze the layer
                acLyrTblRec.IsFrozen = true;

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

            // Freeze the layer
            acLyrTblRec.IsFrozen = true;
        }

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
