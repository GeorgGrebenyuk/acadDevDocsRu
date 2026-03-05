# Переименование набора состояний

Метод RenameLayerState предназначен для изменения имени набора состояний слоев.
Пример ниже содержит код для для переименовывания сохраненного набор состояний "ColorLinetype", созданного в примере раннее, в "OldColorLinetype". 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("RenameLayerState")]
public static void RenameLayerState()
{
    // Get the current document
    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    LayerStateManager acLyrStMan;
    acLyrStMan = acDoc.Database.LayerStateManager;

    string sLyrStName = "ColorLinetype";
    string sLyrStNewName = "OldColorLinetype";

    if (acLyrStMan.HasLayerState(sLyrStName) == true &&
        acLyrStMan.HasLayerState(sLyrStNewName) == false)
    {
        acLyrStMan.RenameLayerState(sLyrStName, sLyrStNewName);
    }
}
```
