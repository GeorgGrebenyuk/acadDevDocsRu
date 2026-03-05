Создание каких-либо элементов в чертеже всегда происходит на активном слое. Если вы сделаете активным другой слой, то все новые объекты, будут создаваться на нём, наследуя также настройки слоя -- цвет, тип линии и пр. Вы не можете сделать слой активным, если он заморожен. 

## Задание активного слоя через свойство Database.Clayer

Пример ниже содержит код, задающий слой с именем "Center" активным, если слой с таким именем имеется в чертеже 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("SetLayerCurrent")]
public static void SetLayerCurrent()
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

        string sLayerName = "Center";

        if (acLyrTbl.Has(sLayerName) == true)
        {
            // Set the layer Center current
            acCurDb.Clayer = acLyrTbl[sLayerName];

            // Save the changes
            acTrans.Commit();
        }

        // Dispose of the transaction
    }
}
```

<b>Задание активного слоя через переменную CLAYER</b> 

```cs
using Autodesk.AutoCAD.ApplicationServices;

Application.SetSystemVariable("CLAYER", "Center");
```