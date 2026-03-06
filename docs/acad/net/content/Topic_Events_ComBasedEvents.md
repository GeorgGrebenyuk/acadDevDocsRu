# Подписка на события из ActiveX (COM)

AutoCAD ActiveX (COM) API содержит некоторую функциональность, отсутствующую в настоящем .NET API, там также есть возможность подписки на события, но этот процесс будет выглядеть немного по-другому, подписываться будет необходимо на соответствующие события у интерфейсов. В примере ниже приводится процесс подписки на событие NewDrawing, срабатывающее после создания нового документа в AutoCAD. 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.Interop;

AcadApplication acAppCom;
[CommandMethod("AddCOMEvent")]
public void AddCOMEvent()
{
    // Set the global variable to hold a reference to the application and
    // register the BeginFileDrop COM event
    acAppCom = Application.AcadApplication as AcadApplication;
    acAppCom.NewDrawing +=
        new _DAcadApplicationEvents_NewDrawingEventHandler(appNewDrawing);
}
[CommandMethod("RemoveCOMEvent")]
public void RemoveCOMEvent()
{
    // Unregister the COM event handle
    acAppCom.NewDrawing -=
        new _DAcadApplicationEvents_NewDrawingEventHandler(appNewDrawing);
    acAppCom = null;
}
public void appNewDrawing()
{
    Application.ShowAlertDialog("Drawing " + Application.DocumentManager.MdiActiveDocument.Name + " is now active!");
}
```
