# Удаление набора состояний

Метод `DeleteLayerState` предназначен для удаления набора состояний слоев из чертежа. Приведенный ниже код удаляет набор состояний с именем "ColorLinetype", если он существует в чертеже: 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
 
[CommandMethod("RemoveLayerState")]
public static void RemoveLayerState()
{
    // Get the current document
    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    LayerStateManager acLyrStMan;
    acLyrStMan = acDoc.Database.LayerStateManager;

    string sLyrStName = "ColorLinetype";

    if (acLyrStMan.HasLayerState(sLyrStName) == true)
    {
        acLyrStMan.DeleteLayerState(sLyrStName);
    }
}
```