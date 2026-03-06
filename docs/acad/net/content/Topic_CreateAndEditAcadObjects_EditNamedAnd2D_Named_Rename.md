# Переименовывание объектов

Возможно переименовывать объекты, чтобы сохранить структуру имен или избежать конфликтов с именами объектов из других вставленных или прикрепленных внешними ссылками чертежах. Свойство Name используется для получения текущего имени или изменения имени именованного объекта. Вы можете переименовать любой именованный объект, за исключением тех, которые зарезервированы AutoCAD, например, слой 0 или тип линии CONTINUOUS. Имена могут содержать до 255 символов. Помимо букв и цифр, имена могут содержать пробелы (хотя AutoCAD удаляет пробелы, которые появляются непосредственно перед и после имени) и любые специальные символы, не используемые Microsoft® Windows® или AutoCADдля других целей. Специальные символы, которые нельзя использовать: 

* символы меньше и больше (\< \>); 
* косые и обратные косые черты (/ \\); 
* кавычки ("); 
* двоеточие (:); 
* точка с запятой (;); 
* вопросительный знак (?); 
* запятая (,); 
* звездочка (*); 
* вертикальная черта (|); 
* знак равенства (=); 
* одинарные кавычки ('). 
  Также нельзя использовать специальные символы, созданные с помощью шрифтов Unicode (эмоджи и т.д.). В коде ниже создается копия слоя "0" и переименовывается в "MyLayer" 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("RenameLayer")]
public static void RenameLayer()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Returns the layer table for the current database
        LayerTable acLyrTbl;
        acLyrTbl = acTrans.GetObject(acCurDb.LayerTableId,
                                        OpenMode.ForWrite) as LayerTable;

        // Clone layer 0 (copy it and its properties) as a new layer
        LayerTableRecord acLyrTblRec;
        acLyrTblRec = acTrans.GetObject(acLyrTbl["0"],
                                        OpenMode.ForRead).Clone() as LayerTableRecord;

        // Change the name of the cloned layer
        acLyrTblRec.Name = "MyLayer";

        // Add the cloned layer to the Layer table and transaction
        acLyrTbl.Add(acLyrTblRec);
        acTrans.AddNewlyCreatedDBObject(acLyrTblRec, true);

        // Save changes and dispose of the transaction
        acTrans.Commit();
    }
}
```

**Примечание**: в nanoCAD наблюдается разное поведение функций при попытке задать неподдерживаемы символы, где-то это возможно, где-то возникнет фатальная ошибка. Лучший вариант -- осуществлять фильтрация у себя на стороне кола приложения, а не полагаться на API приложения.
