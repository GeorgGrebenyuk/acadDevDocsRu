# Создание атрибутов

Чтобы создать новое определение атрибута необходимо создать экземпляр класса AttributeDefinition, а затем добавить его к целевому блоку, представленного объектом класса BlockTableRecord, с помощью метода AppendEntity. При определении атрибута следует указать высоту текста атрибута, режимы поведения, подсказку (Prompt) и значение тэга (Tag), точку вставки (Position) и значение атрибута по умолчанию .

Режимы поведения определения атрибута могут быть:

* Constant (постоянный) - атрибут блока будет иметь фиксированное значение для всех Вхождений блока;
* Invisible (невидимый) - атрибут не будет отображаться на чертеже и не будет выводиться на печать;
* IsMTextAttributeDefinition - атрибут может содержать многострочный текст (значение будет задаваться через свойство MTextAttributeDefinition);
* LockPositionInBlock - делает нередактируемым положение атрибута внутри Вхождения блока, после разблокировки атрибут можно перемещать относительно остальной части блока с помощью специальных ручек редактирования, а многострочным атрибутам можно изменять размер;
* Preset - атрибут будет иметь значение, равное значению по умолчанию. В AutoCAD отображается как "Установленный";
* Verifiable - будет запрашиваться подтверждение корректности значения атрибута при вставке Вхождения блока в чертеж. В AutoCAD отображается как "Контролируемый";

Примечание: системная переменная `ATTDISP`, переопределяющая видимость определений атрибутов, в nanoCAD не реализована.
Подсказка появляется при вставке блока, содержащего атрибут, и задается с помощью свойства `Prompt`. Значение по умолчанию для атрибута задается с помощью свойства TextString. Если свойство `Constant` установлено в значение true, запрос значения для данного атрибута не будет выводиться в окне вставки блока `INSERT`.
Тэг идентифицирует каждое определение атрибута и назначается с помощью свойства `Tag`. Можно использовать любые символы, кроме пробелов и восклицательных знаков, строчные буквы будут преобразованы в прописные.
После того, как определение атрибута будет добавлено в Блок, при каждой вставке блока через команду `INSERT` можно указать различные значения каждому из атрибуту, если он не определен как постоянный (Constant = true). При программном создании Вхождения блока (`BlockReference`) он не будет содержать атрибутов, заданных в определении блока (`BlockTableRecord`) до тех пор, пока они не будут добавлены также программно к данному `BlockReference` через метод `AppendAttribute`.
Перед добавлением атрибута к данному Вхождению блока (`BlockReference`) используйте метод `SetAttributeFromBlock`, чтобы скопировать свойства определения блока `AttributeDefinition` в объект `AttributeReference` (так как добавлять атрибуты можно только с помощью специального класса -- `AttributeReference`). Проверить наличие у блока каких-либо определений атрибутов можно с помощью свойства `HasAttributeDefinitions`.
Определения атрибутов, созданные в пространстве модели или пространстве листа, не считаются связанными с какими-либо блоками.

## Создание атрибута у блока

