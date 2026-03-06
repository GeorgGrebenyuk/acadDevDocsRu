# Создание\, редактирование и копирование размерных стилей

Для создания нового размерного стиля создайте новый экземпляр классса DimStyleTableRecord и добавьте его в коллекцию размерных стилей DimStyleTable с помощью метода Add. Перед добавлением стиля размеров в таблицу стилей необходимо задать ему имя с помощью свойства Name, требования к имени стандартные (см. [статью](\Topic_CreateAndEditNcObjects_EditNamedAnd2D_Named_Rename.md)). 

Вы также можете скопировать существующий или переопределённый стиль. Используйте метод CopyFrom для копирования в текущий стиль настроек из целевого размерного стиля (он указывается в аргументе метода). Исходным объектом может быть другой объект DimStyleTableRecord, объект Dimension (иной размер), Tolerance (допуск) или Leader (выноска), или даже объект Database (в этом случае задаются активные настройки размеров, заданные через системные переменные). 

## Копирование размерных стилей с последующим их переопределением

В примере ниже создаются три новых размерных стиля, и в каждый новый стиль размеров копируются настройки из трех источников: текущей базы данных, заданного размерного стиля и заданного объекта размера соответственно. 

Перед выполнением кода проделайте следующие шаги с чертежом: 

1. Создайте новый чертеж и сделайте его активным; 

2. Создайте произвольный линейный размер. Этот размер должен быть единственным объектом на чертеже;

3.  Измените цвет размерной линии на желтый;

4. Измените системную переменную DIMCLRD на 5 (синий);

5. Запустите следующий пример: 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("CopyDimStyles")]
public static void CopyDimStyles()
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

        // Open the Block table record Model space for read
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForRead) as BlockTableRecord;

        object acObj = null;
        foreach (ObjectId acObjId in acBlkTblRec)
        {
            // Get the first object in Model space
            acObj = acTrans.GetObject(acObjId,
                                        OpenMode.ForRead);

            break;
        }

        // Open the DimStyle table for read
        DimStyleTable acDimStyleTbl;
        acDimStyleTbl = acTrans.GetObject(acCurDb.DimStyleTableId,
                                            OpenMode.ForRead) as DimStyleTable;

        string[] strDimStyleNames = new string[3];
        strDimStyleNames[0] = "Style 1 copied from a dim";
        strDimStyleNames[1] = "Style 2 copied from Style 1";
        strDimStyleNames[2] = "Style 3 copied from the running drawing values";

        int nCnt = 0;

        // Keep a reference of the first dimension style for later
        DimStyleTableRecord acDimStyleTblRec1 = null;

        // Iterate the array of dimension style names
        foreach (string strDimStyleName in strDimStyleNames)
        {
            DimStyleTableRecord acDimStyleTblRec;
            DimStyleTableRecord acDimStyleTblRecCopy = null;

            // Check to see if the dimension style exists or not
            if (acDimStyleTbl.Has(strDimStyleName) == false)
            {
                if (acDimStyleTbl.IsWriteEnabled == false) acTrans.GetObject(acCurDb.DimStyleTableId, OpenMode.ForWrite);

                acDimStyleTblRec = new DimStyleTableRecord();
                acDimStyleTblRec.Name = strDimStyleName;

                acDimStyleTbl.Add(acDimStyleTblRec);
                acTrans.AddNewlyCreatedDBObject(acDimStyleTblRec, true);
            }
            else
            {
                acDimStyleTblRec = acTrans.GetObject(acDimStyleTbl[strDimStyleName],
                                                        OpenMode.ForWrite) as DimStyleTableRecord;
            }

            // Determine how the new dimension style is populated
            switch ((int)nCnt)
            {
                // Assign the values of the dimension object to the new dimension style
                case 0:
                    try
                    {
                        // Cast the object to a Dimension
                        Dimension acDim = acObj as Dimension;

                        // Copy the dimension style data from the dimension and
                        // set the name of the dimension style as the copied settings
                        // are unnamed.
                        acDimStyleTblRecCopy = acDim.GetDimstyleData();
                        acDimStyleTblRec1 = acDimStyleTblRec;
                    }
                    catch
                    {
                        // Object was not a dimension
                    }

                    break;

                // Assign the values of the dimension style to the new dimension style
                case 1:
                    acDimStyleTblRecCopy = acDimStyleTblRec1;
                    break;
                // Assign the values of the current drawing to the dimension style
                case 2:
                    acDimStyleTblRecCopy = acCurDb.GetDimstyleData();
                    break;
            }

            // Copy the dimension settings and set the name of the dimension style
            acDimStyleTblRec.CopyFrom(acDimStyleTblRecCopy);
            acDimStyleTblRec.Name = strDimStyleName;

            // Dispose of the copied dimension style
            acDimStyleTblRecCopy.Dispose();

            nCnt = nCnt + 1;
        }

        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```

Откройте диспетчер размерных стилей (команда DIMSTYLE), и вы увидите 3 новых стиля. "Style 1" будет иметь желтую размерную линию, как и "Style 2", а вот "Style 3" будет иметь синюю линию. Это показывает принцип наследования свойств размерных стилей в зависимости от источника копирования. 
