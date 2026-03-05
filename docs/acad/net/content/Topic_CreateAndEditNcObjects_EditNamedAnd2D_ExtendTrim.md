Вы можете редактировать величины углов дуг и длины отрезков, незамкнутых полилиний, эллиптических дуг и незамкнутых сплайнов. 

Для этого используйте соответствующие свойства для классов, описывающих объект, например, чтобы удлинить линию, просто измените свойство StartPoint или EndPoint. Чтобы изменить угол дуги, измените её свойство StartAngle или EndAngle. После изменения свойств объекта может потребоваться перерисовка окна чертежа, чтобы увидеть изменения. 

Код ниже формирует отрезок большей длины, чем данный, путем редактирования точки EndPoint. Перед тем, как изменить длину отрезка Пользователю будет выведено модальное окно сообщения "Before extend", после закрытия которого длина будет изменена. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("ExtendObject")]
public static void ExtendObject()
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

        // Create a line that starts at (4,4,0) and ends at (7,7,0)
        using (Line acLine = new Line(new Point3d(4, 4, 0),
                                new Point3d(7, 7, 0)))
        {

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acLine);
            acTrans.AddNewlyCreatedDBObject(acLine, true);

            // Update the display and diaplay a message box
            acDoc.Editor.Regen();
            Application.ShowAlertDialog("Before extend");

            // Double the length of the line
            acLine.EndPoint = acLine.EndPoint + acLine.Delta;
        }

        // Save the new object to the database
        acTrans.Commit();
    }
}
```