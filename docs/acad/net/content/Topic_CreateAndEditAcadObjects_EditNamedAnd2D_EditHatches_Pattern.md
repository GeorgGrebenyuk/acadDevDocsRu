# Редактирование определения штриховки

Возможно отредактировать шаблон в определении штриховки: изменить угол или интервал заполнения, задать иное имя шаблона (например, сплошную заливку SOLID) или сменить заливку на градиентное заполнение. Вы можете использовать некоторые из перечисленных ниже методов и свойств: 

* GradientAngle : возвращает или задает угол градиента; 
* GradientName : возвращает наименование градиентной заливки (если использовался преднастроенный стиль из поставки); 
* GradientShift : возвращает или задает сдвиг градиента (определяет позицию, где будет центр смены цветов); 
* GradientType : возвращает тип градиентной заливки; 
* PatternAngle : возвращает или задает угол штриховки; 
* PatternDouble : возвращает признак, является ли штриховка наложенной; 
* PatternType : возвращает тип образца штриховки; 
* SetHatchPattern : задает тип образца штриховки; 
* PatternName : возвращает имя образца штриховки; 
* SetHatchPattern : задает имя образца штриховки; 
* PatternScale : возвращает или задает масштаб штриховки; 
* PatternSpace : возвращает или задает интервал штриховки; 
* SetGradient : задает тип и имя образца градиента; 

## Изменение имени образца штриховки

В примере ниже создается определение штриховки, контуром которого выступает окружность. После добавления контура редактируются значения PatternScale и HatchPattern. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("EditHatchPatternScale")]
public static void EditHatchPatternScale()
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

        // Create a circle object for the boundary of the hatch
        using (Circle acCirc = new Circle())
        {
            acCirc.Center = new Point3d(5, 3, 0);
            acCirc.Radius = 3;

            acBlkTblRec.AppendEntity(acCirc);
            acTrans.AddNewlyCreatedDBObject(acCirc, true);

            // Adds the arc and line to an object id collection
            ObjectIdCollection acObjIdColl = new ObjectIdCollection();
            acObjIdColl.Add(acCirc.ObjectId);

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

                // Evaluate the hatch
                acHatch.EvaluateHatch(true);

                // Increase the pattern scale by 2 and re-evaluate the hatch
                acHatch.PatternScale = acHatch.PatternScale + 2;
                acHatch.SetHatchPattern(acHatch.PatternType, acHatch.PatternName);
                acHatch.EvaluateHatch(true);
            }
        }

        // Save the new object to the database
        acTrans.Commit();
    }
}
```
