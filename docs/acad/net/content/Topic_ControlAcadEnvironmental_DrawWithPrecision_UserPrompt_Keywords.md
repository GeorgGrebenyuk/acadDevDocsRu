# Запрос ключевых слов

Метод `GetKeywords` запрашивает у пользователя ввод ключевого слова в командной строке. Ключевым называется слово из предопределенного списка (заданного в свойстве `Keywords` объекта класса PromptKeywordOptions). 

**Примечание**: Символ подчеркивания («_») относится к служебным символам и не может использоваться в качестве ключевого слова или его части. В примере ниже запрашивается выбор ключевого слова Пользователем с запретом пропуска выбора (`AllowNone` = false), то есть нажатия Enter. Свойство Keywords используется для задания перечня ключевых слов. 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Runtime;
 
[CommandMethod("GetKeywordFromUser")]
public static void GetKeywordFromUser()
{
    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    PromptKeywordOptions pKeyOpts = new PromptKeywordOptions("");
    pKeyOpts.Message = "\nEnter an option ";
    pKeyOpts.Keywords.Add("Line");
    pKeyOpts.Keywords.Add("Circle");
    pKeyOpts.Keywords.Add("Arc");
    pKeyOpts.AllowNone = false;

    PromptResult pKeyRes = acDoc.Editor.GetKeywords(pKeyOpts);

    Application.ShowAlertDialog("Entered keyword: " +
                                pKeyRes.StringResult);
}
```

Удобнее использовать предопределенное значение ключевого слова (на случай, если пользователь нажмет на Enter без выбора значения) в этом случае рекомендуется в подсказке к методу, отображаемой в командной строке, указывать, какое из ключевых слов будет считаться по умолчанию. Более удобной для пользователя является подсказка с ключевым словом, которая предоставляет значение по умолчанию, если пользователь нажимает Enter (ввод NULL). Обратите внимание на незначительные изменения в следующем примере. Он отличается от предыдущего только наличием заданного свойство Keywords.Default и AllowNone = false: 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Runtime;
 
[CommandMethod("GetKeywordFromUser2")]
public static void GetKeywordFromUser2()
{
    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    PromptKeywordOptions pKeyOpts = new PromptKeywordOptions("");
    pKeyOpts.Message = "\nEnter an option ";
    pKeyOpts.Keywords.Add("Line");
    pKeyOpts.Keywords.Add("Circle");
    pKeyOpts.Keywords.Add("Arc");
    pKeyOpts.Keywords.Default = "Arc";
    pKeyOpts.AllowNone = true;

    PromptResult pKeyRes = acDoc.Editor.GetKeywords(pKeyOpts);

    Application.ShowAlertDialog("Entered keyword: " +
                                pKeyRes.StringResult);
}
```
