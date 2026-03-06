# Редактирование размеров

Как и в случае с другими графическими объектами в nanoCAD, вы можете редактировать размеры, используя методы и свойства, предоставляемые соответствующими классами. Для большинства видов размеров доступны следующие свойства: 

* DimensionStyle : идентификатор (ObjectId) размерного стиля; 
* DimensionStyleName : наименование размерного стиля (предпочтительнее использовать DimensionStyle, т.к. при попытке задания данного свойства могут быть ошибки); 
* DimensionText : позволяет задать пользовательский текст для размера (вместо авто:рассчитываемого значения); 
* HorizontalRotation : угол поворота размера в радианах; 
* Measurement : значение размера в виде числа double; 
* TextPosition : точка, где расположен элемент анотации (текст размера); 
* TextRotation : угол поворота текста размера; 

Отображаемое значение размера можно заменить или изменить с помощью свойства DimensionText. Для использования измеренного значения в тексте DimensionText используйте символьную строку "\<\>" в тексте нового выражения. 
В примере ниже к значению размера добавляется префикс "The value is " 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("OverrideDimensionText")]
public static void OverrideDimensionText()
{
    // Get the current database
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

        // Create the aligned dimension
        using (AlignedDimension acAliDim = new AlignedDimension())
        {
            acAliDim.XLine1Point = new Point3d(5, 3, 0);
            acAliDim.XLine2Point = new Point3d(10, 3, 0);
            acAliDim.DimLinePoint = new Point3d(7.5, 5, 0);
            acAliDim.DimensionStyle = acCurDb.Dimstyle;

            // Override the dimension text
            acAliDim.DimensionText = "The value is <>";

            // Add the new object to Model space and the transaction
            acBlkTblRec.AppendEntity(acAliDim);
            acTrans.AddNewlyCreatedDBObject(acAliDim, true);
        }

        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
