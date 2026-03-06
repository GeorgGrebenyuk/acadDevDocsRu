# Использование регулярных выражений

Имена символов и строки в фильтрах выбора могут содержать шаблоны с регулярными выражениями 

В следующей таблице приведены регулярные выражения, распознаваемые nanoCAD, и их значение:

| Символ             | Описание                                                                                                                                                     |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| # (pound)          | Соответствует любой одной цифре                                                                                                                              |
| @ (at)             | Соответствует любому одиночному символу алфавита                                                                                                             |
| . (period)         | Соответствует любому одиночному не-алфавитному символу                                                                                                       |
| * (asterisk)       | Соответствует любой последовательности символов, включая пустую строку, и может использоваться в любом месте поисковой строки: в начале, середине или конце. |
| ? (question mark)  | Соответствует любому одиночному символу                                                                                                                      |
| ~ (tilde)          | Если это первый символ в поисковом критерии, он соответствует всему, кроме поискового критерия                                                               |
| [...]              | Соответствует любому из символов, заключенных в данные [...]                                                                                                 |
| [~...]             | Не соответствует любому из символов, заключенных в данные [...]                                                                                              |
| - (hyphen)         | Используется внутри скобок для указания диапазона значений для одного символа.                                                                               |
| , (comma)          | Разделяет 2 поисковых критерия                                                                                                                               |
| \` (reverse quote) | Исключает специальные символы (читает следующий символ буквально)                                                                                            |

Используйте обратную кавычку (\`) для случая, если символ должен восприниматься буквально. Например, чтобы указать, что в набор выбора должен быть включен только анонимный блок с именем "*U2", используйте значение "\`*U2".

## Выборка MText с заданным значением

Ниже приведен код, производящий выборку объектов типа MText, содержащих буквосочетание "The" 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
 
[CommandMethod("FilterMtextWildcard")]
public static void FilterMtextWildcard()
{
    // Get the current document editor
    Editor acDocEd = Application.DocumentManager.MdiActiveDocument.Editor;

    // Create a TypedValue array to define the filter criteria
    TypedValue[] acTypValAr = new TypedValue[2];
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Start, "MTEXT"), 0);
    acTypValAr.SetValue(new TypedValue((int)DxfCode.Text, "*The*"), 1);

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
