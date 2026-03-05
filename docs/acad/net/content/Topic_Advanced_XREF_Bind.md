Привязка внешней ссылки к чертежу с помощью метода `Bind` делает внешнюю ссылку постоянной частью чертежа в виде блока, она перестает быть внешней ссылкой, при обновлении исходного файла информация в созданном блоке не будет обновлена, при внедрении данных чертежа в текущий чертеж импортируются все связанные с базой данных целевого чертежа вспомогательные данные (слои, стили, типы линий и пр.). Основная цель внедрения файла внешней ссылки -- это использование его настроек (стилей, типов данных и пр.) в данном чертеже. 

Метод `BindXref` требует указания двух параметра: xrefIds (набор идентификаторов внешних ссылок, BlockTableRecord) и флаг insertBind. Если параметр insertBind установлен в значение true, то все блоки, стили и пр. "именованные объекты" из переносимого чертежа будут скопированы в данный с префиксом в виде имени файла внешней ссылки и суффиксом-счетчиком для пересохранения одноименных определений. Если параметр insertBind будет установлен в false, то имена объектов будут скопированы без изменений. Рекомендуется использовать флаг true, если нет уверенности, что чертеж не содержит дублей. 

Если внешняя ссылка имела в чертеже более одного вхождения, все из них станут "Вхождениями блоков". 

В примере ниже создается простой чертеж из одной окружности, далее он добавляется в данный в качестве внешней ссылки в две отдельные позиции. Вызывается метод BindXref и вставленные в чертеж внешние ссылки становятся Вхождениями блоков (блок -- определение целевого чертежа). 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("BindingExternalReference")]
public void BindingExternalReference()
{
    string tmpDwg = @"C:\Temp\test.dwg";
    using (Database dbTmp = new Database())
    {
        using (Transaction acTrans = dbTmp.TransactionManager.StartTransaction())
        {
            // Open the Block table record for read
            BlockTable acBlkTbl;
            acBlkTbl = acTrans.GetObject(dbTmp.BlockTableId,
                                            OpenMode.ForRead) as BlockTable;
            // Open the Block table record Model space for write
            BlockTableRecord acBlkTblRec;
            acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                            OpenMode.ForWrite) as BlockTableRecord;
            using (Circle acCirc = new Circle(new Point3d(0, 0, 0), Vector3d.ZAxis, 2))
            {
                acBlkTblRec.AppendEntity(acCirc);
                acTrans.AddNewlyCreatedDBObject(acCirc, true);
            }
            acTrans.Commit();
        }
        dbTmp.SaveAs(tmpDwg, DwgVersion.Current);
    }
    // Get the current database and start a transaction
    Database acCurDb;
    acCurDb = Application.DocumentManager.MdiActiveDocument.Database;
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Create a reference to a DWG file
        ObjectId acXrefId = acCurDb.AttachXref(tmpDwg, "Test1");
        // If a valid reference is created then continue
        if (!acXrefId.IsNull)
        {
            // Attach the DWG reference to the current space
            Point3d insPt1 = new Point3d(10, 10, 0);
            Point3d insPt2 = new Point3d(30, 10, 0);
            using (BlockReference acBlkRef = new BlockReference(insPt1, acXrefId))
            {
                BlockTableRecord acBlkTblRec;
                acBlkTblRec = acTrans.GetObject(acCurDb.CurrentSpaceId, OpenMode.ForWrite) as BlockTableRecord;
                acBlkTblRec.AppendEntity(acBlkRef);
                acTrans.AddNewlyCreatedDBObject(acBlkRef, true);
            }
            using (BlockReference acBlkRef = new BlockReference(insPt2, acXrefId))
            {
                BlockTableRecord acBlkTblRec;
                acBlkTblRec = acTrans.GetObject(acCurDb.CurrentSpaceId, OpenMode.ForWrite) as BlockTableRecord;
                acBlkTblRec.AppendEntity(acBlkRef);
                acTrans.AddNewlyCreatedDBObject(acBlkRef, true);
            }
            Application.ShowAlertDialog("The external reference is attached.");
            using (ObjectIdCollection acXrefIdCol = new ObjectIdCollection())
            {
                acXrefIdCol.Add(acXrefId);
                acCurDb.BindXrefs(acXrefIdCol, false);
            }
            Application.ShowAlertDialog("The external reference is bound.");
        }
        // Save the new objects to the database
        acTrans.Commit();
    }
}
```