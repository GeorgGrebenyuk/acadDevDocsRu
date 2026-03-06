# Редактирование границ штриховки

Вы можете добавляет, переопределять, удалять контуры у штриховки. Ассоциативные штриховки обновятся при любых изменениях, внесенных в из границы; неассоциативные штриховки не обновятся.
Чтобы отредактировать границу штриховки или получить свойства о них, используйте следующие методы и свойства:

* AppendLoop - добавляет новый контур к определению штриховки. Тип добавляемой петли определяется первым аргументом метода AppendLoop (константами, определенными перечислением Teigha.DatabaseServices.HatchLoopTypes);
* GetLoopAt - возвращает контур по заданному индексу;
* InsertLoopAt - переопределяет контур по заданному индексу;
* RemoveLoopAt - удаляет контур по заданному индексу;
* LoopTypeAt - вовзвращает тип контура по заданному индексу;
* NumberOfLoops - возвращает число контуров;

## Добавление внутреннего контура в штриховку

Пример ниже создает ассоциативную штриховку, добавляет в неё окружность в качестве внешнего контура и другую окружность в качестве внутреннего контура

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("EditHatchAppendLoop")]
public static void EditHatchAppendLoop()
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

        // Create an arc object for the closed boundary to hatch
        using (Arc acArc = new Arc(new Point3d(5, 3, 0), 3, 0, 3.141592))
        {

            acBlkTblRec.AppendEntity(acArc);
            acTrans.AddNewlyCreatedDBObject(acArc, true);

            // Create an line object for the closed boundary to hatch
            using (Line acLine = new Line(acArc.StartPoint, acArc.EndPoint))
            {
                acBlkTblRec.AppendEntity(acLine);
                acTrans.AddNewlyCreatedDBObject(acLine, true);

                // Adds the arc and line to an object id collection
                ObjectIdCollection acObjIdColl = new ObjectIdCollection();
                acObjIdColl.Add(acArc.ObjectId);
                acObjIdColl.Add(acLine.ObjectId);

                // Create the hatch object and append it to the block table record
                using (Hatch acHatch = new Hatch())
                {
                    acBlkTblRec.AppendEntity(acHatch);
                    acTrans.AddNewlyCreatedDBObject(acHatch, true);

                    // Set the properties of the hatch object
                    // Associative must be set after the hatch object is appended to the 
                    // block table record and before AppendLoop
                    acHatch.SetHatchPattern(HatchPatternType.PreDefined, "ANSI31");
                    acHatch.Associative = true;
                    acHatch.AppendLoop(HatchLoopTypes.Outermost, acObjIdColl);

                    // Create a circle object for the inner boundary of the hatch
                    using (Circle acCirc = new Circle())
                    {
                        acCirc.Center = new Point3d(5, 4.5, 0);
                        acCirc.Radius = 1;

                        acBlkTblRec.AppendEntity(acCirc);
                        acTrans.AddNewlyCreatedDBObject(acCirc, true);

                        // Adds the circle to an object id collection
                        acObjIdColl.Clear();
                        acObjIdColl.Add(acCirc.ObjectId);

                        // Append the circle as the inner loop of the hatch and evaluate it
                        acHatch.AppendLoop(HatchLoopTypes.Default, acObjIdColl);
                        acHatch.EvaluateHatch(true);
                    }
                }
            }
        }

        // Save the new object to the database
        acTrans.Commit();
    }
}
```
