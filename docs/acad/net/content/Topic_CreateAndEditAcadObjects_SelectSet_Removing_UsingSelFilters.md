# Настройка SelectionFilter

Критерии фильтра выбора (SelectionFilter) состоят из пар аргументов (TypeCode и Value) в структуре TypedValue. Первый аргумент, TypeCode, определяет тип фильтра (например, объект), а второй аргумент, Value, указывает значение, по которому выполняется фильтрация (например, тип "Окружность"). Тип фильтра — это код группы DXF, который определяет, какой фильтр следует использовать. Ниже перечислены некоторые из наиболее распространенных типов фильтров. 

| DXF code                | Filter type                                                                                                                                                         |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DxfCode.Start = 0       | Тип объекта (строка). Например, отрезок Line, окружность Circle                                                                                                     |
| DxfCode.BlockName =2    | Наименование определения блока (строка) для выборки Вхождений блоков с данным именем блока                                                                          |
| DxfCode.LayerName = 8   | Наименование слоя (строка)                                                                                                                                          |
| DxfCode.Visibility = 60 | Значение видимости объектов (integer). 0 = видимый, 1 = невидимый                                                                                                   |
| DxfCode.Color = 62      | Числовый индекс, соответствующий цвету - ColorIndex, от 0 до 256. Значение 0 = ПоБлоку. Значение 256 = ПоСлою. Отрицательное значение указывает, что слой выключен. |
| 67                      | Model/paper space indicator (Integer) Use 0 or omitted = model space, 1 = paper space.                                                                              |

Имя типа объекта можно получить с помощью следующего приведения: 

```csharp
System.Type t;
string dxfName =Autodesk.AutoCAD.Runtime.RXObject.GetClass(t).DxfName;
```

## Определение выбора по одному критерию фильтрации

Ниже приведен код, задающий выборку объектов только для типа объектов = Окружность. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
 
[CommandMethod("FilterSelectionSet")]
public static void FilterSelectionSet()
{
    // Get the current document editor
    Editor acDocEd = Application.DocumentManager.MdiActiveDocument.Editor;

    // Create a TypedValue array to define the filter criteria
    TypedValue[] acTypValAr = new TypedValue[1];
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Start, "CIRCLE"), 0);

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

## Определение выбора по нескольким критериям фильтрации

Ниже приведен код, задающий выборку объектов только для типа объектов = Окружность, расположенных на слое 0 и имеющих цвет = 5 (Синий) 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
 
[CommandMethod("FilterBlueCircleOnLayer0")]
public static void FilterBlueCircleOnLayer0()
{
    // Get the current document editor
    Editor acDocEd = Application.DocumentManager.MdiActiveDocument.Editor;

    // Create a TypedValue array to define the filter criteria
    TypedValue[] acTypValAr = new TypedValue[3];
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Color, 5), 0);
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Start, "CIRCLE"), 1);
    acTypValAr.SetValue(new TypedValue((int)DxfCode.LayerName, "0"), 2);

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
