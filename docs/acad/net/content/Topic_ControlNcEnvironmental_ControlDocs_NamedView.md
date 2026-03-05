Любой вид возможно сохранить под заданным именем (Именованный вид) и при необходимости их далее использовать. Созданные виды также можно удалить. Именованные виды хранятся в общей таблице видов (ViewTable) базы данных чертежа. Создаются новые виды при помощи вызова метода ViewTable.Add. При создании нового именованного вида ему автоматически назначается вид по умолчанию для пространства модели. Имя вида может содержать до 255 символов и содержать буквы, числа и следующие специальные символы: доллар-символ ($), тире (-), and нижнее подчеркивание (_). Удаление именованного вида (объекта ViewTableRecord) будет осуществляться через метод ViewTable.Erase. 

## Создание нового именованного вида

Код ниже создает новый именованный вид и делает его текущим: 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Runtime;
 
[CommandMethod("CreateNamedView")]
public static void CreateNamedView()
{
    // Get the current database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the View table for read
        ViewTable acViewTbl;
        acViewTbl = acTrans.GetObject(acCurDb.ViewTableId,
                                        OpenMode.ForRead) as ViewTable;

        // Check to see if the named view 'View1' exists
        if (acViewTbl.Has("View1") == false)
        {
            // Open the View table for write
            acTrans.GetObject(acCurDb.ViewTableId, OpenMode.ForWrite);

            // Create a new View table record and name the view 'View1'
            using (ViewTableRecord acViewTblRec = new ViewTableRecord())
            {
                acViewTblRec.Name = "View1";

                // Add the new View table record to the View table and the transaction
                acViewTbl.Add(acViewTblRec);
                acTrans.AddNewlyCreatedDBObject(acViewTblRec, true);

                // Set 'View1' current
                acDoc.Editor.SetCurrentView(acViewTblRec);
            }

            // Commit the changes
            acTrans.Commit();
        }

        // Dispose of the transaction
    }
}
```

## Удаление имеющегося именованного вида

Код ниже удаляет существующий (созданный в примере выше) именованный вид: 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Runtime;
 
[CommandMethod("EraseNamedView")]
public static void EraseNamedView()
{
    // Get the current database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the View table for read
        ViewTable acViewTbl;
        acViewTbl = acTrans.GetObject(acCurDb.ViewTableId,
                                        OpenMode.ForRead) as ViewTable;

        // Check to see if the named view 'View1' exists
        if (acViewTbl.Has("View1") == true)
        {
            // Open the View table for write
            acTrans.GetObject(acCurDb.ViewTableId, OpenMode.ForWrite);

            // Get the named view
            ViewTableRecord acViewTblRec;
            acViewTblRec = acTrans.GetObject(acViewTbl["View1"],
                                                OpenMode.ForWrite) as ViewTableRecord;

            // Remove the named view from the View table
            acViewTblRec.Erase();

            // Commit the changes
            acTrans.Commit();
        }

        // Dispose of the transaction
    }
}
```