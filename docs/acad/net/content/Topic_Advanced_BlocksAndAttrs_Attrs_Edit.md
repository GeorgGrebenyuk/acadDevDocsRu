# Редактирование атрибутов

Определения атрибута блока наследуют общий класс Attribute, который предоставляет следующие свойства и методы для редактирования: 

* FieldLength : количество разрешенных символов в значении атрибута; 
* Height : высота текста атрибута; 
* HorizontalMode : горизонтальное выравнивание атрибута; 
* IsMirroredInX : признак, что текст будет ориентирован справа:налево при значении true; 
* IsMirroredInY : признак, что текст будет ориентирован снизу:вверх при значении true; 
* Position : точка вставки атрибута; 
* Prompt : подсказка для атрибута (отображается в диалоговом окне INSERT при вставке блока); 
* Rotation : поворот атрибута; 
* Tag : идентификатор атрибута; 
* TextString : значение атрибута; 
* VerticalMode : вертикальное выравнивание атрибута; 

В примере ниже создается блок, к нему добавляется определение атрибута, затем создается вхождение блока. При добавлении в блок атрибутов у определения атрибута ставится свойство IsMirroredInX = true. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("RedefiningAnAttribute")]
public void RedefiningAnAttribute()
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

        // Create and insert the new block reference
        if (blkRecId != ObjectId.Null)
        {
            BlockTableRecord acBlkTblRec;
            acBlkTblRec = acTrans.GetObject(blkRecId, OpenMode.ForRead) as BlockTableRecord;

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

                            // Change the attribute definition to be displayed as backwards
                            acTrans.GetObject(objID, OpenMode.ForWrite);
                            acAtt.IsMirroredInX = true;
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

<b>Примечание</b>: в AutoCAD .NET API редактировать атрибут блока можно уже после создания вхождения атрибута, в nanoCAD механика событий несколько нарушена, поэтому для корректной работы необходимо действия с редактированием атрибутов делать до добавления их во Вхождение блока/
