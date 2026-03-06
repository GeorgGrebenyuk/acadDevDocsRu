# Добавление логических операций в фильтры

При указании нескольких критериев фиьтрации выбора nanoCAD предполагает, что выбранный объект должен соответствовать каждому критерию. Вы можете уточнить критерии фильтрации другими способами. Для числовых элементов можно указать операции сравнения (например, радиус круга должен быть больше или равен 5,0). А для всех элементов можно указать логические операции (например, для содержимого Text или MText). 

Используйте код DXF -4 или константу `DxfCode.Operator` для указания оператора сравнения в фильтре выбора. Оператор выражается в виде строки. Перечень допустимых операторов приведен в следующей таблице. 

| Operator | Описание                                              |
| -------- | ----------------------------------------------------- |
| "*"      | Любые значения (всегда true)                          |
| "="      | Точное соответствие                                   |
| "!="     | Точное не-соответствие                                |
| "/="     | Точное не-соответствие                                |
| "<>"     | Точное не-соответствие                                |
| "<"      | Менее, чем                                            |
| "<="     | Менее или равно, чем                                  |
| ">"      | Более, чем                                            |
| ">="     | Более или равно, чем                                  |
| "&"      | Побитовое И, только для групп целых чисел             |
| "&="     | Побитовое И (аналог &&), только для групп целых чисел |

Логические операторы в фильтре выбора также обозначаются кодом группы -4 или константой DxfCode.Operator, а оператор представляет собой строку, но операторы должны быть спарены. Открывающий оператор предваряется символом «меньше» (`<`), а замыкающий оператор сопровождается символом «больше» (`>`). В следующей таблице перечислены логические операторы, разрешенные для задания критериев фильтрации. 

| Начальный оператор | Содержимое                   | Замыкающий оператор |
| ------------------ | ---------------------------- | ------------------- |
| "<AND"             | Один или несколько операндов | "AND>"              |
| "<OR"              | Один или несколько операндов | "OR>"               |
| "<XOR"             | 2 операнда                   | "XOR>"              |
| "<NOT"             | 1 операнд                    | "NOT>"              |

## Выбор окружности с радиусом более или равно 5.0

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
 
[CommandMethod("FilterRelational")]
public static void FilterRelational()
{
    // Get the current document editor
    Editor acDocEd = Application.DocumentManager.MdiActiveDocument.Editor;

    // Create a TypedValue array to define the filter criteria
    TypedValue[] acTypValAr = new TypedValue[3];
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Start, "CIRCLE"), 0);
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Operator, ">="), 1);
    acTypValAr.SetValue(new TypedValue(40, 5), 2);

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

## Выбор объектов Тест и МТекст

В альтернативу использования фильтра типа 

```cs
TypedValue[] acTypValAr = new TypedValue[1];
acTypValAr[1] = new TypedValue((int)DxfCode.Start, "TEXT, MTEXT");
```

Можно записать это же условие с помощью операторов: 

```cs
using Teigha.Runtime;
using HostMgd.ApplicationServices;
using Teigha.DatabaseServices;
using HostMgd.EditorInput;
[CommandMethod("FilterForText")]
public static void FilterForText()
{
    // Get the current document editor
    Editor acDocEd = Application.DocumentManager.MdiActiveDocument.Editor;
    // Create a TypedValue array to define the filter criteria
    TypedValue[] acTypValAr = new TypedValue[4];
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Operator, "\<or"), 0);
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Start, "TEXT"), 1);
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Start, "MTEXT"), 2);
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Operator, "or\>"), 3);
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
