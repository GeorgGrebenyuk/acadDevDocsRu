# Работа со словарями

Словари - это специальные неграфические объекты, имеющие структуру "ключ:значение"; ключём выступают строки, значением - ObjectId.

Для проверки, имеет ли словарь элемент с данным строковым ключем имеется метод `Has(string)`

В явном виде (объектами класса `DBDictionary`) словари нигде не хранятся, их необходимо получать через ObjectId и приведением к классу `DBDictionary`.

В чертеже имеются постоянные словари, описывающие служебные [коллекции объектов чертежа](./Topic_PartBasics_HierAbout_CollectionObjects.md).

У прочих объектов, наследующих `DBObject` по умолчанию словарей может не быть, если свойство `DBObject.ExtensionDictionary` возвращает ObjectId.Null, то словарь необходимо создать служебным методом `DBObject.CreateExtensionDictionary`, после этого свойство `ExtensionDictionary` должно указать на корректный ObjectId.

Ниже приведен расширенный пример регистрации в чертеже приложения `SEMANTIC_APP`, создании для объекта словаря, записи в словарь пользовательского словаря `SEMANTICS` с набором `Xrecord`, значением `XData` которого являются пользовательские строковые свойства, сохраненные под приложением `SEMANTIC_APP`:

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using System.Collections.Generic;

private const string SEMANTIC_APP = "SEMANTIC_APP";
private const string SEMANTIC_DIСT = "SEMANTICS";
private void checkRegApp()
{
    Database cadDb = Application.DocumentManager.MdiActiveDocument.Database;
    using (Transaction cadTrans = cadDb.TransactionManager.StartTransaction())
    {
        RegAppTable acRegAppTbl;
        acRegAppTbl = cadTrans.GetObject(cadDb.RegAppTableId,
                                              OpenMode.ForRead) as RegAppTable;
        // Проверить наличие SEMANTIC_APP
        if (acRegAppTbl.Has(SEMANTIC_APP) == false)
        {
            using (RegAppTableRecord acRegAppTblRec = new RegAppTableRecord())
            {
                acRegAppTblRec.Name = SEMANTIC_APP;
                cadTrans.GetObject(cadDb.RegAppTableId, OpenMode.ForWrite);
                acRegAppTbl.Add(acRegAppTblRec);
                cadTrans.AddNewlyCreatedDBObject(acRegAppTblRec, true);
            }
        }

        cadTrans.Commit();
    }
}
private void saveObjectProps(ObjectId dwgEntId, Dictionary<string, string> properties)
{
    checkRegApp();
    Database cadDb = Application.DocumentManager.MdiActiveDocument.Database;
    using (Transaction cadTrans = cadDb.TransactionManager.StartTransaction())
    {
        RegAppTable acRegAppTbl;
        acRegAppTbl = cadTrans.GetObject(cadDb.RegAppTableId,
                                              OpenMode.ForRead) as RegAppTable;
        // Проверить наличие SEMANTIC_APP
        if (acRegAppTbl.Has(SEMANTIC_APP) == false)
        {
            using (RegAppTableRecord acRegAppTblRec = new RegAppTableRecord())
            {
                acRegAppTblRec.Name = SEMANTIC_APP;
                cadTrans.GetObject(cadDb.RegAppTableId, OpenMode.ForWrite);
                acRegAppTbl.Add(acRegAppTblRec);
                cadTrans.AddNewlyCreatedDBObject(acRegAppTblRec, true);
            }
        }

        DBObject dwgEnt = cadTrans.GetObject(dwgEntId, OpenMode.ForWrite);

        if (dwgEnt.ExtensionDictionary == ObjectId.Null) dwgEnt.CreateExtensionDictionary();
        DBDictionary? entDict = cadTrans.GetObject(dwgEnt.ExtensionDictionary, OpenMode.ForWrite) as DBDictionary;
        if (entDict == null) return;


        // Если словарь уже существует, удалим его
        ObjectId propsDictId;
        if (entDict.Contains(SEMANTIC_DIСT))
        {
            entDict.Remove(SEMANTIC_DIСT);
        }

        DBDictionary propsDict = new DBDictionary();
        entDict.SetAt(SEMANTIC_DIСT, propsDict);
        cadTrans.AddNewlyCreatedDBObject(propsDict, true);
        propsDictId = propsDict.ObjectId;



        propsDict = (DBDictionary)cadTrans.GetObject(propsDictId, OpenMode.ForWrite);

        // Создаем Xrecord для всех значений свойств
        int indexCounter = 0;
        foreach (var propValueInfo in properties)
        {
            string propKey = $"Property_{indexCounter}";
            ObjectId xRecordId;

            Xrecord xrec = new Xrecord();
            propsDict.SetAt(propKey, xrec);
            cadTrans.AddNewlyCreatedDBObject(xrec, true);
            xRecordId = xrec.ObjectId;

            Xrecord propValueInfoRecord = (Xrecord)cadTrans.GetObject(xRecordId, OpenMode.ForWrite);
            using (ResultBuffer propValueInfoRecord_RB = new ResultBuffer())
            {
                propValueInfoRecord_RB.Add(new TypedValue((int)DxfCode.ExtendedDataRegAppName, SEMANTIC_APP));
                propValueInfoRecord_RB.Add(new TypedValue((int)DxfCode.ExtendedDataAsciiString, propValueInfo.Key));
                propValueInfoRecord_RB.Add(new TypedValue((int)DxfCode.ExtendedDataAsciiString, propValueInfo.Value)); //
                propValueInfoRecord.XData = propValueInfoRecord_RB;
            }
            indexCounter++;
        }
        cadTrans.Commit();
    }
}

