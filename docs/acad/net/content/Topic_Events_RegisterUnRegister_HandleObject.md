# События для объекта чертежа

События для объектов доступны, в основном, для класса DBObject, часть для Database. Они позволяют реагировать на действия с объектами -- добавление, редактирование, удаление. События, применимые к объектам, можно разбить на 2 большие группы - регистрируемые для конкретного объекта и на уровне всей базы данных чертежа сразу для любого объекта. 

* Cancelled : если открытие объекта на чтение или запись было прервано; 
* Copied : после того, как была создана копия объекта; 
* Erased : когда объект стал помеченным к удалению; 
* Goodbye : когда объект удаляется из памяти, поскольку связанная с ним база данных чертежа уничтожена; 
* Modified : при редактировании объекта; 
* ModifiedXData : когда изменяется подключенная к объекту XData; 
* ModifyUndone : cрабатывает при отмене предыдущих изменений, внесенных в объект; 
* ObjectClosed : при закрытии объекта; 
* OpenedForModify : при открытии на изменение (OpenMode.ForWrite); 
* Reappended : когда объект удаляется из базы данных после операции Undo и добавляется в БД через операцию Redo; 
* SubObjectModified : при изменении составляющей части объекта; 

События для Database: 

* ObjectAppended : когда объект добавляется в БД чертежа; 
* ObjectErased : при удалении объекта; 
* ObjectModified : при изменении объекта; 
* ObjectOpenedForModify : при открытии на изменение (OpenMode.ForWrite); 
* ObjectReappended : когда объект удаляется из базы данных после операции Undo и добавляется в БД через операцию Redo; 
* ObjectUnappended : когда объект удаляется из базы данных после операции Undo; 

В примере ниже приведен код, создающий некоторую полилинию и запоминающую её на уровне класса. К полилинии привязывается обработчик события Modified, при ручном редактировании полилинии в модели Пользователем будет выводиться модальное окно с величиной площади полилинии после редактирования. На другие полилинии этот обработчик распространяться не будет. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
// Global variable for polyline object
Polyline acPoly = null;
 
[CommandMethod("AddPlObjEvent")]
public void AddPlObjEvent()
{
  // Get the current document and database, and start a transaction
  Document acDoc = Application.DocumentManager.MdiActiveDocument;
  Database acCurDb = acDoc.Database;
 
  using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
  {
      // Open the Block table record for read
      BlockTable acBlkTbl;
      acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                   OpenMode.ForRead) as BlockTable;
 
      // Open the Block table record Model space for write
      BlockTableRecord acBlkTblRec;
      acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                      OpenMode.ForWrite) as BlockTableRecord;
 
      // Create a closed polyline
      acPoly = new Polyline();
      acPoly.AddVertexAt(0, new Point2d(1, 1), 0, 0, 0);
      acPoly.AddVertexAt(1, new Point2d(1, 2), 0, 0, 0);
      acPoly.AddVertexAt(2, new Point2d(2, 2), 0, 0, 0);
      acPoly.AddVertexAt(3, new Point2d(3, 3), 0, 0, 0);
      acPoly.AddVertexAt(4, new Point2d(3, 2), 0, 0, 0);
      acPoly.Closed = true;
 
      // Add the new object to the block table record and the transaction
      acBlkTblRec.AppendEntity(acPoly);
      acTrans.AddNewlyCreatedDBObject(acPoly, true);
 
      acPoly.Modified += new EventHandler(acPolyMod);
 
      // Save the new object to the database
      acTrans.Commit();
  }
}
 
[CommandMethod("RemovePlObjEvent")]
public void RemovePlObjEvent()
{
  if (acPoly != null)
  {
      // Get the current document and database, and start a transaction
      Document acDoc = Application.DocumentManager.MdiActiveDocument;
      Database acCurDb = acDoc.Database;
 
      using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
      {
          // Open the polyline for read
          acPoly = acTrans.GetObject(acPoly.ObjectId,
                                     OpenMode.ForRead) as Polyline;
 
          if (acPoly.IsWriteEnabled == false)
          {
              acTrans.GetObject(acPoly.ObjectId, OpenMode.ForWrite);
          }
 
          acPoly.Modified -= new EventHandler(acPolyMod);
          acPoly = null;
      }
  }
}
 
public void acPolyMod(object senderObj,
                      EventArgs evtArgs)
{
  Application.ShowAlertDialog("The area of " +
                              acPoly.ToString() + " is: " +
                              acPoly.Area);
}
```
