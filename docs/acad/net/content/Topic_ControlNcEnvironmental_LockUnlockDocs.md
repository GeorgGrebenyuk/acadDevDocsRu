Запросы на изменение объектов чертежа или получение доступа к приложению AutoCAD могут возникать от различных загруженных приложений. Для избегания конфликтов одновременного доступа к данным имеется возможность блокировки документа перед его изменением. Несмотря на то, что блокируется фактически база данных, термин блокировки связан с документом. Если этого не сделать, то при выполнении некоторых операций могут произойти ошибки синхронизации базы данных чертежа, что может привести к потере данных или появлению фатальной ошибки. Рекомендуется использовать блокировку документа во всех следующих случаях: 

* Взаимодействие с AutoCAD из-под модальных диалоговых окон; 
* Доступ к другому документу из-под текущего документа; 
* Использование COM API; 
* В командах с флагом `CommandFlags.Session`; 

Например, при добавлении сущности в пространство модели или листа документа, отличного от текущего, целевой документ необходимо заблокировать. Для этого используется метод Document.LockDocument для документа, который вы хотите заблокировать. При вызове метода LockDocument возвращается объект DocumentLock. После того как вы закончили изменять заблокированный документ (вернее, его базу данных), вам нужно разблокировать его. Чтобы разблокировать документ, вызовите метод Dispose у объекта DocumentLock. Вы также можете использовать оператор using с объектом DocumentLock, когда оператор using завершится, база данных будет разблокирована. 

```cs
Document acNewDoc;
using (DocumentLock acLckDoc = acNewDoc.LockDocument())
{ ... }
```

<b>Примечание</b>: При работе в контексте команды, не использующей CommandFlags.Session, не нужно блокировать базу данных для текущего документа перед его изменением. 

## Блокировка БД чертежа перед вставкой объекта в модель

Код ниже создает новый документ и рисует в его пространстве модели окружность. После того, как документ был создан, база данных нового чертежа блокируется, далее в неё добавляется окружность, после чего блокировка снимается, а документ становится текущим. 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("LockDoc", CommandFlags.Session)]
public static void LockDoc()
{
    // Create a new drawing
    DocumentCollection acDocMgr = Application.DocumentManager;
    Document acNewDoc = acDocMgr.Add("acad.dwt");
    Database acDbNewDoc = acNewDoc.Database;

    // Lock the new document
    using (DocumentLock acLckDoc = acNewDoc.LockDocument())
    {
        // Start a transaction in the new database
        using (Transaction acTrans = acDbNewDoc.TransactionManager.StartTransaction())
        {
            // Open the Block table for read
            BlockTable acBlkTbl;
            acBlkTbl = acTrans.GetObject(acDbNewDoc.BlockTableId,
                                            OpenMode.ForRead) as BlockTable;

            // Open the Block table record Model space for write
            BlockTableRecord acBlkTblRec;
            acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                            OpenMode.ForWrite) as BlockTableRecord;

            // Create a circle with a radius of 3 at 5,5
            using (Circle acCirc = new Circle())
            {
                acCirc.Center = new Point3d(5, 5, 0);
                acCirc.Radius = 3;

                // Add the new object to Model space and the transaction
                acBlkTblRec.AppendEntity(acCirc);
                acTrans.AddNewlyCreatedDBObject(acCirc, true);
            }

            // Save the new object to the database
            acTrans.Commit();
        }

        // Unlock the document
    }

    // Set the new document current
    acDocMgr.MdiActiveDocument = acNewDoc;
}
```