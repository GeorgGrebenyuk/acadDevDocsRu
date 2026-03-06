# Перебор слоев

Получить информацию о слоях документа вы можете путем итеративного перебора таблицы слоев (LayerTable). Пример ниже собирает информацию об именах слоев и выводит её в диалоговое окно. 

```cs
using Teigha.Runtime;
using HostMgd.ApplicationServices;
using Teigha.DatabaseServices;
[CommandMethod("DisplayLayerNames")]
public static void DisplayLayerNames()
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
        string sLayerNames = "";
        foreach (ObjectId acObjId in acLyrTbl)
        {
            LayerTableRecord acLyrTblRec;
            acLyrTblRec = acTrans.GetObject(acObjId,
                                            OpenMode.ForRead) as LayerTableRecord;
            sLayerNames = sLayerNames + "\\n" + acLyrTblRec.Name;
        }
        Application.ShowAlertDialog("The layers in this drawing are: " +
                                    sLayerNames);
        // Dispose of the transaction
    }
}
```
