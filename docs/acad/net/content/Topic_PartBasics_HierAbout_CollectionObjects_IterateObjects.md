# Перебор объектов коллекции

Для получения конкретного объекта коллекции, представленной таблицей можно использовать обращение к ней, как к словарю, указывая в качестве поискового строкового ключа наименование объекта. Для предварительной проверки, имеется ли в коллекции определение объекта целесообразно использование метода Has. Для словарей (DBDictionary) имеется только метод GetAt. 

```cs
//Обращение к таблице слоев
ObjectId acObjId;
if (acLyrTbl.Has("MyLayer")) acObjId = acLyrTbl["MyLayer"];
```

Для итеративного перебора объектов коллекции возможно использование цикла foreach. Существует устойчивое название "запись", которым обозначают объект коллекции, хранящейся в Таблице данных (подробнее о таблицах см. соответствующий раздел в статье [База данных чертежа](./Topic_PartBasics_HierAbout_Database.md). Подобные объекты-записи имеют специфичный тип, равный названию класса таблицы + суффикс Record. Для каждой из 11 таблиц существуют соответствующие классы-записи с суффиксами Record. Рассмотрим перебор слоев таблицы слоев, а также проверку, имеется ли среди таблицы слоев слой с фиксированным именем: 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("AddMyLayer")]
public static void AddMyLayer()
{
  // Get the current document and database, and start a transaction
  Document acDoc = Application.DocumentManager.MdiActiveDocument;
  Database acCurDb = acDoc.Database;

  using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
  {
      // Returns the layer table for the current database
      LayerTable acLyrTbl;
      acLyrTbl = acTrans.GetObject(acCurDb.LayerTableId,
                                   OpenMode.ForRead) as LayerTable;

      // Check to see if MyLayer exists in the Layer table
      if (acLyrTbl.Has("MyLayer") != true)
      {
          // Open the Layer Table for write
          acTrans.GetObject(acCurDb.LayerTableId, OpenMode.ForWrite);

          // Create a new layer table record and name the layer "MyLayer"
          using (LayerTableRecord acLyrTblRec = new LayerTableRecord())
          {
              acLyrTblRec.Name = "MyLayer";

              // Add the new layer table record to the layer table and the transaction
              acLyrTbl.Add(acLyrTblRec);
              acTrans.AddNewlyCreatedDBObject(acLyrTblRec, true);
          }

          // Commit the changes
          acTrans.Commit();
      }

      // Dispose of the transaction
  }
}
```
