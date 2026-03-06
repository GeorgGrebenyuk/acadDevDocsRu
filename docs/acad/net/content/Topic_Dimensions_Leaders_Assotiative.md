# Ассоциативность выносок

Выноски связаны со своими аннотациями таким образом, что при перемещении аннотации конечная точка выноски перемещается вместе с ней. При перемещении текста и аннотаций, содержащих элементы управления (поля, стрелки и пр.), последний сегмент выноски попеременно прикрепляется к левой и правой сторонам аннотации в зависимости от положения аннотации относительно предпоследней (второй с конца) точки выноски. Если середина аннотации находится справа от предпоследней точки выноски, то выноска прикрепляется справа; в противном случае — слева от анотативного блока. 

Удаление любого из составляющих выноску объектов с чертежа с помощью методов Erase, Add (добавление в состав Блока) или WBlock нарушит ассоциативность. Если выноска и ее аннотация копируются вместе в рамках одной операции, новая копия будет ассоциативной. Если они копируются отдельно, они будут неассоциативными. Если ассоциативность нарушена по какой-либо причине, например, при копировании только объекта WBlock или при удалении аннотации, полка будет также удалена с выноски. 

## Связывание анотации с выноской

В примере ниже создается выноска с многострочным текстом в качестве анотации 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("AddLeaderAnnotation")]
public static void AddLeaderAnnotation()
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

        // Create the MText annotation
        using (MText acMText = new MText())
        {
            acMText.Contents = "Hello, World.";
            acMText.Location = new Point3d(5, 5, 0);
            acMText.Width = 2;

            // Add the new object to Model space and the transaction
            acBlkTblRec.AppendEntity(acMText);
            acTrans.AddNewlyCreatedDBObject(acMText, true);

            // Create the leader with annotation
            using (Leader acLdr = new Leader())
            {
                acLdr.AppendVertex(new Point3d(0, 0, 0));
                acLdr.AppendVertex(new Point3d(4, 4, 0));
                acLdr.AppendVertex(new Point3d(4, 5, 0));
                acLdr.HasArrowHead = true;

                // Add the new object to Model space and the transaction
                acBlkTblRec.AppendEntity(acLdr);
                acTrans.AddNewlyCreatedDBObject(acLdr, true);

                // Attach the annotation after the leader object is added
                acLdr.Annotation = acMText.ObjectId;
                acLdr.EvaluateLeader();
            }
        }

        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```

**Примечание**: в некоторых случаях в nanoCAD .NET API добавление анотации может завершиться ошибкой при вызове метода EvaluateLeader.
