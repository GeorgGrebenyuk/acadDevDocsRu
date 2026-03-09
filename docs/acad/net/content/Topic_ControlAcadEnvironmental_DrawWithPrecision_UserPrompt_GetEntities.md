# Запрос нескольких объектов

Выбор нескольких объектов осуществляется с помощью метода `Editor.GetSelection` с перегрузкой для `SelectionFilter`.

`SelectionFilter` задается с помощью массива `TypedValue`, как и `ResultBuffer`. Если необходимо выбрать несколько типов, то их надо задавать либо в 1 строку для DxfCode.Start с перечислением запятыми, либо с помощью [логических операторов](./Topic_CreateAndEditAcadObjects_SelectSet_Removing_Operators.md). Выбор для нескольких условий см. в [статье про SelectionFilter](./Topic_CreateAndEditAcadObjects_SelectSet_Removing_UsingSelFilters.md).

Для быстрого перехода от типа объекта (`typeof(Polyline)`) к соответствующему ему `DxfName` для задания в фильтре `TypedValue`) можно воспользоваться следующим приведением:

```csharp
Type t;
string dxfName = Autodesk.AutoCAD.Runtime.RXObject.GetClass(t).DxfName;
```

В примере ниже осуществляется выбор нескольких полилиний и окружностей с выводом в командную строку количества отфильтрованных объектов.

```csharp
using System.Linq;
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;

[CommandMethod("SelectPolylines")]
public void SelectPolylines()
{
    Document doc = Application.DocumentManager.MdiActiveDocument;
    Type[] typesToSelect = new Type[]
    {
                typeof(Polyline), typeof(Circle)
    };

    string[] entNamesArr = typesToSelect.Select(t => RXObject.GetClass(t).DxfName).Distinct().ToArray();
    TypedValue[] tmpFilterArgs = new TypedValue[]
    {
                new TypedValue((int)DxfCode.Start, string.Join(",", entNamesArr))
    };

    SelectionFilter filter = new SelectionFilter(tmpFilterArgs.ToArray());
    PromptSelectionOptions settings = new PromptSelectionOptions()
    {
        MessageForAdding = "Select polylines and circles"
    };
    PromptSelectionResult result = doc.Editor.GetSelection(settings, filter);
    if (result.Status != PromptStatus.OK) return;
    doc.Editor.WriteMessage($"\nThere were selected: {result.Value.Count}" + " entities\n");
}
```
