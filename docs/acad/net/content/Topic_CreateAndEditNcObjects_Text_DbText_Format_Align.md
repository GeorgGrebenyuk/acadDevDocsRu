Вы можете выравнивить однострочный текст по горизонтали и вертикали. По умолчанию используется выравнивание по левому краю. Для настройки параметров выравнивания по горизонтали и вертикали используйте свойства `HorizontalMode` и `VerticalMode` соответственно. 

Обычно при завершении работы с текстовым объектом его положение и границы выравнивания пересчитываются согласно настройкам стиля текста. Для визуального изменения настроек выравнивания вызовите метод `AdjustAlignment` у текстового объекта. 

В примере ниже для каждого из выравниваний текста по горизонталей отрисовывается точка, относительно которой происходит выравнивание, в виде объекта класса DBPoint красного цвета в виде креста. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("TextAlignment")]
public static void TextAlignment()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                        OpenMode.ForRead) as BlockTable;

        // Open the Block table record Model space for write
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;

        string[] textString = new string[3];
        textString[0] = "Left";
        textString[1] = "Center";
        textString[2] = "Right";

        int[] textAlign = new int[3];
        textAlign[0] = (int)TextHorizontalMode.TextLeft;
        textAlign[1] = (int)TextHorizontalMode.TextCenter;
        textAlign[2] = (int)TextHorizontalMode.TextRight;

        Point3d acPtIns = new Point3d(3, 3, 0);
        Point3d acPtAlign = new Point3d(3, 3, 0);

        int nCnt = 0;

        foreach (string strVal in textString)
        {
            // Create a single-line text object
            using (DBText acText = new DBText())
            {
                acText.Position = acPtIns;
                acText.Height = 0.5;
                acText.TextString = strVal;

                // Set the alignment for the text
                acText.HorizontalMode = (TextHorizontalMode)textAlign[nCnt];

                if (acText.HorizontalMode != TextHorizontalMode.TextLeft)
                {
                    acText.AlignmentPoint = acPtAlign;
                }

                acBlkTblRec.AppendEntity(acText);
                acTrans.AddNewlyCreatedDBObject(acText, true);
            }

            // Create a point over the alignment point of the text
            using (DBPoint acPoint = new DBPoint(acPtAlign))
            {
                acPoint.ColorIndex = 1;

                acBlkTblRec.AppendEntity(acPoint);
                acTrans.AddNewlyCreatedDBObject(acPoint, true);

                // Adjust the insertion and alignment points
                acPtIns = new Point3d(acPtIns.X, acPtIns.Y + 3, 0);
                acPtAlign = acPtIns;
            }

            nCnt = nCnt + 1;
        }

        // Set the point style to crosshair
        Application.SetSystemVariable("PDMODE", 2);

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```