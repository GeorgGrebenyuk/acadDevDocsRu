# Использование транзакций для получения доступа к объектам

Менеджер транзакций доступен через свойство TransactionManager у объекта базы данных чертежа (Database). После обращения к менеджеру транзакций вы можете использовать один из следующих методов для запуска или получения существующей транзакции: 

* `StartTransaction` : Запускает новую транзакцию, создавая новый экземпляр объекта `Transaction`. Используйте этот метод, когда вам нужно редактировать объект несколько раз в течение транзакции и иметь возможность применить или откатить изменения на любом шаге в ходе вложенных транзакций (если таковые будут); 
* `StartOpenCloseTransation` : создает объект `OpenCloseTransaction`, который ведет себя аналогично объекту Transaction, но дополнительно оборачивает объекты методами Open и Close объекта, что упрощает закрытие всех открытых объектов вместо необходимости явного закрытия каждого открытого объекта. Рекомендуется для использования во вспомогательных или служебных функциях, которые могут быть вызваны неизвестное количество раз, а также при работе с большинством из имеющихся обработчиками событий;

Получив объект Transaction или OpenCloseTransaction, используйте метод GetObject для открытия хранящегося в БД чертежа объекта для чтения или записи. Метод `GetObject` вернет объект типа `DBObject` и вам необходимо будет самостоятельно привести его к нужному типу при помощи приведения **as**. Все объекты, открытые во время транзакции, закрываются в конце транзакции. Чтобы завершить транзакцию, вызовите метод `Dispose` объекта транзакции. Если вы используете объект транзакции в составе конструкции `using`, вам не нужно вызывать метод `Dispose.` Перед уничтожением транзакции необходимо зафиксировать все внесенные изменения с помощью метода `Commit`. Если изменения не будут зафиксированы (применен метод `Commit`) до уничтожения транзакции, все сделанные изменения будут откачены к состоянию, в котором они находились до начала транзакции. К этому же поведению приведет и использование метода Abort (его вы можете использовать, например, во вложенных транзакциях или на определенном шаге в текущей транзакции. Можно запустить более одной транзакции. Количество активных транзакций можно получить с помощью свойства NumberOfActiveTransactions объекта TransactionManager, а самую последнюю транзакцию можно получить с помощью свойства TopTransaction. Транзакции могут быть вложены одна в другую, чтобы откатить некоторые изменения, сделанные во время выполнения ранних процедур. 

## Запрос объектов

В примере ниже показывается, как открывать и считывать данные об объектах при помощи транзакции. Сперва метод GetObject используется для получения таблицы блоков BlockTable, а из неё -- записи, соответствующей пространству модели. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
 
[CommandMethod("StartTransactionManager")]
public static void StartTransactionManager()
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
 
        // Open the Block table record Model space for read
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForRead) as BlockTableRecord;
 
        // Step through the Block table record
        foreach (ObjectId asObjId in acBlkTblRec)
        {
            acDoc.Editor.WriteMessage("\nDXF name: " + asObjId.ObjectClass.DxfName);
            acDoc.Editor.WriteMessage("\nObjectID: " + asObjId.ToString());
            acDoc.Editor.WriteMessage("\nHandle: " + asObjId.Handle.ToString());
            acDoc.Editor.WriteMessage("\n");
        }
 
        // Dispose of the transaction
    }
}
```

## Добавление нового объекта в БД

В примере ниже показывается, как добавить в БД определение окружности. Сперва метод `GetObject` используется для получения таблицы блоков `BlockTable`, а из неё -- записи, соответствующей пространству модели с режимом записи; для ней вызываются методы `AppendEntity` и `AddNewlyCreatedDBObject` для добавления новой окружности в пространство модели. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("AddNewCircleTransaction")]
public static void AddNewCircleTransaction()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartOpenCloseTransaction())
    {
        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
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

        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