private void listObjectProperies(ObjectId entId)
{
    Document doc = Application.DocumentManager.MdiActiveDocument;
    Database cadDb = doc.Database;
    using (Transaction cadTrans = cadDb.TransactionManager.StartTransaction())
    {
        // Получаем словарь объекта, если его нет -- то создаем
        DBObject dwgEnt = cadTrans.GetObject(entId, OpenMode.ForWrite);

        DBDictionary? entDict = cadTrans.GetObject(dwgEnt.ExtensionDictionary, OpenMode.ForRead) as DBDictionary;
        if (entDict == null)
        {
            doc.Editor.WriteMessage("У объекта отсутствуют данные");
            return;
        }

        if (!entDict.Contains(SEMANTIC_DIСT))
        {
            if (entDict == null)
            {
                doc.Editor.WriteMessage("У объекта отсутствуют данные для " + SEMANTIC_APP);
                return;
            }
        }
        ObjectId propsDictId = entDict.GetAt(SEMANTIC_DIСT);
        DBDictionary? propsDict = cadTrans.GetObject(propsDictId, OpenMode.ForRead) as DBDictionary;
        if (propsDict == null)
        {
            doc.Editor.WriteMessage("Не удалось привести к словарю");
            return;
        }

        doc.Editor.WriteMessage($"\nProperties for " + entId.ToString());
        foreach (var propValueInfoRaw in propsDict)
        {
            Xrecord? propValueInfoDef = cadTrans.GetObject(propValueInfoRaw.Value, OpenMode.ForRead) as Xrecord;

            if (propValueInfoDef == null) continue;
            ResultBuffer propValueInfoDefData = propValueInfoDef.GetXDataForApplication(SEMANTIC_APP);
            if (propValueInfoDefData == null) continue;
            {
                var propArray = propValueInfoDefData.AsArray();

                doc.Editor.WriteMessage($"\nProperty " +
                    $"Name:{propArray[1].Value} Value:{propArray[2].Value}");
            }
        }
        doc.Editor.WriteMessage($"\nEnd Properties!\n");
    }
}

[CommandMethod("SaveExtProperties")]
public void DemoSaveProperties()
{
    Document doc = Application.DocumentManager.MdiActiveDocument;
    PromptEntityOptions selOpts = new PromptEntityOptions("Select entity");
    selOpts.SetRejectMessage("Ent is not valid");
    selOpts.AddAllowedClass(typeof(Entity), false);
    PromptEntityResult selResult = doc.Editor.GetEntity(selOpts);
    if (selResult.Status != PromptStatus.OK) return;

    saveObjectProps(selResult.ObjectId, new Dictionary<string, string>()
        {
            {"Handle", selResult.ObjectId.Handle.ToString() },
            {"DxfName", selResult.ObjectId.ObjectClass.DxfName }
        });
}

[CommandMethod("ListExtProperties")]
public void DemoListExtProperties()
{
    Document doc = Application.DocumentManager.MdiActiveDocument;
    PromptEntityOptions selOpts = new PromptEntityOptions("Select entity");
    selOpts.SetRejectMessage("Ent is not valid");
    selOpts.AddAllowedClass(typeof(Entity), false);
    PromptEntityResult selResult = doc.Editor.GetEntity(selOpts);
    if (selResult.Status != PromptStatus.OK) return;

    listObjectProperies(selResult.ObjectId);
}
```
