# События документа Document

События для окна чертежа (класса Document) позволяют отлавливать действия, совершаемые на уровне документа AutoCAD: 

* BeginDocumentClose : Событие, генерируемое перед закрытием документа. Событие, генерируемое перед закрытием документа. Позволяет разработчику вызвать метод DocumentBeginCloseEventArgs.Veto() при обработке этого события, чтобы остановить закрытие документа. Соответствует функции ObjectARX API AcEditorReactor.docCloseAborted(); 
* CloseAborted : Событие, возникающее после того, как в обработчике отменяется закрытие документа. Это событие попадет во все реакторы, которые получают событие beginDocClose. Соответствует функции ObjectARX API AcEditorReactor.docCloseAborted(); 
* CloseWillStart : Событие, возникающее после BeginDocumentClose и перед закрытием чертежа. Соответствует функции ObjectARX API AcEditorReactor.docCloseWillStart(); 
* CommandCancelled : Событие, означающее, что команда cmdStr была отменена пользователем или другим приложением, и не смогла быть успешно завершена. Соответствует функции ObjectARX API AcEditorReactor.commandcanceled(); 
* CommandFailed : Событие, означающее что команда cmdStr аварийно завершена. Соответствует функции ObjectARX API AcEditorReactor.commandFailed(); 
* CommandWillStart : Событие, возникающее перед началом выполнения команды cmdStr. Соответствует функции ObjectARX API AcEditorReactor.commandWillStart(); 
* ImpliedSelectionChanged : Событие, возникающее при изменении набора предварительно выбранных объектов в документе (pickfirst). Оно возникает для всех действий, добавляющих или удаляющих объекты из этого набора. Действия, меняющие геометрию или свойства объектов из этого набора (сдвиг, удлинение и т.д.) не вызывают этого события. Соответствует функции ObjectARX API AcEditorReactor.pickfirstModified(); 
* LispCancelled : Событие, возникающее при прерывании выполнения lisp выражения в документе. Соответствует функции ObjectARX API AcEditorReactor.lispCancelled(); 
* LispEnded : Событие, возникающее при прерывании выполнения lisp выражения в документе. Соответствует функции ObjectARX API AcEditorReactor.lispEnded(); 
* LispWillStart : Событие, возникающее перед началом выполнения lisp выражения в документе. Соответствует функции ObjectARX API AcEditorReactor.lispWillStart(); 
* UnknownCommand : Событие, возникающее при вызове команды, которую nanoCAD не распознает. Соответствует функции ObjectARX API AcEditorReactor.unknownCommand(); 
* ViewChanged : Событие возникает, когда параметры текущего вида были изменены; 

<b>Примечание</b>: в nanoCAD .NET API не реализованы события BeginDwgOpen, CommandEnded, EndDwgOpen, LayoutSwitched.

Пример ниже содержит код, подписывающийся на событие закрытия документа. Перед закрытием будет выведено диалоговое окно, при выборе в окне команды "No" закрытие документа будет прекращено. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;

[CommandMethod("AddDocEvent")]
public void AddDocEvent()
{
  // Get the current document
  Document acDoc = Application.DocumentManager.MdiActiveDocument;
  acDoc.BeginDocumentClose +=
      new DocumentBeginCloseEventHandler(docBeginDocClose);
}
[CommandMethod("RemoveDocEvent")]
public void RemoveDocEvent()
{
  // Get the current document
  Document acDoc = Application.DocumentManager.MdiActiveDocument;
  acDoc.BeginDocumentClose :=
      new DocumentBeginCloseEventHandler(docBeginDocClose);
}
public void docBeginDocClose(object senderObj,
                             DocumentBeginCloseEventArgs docBegClsEvtArgs)
{
  // Display a message box prompting to continue closing the document
  if (System.Windows.Forms.MessageBox.Show(
                       "The document is about to be closed." +
                       "\nDo you want to continue?",
                       "Close Document",
                       System.Windows.Forms.MessageBoxButtons.YesNo) ==
                       System.Windows.Forms.DialogResult.No)
  {
      docBegClsEvtArgs.Veto();
  }
}
```
