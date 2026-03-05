Объект DocumentCollection, возвращаемый через свойство DocumentManager статического класса Application предоставляет ряд событий по контролю за состоянием документа среди группы других документов в данной сессии приложения: 

* `DocumentActivated` : Событие, возникающее при переходе к данному dwg:чертежу. Соответствует функции ObjectARX `AcApDocManagerReactor.documentActivated()`; 
* `DocumentActivationChanged` : Событие, возникающее после событий `DocumentActivated` или `DocumentDestroyed`; 
* `DocumentBecameCurrent` : Событие, возникающее при переключении между открытыми dwg:документами. Событие возникает всегда, когда текущим становится другой документ; 
* `DocumentCreated` : Событие, возникающее после создания нового объекта типа `Document`. Соответствует функции ObjectARX API `AcApDocManagerReactor.documentCreated()`; 
* `DocumentCreateStarted` : Событие, возникающее перед созданием документа, когда база данных еще не доступна. Соответствует функции ObjectARX API `AcApDocManagerReactor.documentCreateStarted()`; 
* `DocumentCreationCanceled` : Событие, возникающее после отмены создания dwg-документа. Событие возникает, когда пользователь отменил создание dwg:документа. Данное событие может возникнуть только в режиме MDI и после события `DocumentCreateStarted`. Соответствует функции ObjectARX API `AcApDocManagerReactor.documentCreationCanceled()`; 
* `DocumentDestroyed` : Событие, возникающее, когда документ полностью закрыт и база данных, соответствующая этому документу,также уничтожена в памяти. Соответствует функции ObjectARX API `AcApDocManagerReactor.documentDestroyed()`; 
* `DocumentLockModeChanged` : Событие, возникающее при каждой блокировке/разблокировке dwg:документа. Вызов блокировки или разблокировки можно отличить. При разблокировке документа имя команды начинается с символа '#'. Блокировка документа может быть запрещена, а разблокировка — нет. Соответствует функции ObjectARX API `AcApDocManagerReactor.documentLockModeChanged()`; 
* `DocumentLockModeChangeVetoed` : Событие, возникающее при запрете блокировки dwg:документа. Попытка блокировки документа может быть запрещена реактором, получившим событие `DocumentLockModeChanged`. Если запрет произошел, все реакторы получат данное событие и все реакторы смогут получить информацию о запрете блокировки, даже если не все реакторы получили событие `DocumentLockModeChanged` до того, как будет запрещена блокировка. Соответствует функции ObjectARX API `AcApDocManagerReactor.documentLockModeChangeVetoed()`; 
* `DocumentLockModeWillChange` : Событие, возникающее перед изменением режима блокировки dwg:документа. Событие, возникающее перед тем, как будет изменен режим блокировки dwg-документа. Оно не может быть запрещено. Соответствует функции ObjectARX API `AcApDocManagerReactor.documentLockModeWillChange()`; 
* DocumentToBeActivated : Событие, возникающее перед активацией документа. Событие, генерируемое перед активацией документа. Соответствует функции ObjectARX API `AcApDocManagerReactor.documentToBeActivated()`; 
* DocumentToBeDeactivated : Событие, возникающее перед тем, как фокус переходит на иной dwg-документ . Соответствует функции ObjectARX API `AcApDocManagerReactor.documentToBeDeactivated()`;
* DocumentToBeDestroyed : Событие, возникающее перед уничтожением документа. Событие, возникающее перед уничтожением документа. Соответствует функции ObjectARX API `AcApDocManagerReactor.documentToBeDestroyed()`; 

<b>Примечание</b>: в nanoCAD .NET API не реализовано событие DocumentToBeDeactivated 

В примере ниже содержится пример подписки на событие DocumentActivated. Для запуска связанной с обработчиком события процедуры (вывода модального окна) создайте или переключитесь на новый чертеж в nanoCAD 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;

[CommandMethod("AddDocColEvent")]
public void AddDocColEvent()
{
  Application.DocumentManager.DocumentActivated +=
      new DocumentCollectionEventHandler(docColDocAct);
}
[CommandMethod("RemoveDocColEvent")]
public void RemoveDocColEvent()
{
  Application.DocumentManager.DocumentActivated :=
      new DocumentCollectionEventHandler(docColDocAct);
}
public void docColDocAct(object senderObj,
                         DocumentCollectionEventArgs docColDocActEvtArgs)
{
  Application.ShowAlertDialog(docColDocActEvtArgs.Document.Name +
                              " was activated.");
}
```