# Документ AutoCAD

Объект Document, который фактически является чертежом AutoCAD, обрабатывается через DocumentCollection. Объекты DocumentExtension и DocumentCollectionExtention используются для создания, открытия и закрытия файлов чертежей. Объект `Document` предоставляет доступ к объекту `Database`, который содержит все графические и большинство неграфических объектов AutoCAD. Вместе с тем, база данных чертежа Database может быть получена и без открытия документа при помощи следующей процедуры: 

```cs
Database db = new Database(false, true);
dwgDb.ReadDwgFile(pathToDwg, FileOpenMode.OpenForReadAndReadShare, false, null);
```

Наряду с объектом базы данных объект Document предоставляет доступ к строке состояния, окну, в котором открыт документ, специальным объектам Editor и TransactionManager. Класс `Editor` предоставляет доступ к функциям ввода-вывода данных от пользователя -- выбор точки, объектов, вывод сообщения в консоль и т.д. 

Класс `TransactionManager` используется для доступа к нескольким объектам базы данных в рамках одной операции, называемой транзакцией. Транзакции могут быть вложенными, а по завершении транзакции вы можете зафиксировать (Commit) или отменить (Abort) внесенные изменения. ActiveX-интерфейс, описывающий документ, называется `AutoCAD.AcadDocument` и может быть получен следующим приведением: 

```cs
Autodesk.AutoCAD.ApplicationServices.Document doc;
AutoCAD.AcadDocument docCOM = doc.GetAcadDocument() as AutoCAD.AcadDocument;
```
