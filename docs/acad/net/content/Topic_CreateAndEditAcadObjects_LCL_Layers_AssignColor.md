# Установка цвета слою

Каждому слою может быть назначен определенный цвет. Цвет слоя описывается объектом Color, который является частью пространства имен Colors. Этот объект может содержать значение RGB или номер ACI (целое число от 1 до 255). Вариант задания цвета из альбома цветов, существовавший в AutoCAD .NET API не реализован. 

Чтобы назначить цвет слою или получить информацию о нём, используйте свойство Color. 
**Примечание**: некоторые объекты, такие как линии и окружности и пр., имеют два разных свойства для управления их текущим цветом. Свойство Color используется для назначения значения RGB, номера ACI или цвета из альбома цветов, а свойство ColorIndex поддерживает только номера ACI. 

Если вы используете цвет ACI=0 или ByBlock, AutoCAD рисует новые объекты в цвете по умолчанию (белом или черном, в зависимости от настроек приложения), пока они не будут добавлены в блок. При размещении объекты в конкретном блоке (объекте таблицы записи блоков), объекты наследуют его текущие настройки свойств. 

Если вы используете цвет ACI=256 или ByLayer, новые объекты наследуют цвет слоя, на котором они находятся. В примере ниже создаются 2 слоя, каждому из которых задаются цвета двумя разными перечисленными выше методами 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Colors;
 
[CommandMethod("SetLayerColor")]
public static void SetLayerColor()
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

        // Define an array of layer names
        string[] sLayerNames = new string[3];
        sLayerNames[0] = "ACIRed";
        sLayerNames[1] = "TrueBlue";
        sLayerNames[2] = "ColorBookYellow";

        // Define an array of colors for the layers
        Color[] acColors = new Color[3];
        acColors[0] = Color.FromColorIndex(ColorMethod.ByAci, 1);
        acColors[1] = Color.FromRgb(23, 54, 232);
        acColors[2] = Color.FromNames("PANTONE Yellow 0131 C",
                                      "PANTONE+ Pastels & Neons Coated");

        int nCnt = 0;

        // Add or change each layer in the drawing
        foreach (string sLayerName in sLayerNames)
        {
            if (acLyrTbl.Has(sLayerName) == false)
            {
                using (LayerTableRecord acLyrTblRec = new LayerTableRecord())
                {
                    // Assign the layer a name
                    acLyrTblRec.Name = sLayerName;

                    // Set the color of the layer
                    acLyrTblRec.Color = acColors[nCnt];

                    // Upgrade the Layer table for write
                    if (acLyrTbl.IsWriteEnabled == false) acTrans.GetObject(acCurDb.LayerTableId, OpenMode.ForWrite);

                    // Append the new layer to the Layer table and the transaction
                    acLyrTbl.Add(acLyrTblRec);
                    acTrans.AddNewlyCreatedDBObject(acLyrTblRec, true);
                }
            }
            else
            {
                // Open the layer if it already exists for write
                LayerTableRecord acLyrTblRec = acTrans.GetObject(acLyrTbl[sLayerName],
                                                                 OpenMode.ForWrite) as LayerTableRecord;

                // Set the color of the layer
                acLyrTblRec.Color = acColors[nCnt];
            }

            nCnt = nCnt + 1;
        }

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
