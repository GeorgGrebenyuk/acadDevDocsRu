# Установка типа линии

Тип линии является одной их характеристик отображения графических объектов в чертеже. Наименование типа линии и его определение описывают последовательность штрихов и точек, длину штрихов и пробелов, а также характеристики любых содержащихся в стиле текстовых символов или фигур. 

Используйте свойство Linetype, чтобы назначить тип линии слою. Это свойство принимает в качестве входных данных имя типа линии. 
**Примечание**: Прежде чем назначить тип линии слою, необходимо удостовериться, что такой тип линии в чертеже есть. В примере ниже создается новый слой "ABC" при его отсутствии, и ему назначается тип линии "Center" при его наличии в перечне типов линий. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
 
[CommandMethod("SetLayerLinetype")]
public static void SetLayerLinetype()
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

                // Open the Layer table for read
                LinetypeTable acLinTbl;
                acLinTbl = acTrans.GetObject(acCurDb.LinetypeTableId,
                                                OpenMode.ForRead) as LinetypeTable;

                if (acLinTbl.Has("Center") == true)
                {
                    // Set the linetype for the layer
                    acLyrTblRec.LinetypeObjectId = acLinTbl["Center"];
                }

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
                                            OpenMode.ForRead) as LayerTableRecord;

            // Open the Layer table for read
            LinetypeTable acLinTbl;
            acLinTbl = acTrans.GetObject(acCurDb.LinetypeTableId,
                                            OpenMode.ForRead) as LinetypeTable;

            if (acLinTbl.Has("Center") == true)
            {
                // Upgrade the Layer Table Record for write
                acTrans.GetObject(acLyrTbl[sLayerName], OpenMode.ForWrite);

                // Set the linetype for the layer
                acLyrTblRec.LinetypeObjectId = acLinTbl["Center"];
            }
        }

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
