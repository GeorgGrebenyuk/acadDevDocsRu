Внешние приложения могут добавлять к объектам AutoCAD такие данные, как текстовые строки, числовые значения, 3D-точки, значения расстояний и имена слоев. Эти данные называются расширенными данными или xdata. Вы можете фильтровать объекты, содержащие расширенные данные для заданного приложения. 

Код в примере ниже содержит выборку окружностей, содержащих XData для приложения с именем MY_APP 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
 
[CommandMethod("FilterXdata")]
public static void FilterXdata()
{
    // Get the current document editor
    Editor acDocEd = Application.DocumentManager.MdiActiveDocument.Editor;

    // Create a TypedValue array to define the filter criteria
    TypedValue[] acTypValAr = new TypedValue[2];
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Start, "Circle"), 0);
    acTypValAr.SetValue(new TypedValue((int)DxfCode.ExtendedDataRegAppName, 
                                        "MY_APP"), 1);

    // Assign the filter criteria to a SelectionFilter object
    SelectionFilter acSelFtr = new SelectionFilter(acTypValAr);

    // Request for objects to be selected in the drawing area
    PromptSelectionResult acSSPrompt;
    acSSPrompt = acDocEd.GetSelection(acSelFtr);

    // If the prompt status is OK, objects were selected
    if (acSSPrompt.Status == PromptStatus.OK)
    {
        SelectionSet acSSet = acSSPrompt.Value;

        Application.ShowAlertDialog("Number of objects selected: " +
                                    acSSet.Count.ToString());
    }
    else
    {
        Application.ShowAlertDialog("Number of objects selected: 0");
    }
}
```