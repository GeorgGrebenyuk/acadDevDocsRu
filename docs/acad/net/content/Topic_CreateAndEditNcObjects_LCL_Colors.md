# Работа с цветами

Вы можете назначить цвет отдельному объекту в чертеже, используя его свойство Color, ColorIndex или цвета из альбома цветов. Свойство ColorIndex принимает значение т.н. AutoCAD Color Index (ACI) в виде числового значения от 0 до 256. Свойство Color используется для назначения объекту номера ACI, цвета RGB. 

**Примечание**: Вариант задания цвета из альбома цветов, существовавший в AutoCAD .NET API не реализован.

Объект Color имеет метод SetRGB, который позволяет определить цвет, состоящий из заданного числа красного, зеленого и синего оттенков. Вы также можете назначать цвет конкретному слою. Если вы хотите, чтобы объект унаследовал цвет слоя, на котором он находится, установите цвет объекта на ByLayer, задав значение цвета слоя ACI = 256. Один и тот же цвет может иметь неограниченное количество объектов и слоев.

## Задание цвета объекты несколькими способами

В примере ниже окружности задается цвет 3 разными способами: через индекс цвета ACI, RGB-код и альбом цветов. 

**Примечание**: наименование альбома цвета и сам цвет скорректирован по шаблону `acadiso.dwt` из AutoCAD 2022, для оригинального примера такие значения отсутствуют.

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.Colors;

[CommandMethod("SetObjectColor")]
public static void SetObjectColor()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Define an array of colors for the layers
        Color[] acColors = new Color[3];
        acColors[0] = Color.FromColorIndex(ColorMethod.ByAci, 1);
        acColors[1] = Color.FromRgb(23, 54, 232);
        acColors[2] = Co"PANTONE Yellow C", "PANTONE+ Solid Coated"astel coated");

        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                        OpenMode.ForRead) as BlockTable;

        // Open the Block table record Model space for write
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;

        // Create a circle object and assign it the ACI value of 4
        Point3d acPt = new Point3d(0, 3, 0);
        using (Circle acCirc = new Circle())
        {
            acCirc.Center = acPt;
            acCirc.Radius = 1;
            acCirc.ColorIndex = 4;

            acBlkTblRec.AppendEntity(acCirc);
            acTrans.AddNewlyCreatedDBObject(acCirc, true);

            int nCnt = 0;

            while (nCnt < 3)
            {
                // Create a copy of the circle
                Circle acCircCopy;
                acCircCopy = acCirc.Clone() as Circle;

                // Shift the copy along the Y-axis
                acPt = new Point3d(acPt.X, acPt.Y + 3, acPt.Z);
                acCircCopy.Center = acPt;

                // Assign the new color to the circle
                acCircCopy.Color = acColors[nCnt];

                acBlkTblRec.AppendEntity(acCircCopy);
                acTrans.AddNewlyCreatedDBObject(acCircCopy, true);

                nCnt = nCnt + 1;
            }
        }

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```

## Задание активного цвета через свойство Database.Cecolor

Пример ниже содержит код, задающий активным цвет "По слою" 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.Colors;

[CommandMethod("SetColorCurrent")]
public static void SetColorCurrent()
{
    // Get the current document
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    // Set the current color
    acDoc.Database.Cecolor = Color.FromColorIndex(ColorMethod.ByLayer, 256);
}
```

## Задание активного цвета через переменную CECOLOR

Пример ниже задает активный слой = Красный с помощью задания системной переменной CECOLOR 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;

[CommandMethod("SetColorCurrent")]
public static void SetColorCurrent()
{
    Application.SetSystemVariable("CECOLOR", "1");
}
```