В примере ниже создается определение блока CircleBlockWithAttributes, представленного окружность и одним определением атрибута с именем "Door#". 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("AddingAttributeToABlock")]
public void AddingAttributeToABlock()
{
    // Get the current database and start a transaction
    Database acCurDb;
    acCurDb = Application.DocumentManager.MdiActiveDocument.Database;

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId, OpenMode.ForRead) as BlockTable;

        if (!acBlkTbl.Has("CircleBlockWithAttributes"))
        {
            using (BlockTableRecord acBlkTblRec = new BlockTableRecord())
            {
                acBlkTblRec.Name = "CircleBlockWithAttributes";

                // Set the insertion point for the block
                acBlkTblRec.Origin = new Point3d(0, 0, 0);

                // Add a circle to the block
                using (Circle acCirc = new Circle())
                {
                    acCirc.Center = new Point3d(0, 0, 0);
                    acCirc.Radius = 2;

                    acBlkTblRec.AppendEntity(acCirc);

                    // Add an attribute definition to the block
                    using (AttributeDefinition acAttDef = new AttributeDefinition())
                    {
                        acAttDef.Position = new Point3d(0, 0, 0);
                        acAttDef.Verifiable = true;
                        acAttDef.Prompt = "Door #: ";
                        acAttDef.Tag = "Door#";
                        acAttDef.TextString = "DXX";
                        acAttDef.Height = 1;
                        acAttDef.Justify = AttachmentPoint.MiddleCenter;
                        //Тут может возникнуть ошибка, см. примечание внизу
                        acBlkTblRec.AppendEntity(acAttDef);

                        acTrans.GetObject(acCurDb.BlockTableId, OpenMode.ForWrite);
                        acBlkTbl.Add(acBlkTblRec);
                        acTrans.AddNewlyCreatedDBObject(acBlkTblRec, true);
                    }
                }
            }
        }

        // Save the new object to the database
        acTrans.Commit();

        // Dispose of the transaction
    }
}
```

**Примечание**: в AutoCAD (2022) .NET API замечено, в некоторых случаях, если одновременно в теле using создания BlockTableRecord выполняется и добавление определений атрибутов, то AutoCAD может выбросить ошибку доступа в память и вылетать с фатальной ошибкой. Решение -- в теле using только создать блок без атрибутов, а после using-конструкции получить созданный BlockTableRecord на запись и добавить в него атрибуты. В nanoCAD .NET API таких проблем не встречалось.

## Вставка блока с атрибутами

В примере ниже в пространство модели вставляется блок с именем CircleBlockWithAttributes и вхождением атрибута, заданного в определении блока. Если определение блока отсутствует, то оно создается. 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("InsertingBlockWithAnAttribute")]
public void InsertingBlockWithAnAttribute()
{
    // Get the current database and start a transaction
    Database acCurDb;
    acCurDb = Application.DocumentManager.MdiActiveDocument.Database;

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId, OpenMode.ForRead) as BlockTable;

        ObjectId blkRecId = ObjectId.Null;

        if (!acBlkTbl.Has("CircleBlockWithAttributes"))
        {
            using (BlockTableRecord acBlkTblRec = new BlockTableRecord())
            {
                acBlkTblRec.Name = "CircleBlockWithAttributes";

                // Set the insertion point for the block
                acBlkTblRec.Origin = new Point3d(0, 0, 0);

                // Add a circle to the block
                using (Circle acCirc = new Circle())
                {
                    acCirc.Center = new Point3d(0, 0, 0);
                    acCirc.Radius = 2;

                    acBlkTblRec.AppendEntity(acCirc);

                    // Add an attribute definition to the block
                    using (AttributeDefinition acAttDef = new AttributeDefinition())
                    {
                        acAttDef.Position = new Point3d(0, 0, 0);
                        acAttDef.Prompt = "Door #: ";
                        acAttDef.Tag = "Door#";
                        acAttDef.TextString = "DXX";
                        acAttDef.Height = 1;
                        acAttDef.Justify = AttachmentPoint.MiddleCenter;
                        acBlkTblRec.AppendEntity(acAttDef);

                        acTrans.GetObject(acCurDb.BlockTableId, OpenMode.ForWrite);
                        acBlkTbl.Add(acBlkTblRec);
                        acTrans.AddNewlyCreatedDBObject(acBlkTblRec, true);
                    }
                }

                blkRecId = acBlkTblRec.Id;
            }
        }
        else
        {
            blkRecId = acBlkTbl["CircleBlockWithAttributes"];
        }

        // Insert the block into the current space
        if (blkRecId != ObjectId.Null)
        {
            BlockTableRecord acBlkTblRec;
            acBlkTblRec = acTrans.GetObject(blkRecId, OpenMode.ForRead) as BlockTableRecord;

            // Create and insert the new block reference
            using (BlockReference acBlkRef = new BlockReference(new Point3d(2, 2, 0), blkRecId))
            {
                BlockTableRecord acCurSpaceBlkTblRec;
                acCurSpaceBlkTblRec = acTrans.GetObject(acCurDb.CurrentSpaceId, OpenMode.ForWrite) as BlockTableRecord;

                acCurSpaceBlkTblRec.AppendEntity(acBlkRef);
                acTrans.AddNewlyCreatedDBObject(acBlkRef, true);

                // Verify block table record has attribute definitions associated with it
                if (acBlkTblRec.HasAttributeDefinitions)
                {
                    // Add attributes from the block table record
                    foreach (ObjectId objID in acBlkTblRec)
                    {
                        DBObject dbObj = acTrans.GetObject(objID, OpenMode.ForRead) as DBObject;

                        if (dbObj is AttributeDefinition)
                        {
                            AttributeDefinition acAtt = dbObj as AttributeDefinition;

                            if (!acAtt.Constant)
                            {
                                using (AttributeReference acAttRef = new AttributeReference())
                                {
                                    acAttRef.SetAttributeFromBlock(acAtt, acBlkRef.BlockTransform);
                                    acAttRef.Position = acAtt.Position.TransformBy(acBlkRef.BlockTransform);

                                    acAttRef.TextString = acAtt.TextString;

                                    acBlkRef.AttributeCollection.AppendAttribute(acAttRef);

                                    acTrans.AddNewlyCreatedDBObject(acAttRef, true);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Save the new object to the database
        acTrans.Commit();

        // Dispose of the transaction
    }
}
```
