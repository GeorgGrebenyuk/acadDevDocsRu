## Переименование типа линии

Чтобы переименовать тип линии, используйте свойство Name. При переименовании типа линии вы переименовываете только определение типа линии в чертеже. Имя типа линия в файле LIN останется прежним. 

## Удаление типа линии

Чтобы удалить тип линии, используйте метод Erase. Нельзя удалить тип линии, если: 

* это системный тип линии BYLAYER, BYBLOCK, CONTINUOUS; 
* это текущий тип линии; 
* это используемый каким:либо объектом или слоем тип линии; 
* типы линий зависят от внешних ссылок; 

Кроме того, типы линий, на которые ссылаются определения блоков, не могут быть удалены, даже если они не используются ни одним объектом. 

## Изменение описания типа линии

Типы линий могут иметь связанное с ними описание. Описание представляет собой строку в ASCII-кодировке. Вы можете задать или изменить описание типа линии с помощью свойства AsciiDescription. Описание должно содержать до 47 символов (больше символов возможно, но при сохранении в lin-файл и последующем считывании описание урежется до 47 символов). Описание может содержать символы табуляции (например, для имитации рисунка типа линии). В примере ниже редактируется описание для активного типа линии, информация о котором возвращена через свойство Database.Celtype 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
 
[CommandMethod("ChangeLinetypeDescription")]
public static void ChangeLinetypeDescription()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;
 
    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Linetype table record of the current linetype for write
        LinetypeTableRecord acLineTypTblRec;
        acLineTypTblRec = acTrans.GetObject(acCurDb.Celtype,
                                            OpenMode.ForWrite) as LinetypeTableRecord;
 
        // Change the description of the current linetype
        acLineTypTblRec.AsciiDescription = "Exterior Wall";
 
        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```

## Изменение масштаба типа линии

Вы можете указать масштаб типа линии для новых создаваемых объектов. Чем меньше масштаб, тем больше повторений "узора линии" на единицу чертежа. По умолчанию AutoCAD использует глобальный масштаб типа линии 1.0, который равен одной единице чертежа. Вы можете изменить масштаб типа линии для всех объектов чертежа и определений атрибутов. Системная переменная `CELTSCALE` устанавливает масштаб типа линии для вновь создаваемых объектов. Системная переменная `LTSCALE` изменяет глобальный масштаб линий существующих объектов, а также новых объектов. 

Свойство `LinetypeScale` объекта используется для изменения масштаба типа линий объекта. Масштаб типа линий, в котором отображается объект, рассчитается как масштаб типа линий отдельного объекта, умноженный на глобальный масштаб типа линий (LTSCALE). В примере ниже задается глобальный масштаб типа линии и у одной из окружностей редактируется значение масштаба типа линии на 0.5 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("SetObjectLinetypeScale")]
public static void SetObjectLinetypeScale()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Save the current linetype
        ObjectId acObjId = acCurDb.Celtype;

        // Set the global linetype scale
        acCurDb.Ltscale = 3;

        // Open the Linetype table for read
        LinetypeTable acLineTypTbl;
        acLineTypTbl = acTrans.GetObject(acCurDb.LinetypeTableId,
                                            OpenMode.ForRead) as LinetypeTable;

        string sLineTypName = "Border";

        if (acLineTypTbl.Has(sLineTypName) == false)
        {
            acCurDb.LoadLineTypeFile(sLineTypName, "acad.lin");
        }

        // Set the Border linetype current
        acCurDb.Celtype = acLineTypTbl[sLineTypName];

        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                        OpenMode.ForRead) as BlockTable;

        // Open the Block table record Model space for write
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;

        // Create a circle object and set its linetype
        // scale to half of full size
        using (Circle acCirc1 = new Circle())
        {
            acCirc1.Center = new Point3d(2, 2, 0);
            acCirc1.Radius = 4;
            acCirc1.LinetypeScale = 0.5;

            acBlkTblRec.AppendEntity(acCirc1);
            acTrans.AddNewlyCreatedDBObject(acCirc1, true);

            // Create a second circle object
            using (Circle acCirc2 = new Circle())
            {
                acCirc2.Center = new Point3d(12, 2, 0);
                acCirc2.Radius = 4;

                acBlkTblRec.AppendEntity(acCirc2);
                acTrans.AddNewlyCreatedDBObject(acCirc2, true);
            }
        }

        // Restore the original active linetype
        acCurDb.Celtype = acObjId;

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```