При запросе данных от Пользователя необходимо ограничить тип вводимой им информации, чтобы получить корректный ответ. В некоторых методах ввода можно получать как конкретное значение в зависимости от типа используемого метода, так и ключевое слово (используя свойство `Keywords` настроек ввода данных). Например, можно использовать метод `GetPoint`, чтобы пользователь указал точку или ответил ключевым словом. Именно так работают такие команды, как LINE, CIRCLE и PLINE. 

Пример ниже содержит инструкцию ввода численных данных от пользователя с помощью метода GetInteger, где может быть введено как число, так и выбрано ключевое слово из числа предопределенных. В AutoCAD при вызове этого метода командная строка будет выглядеть "Enter the size or [Big/Small/Regular] \<Regular\>:" 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Runtime;
 
[CommandMethod("GetIntegerOrKeywordFromUser")]
public static void GetIntegerOrKeywordFromUser()
{
    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    PromptIntegerOptions pIntOpts = new PromptIntegerOptions("");
    pIntOpts.Message = "\nEnter the size or ";

    // Restrict input to positive and non-negative values
    pIntOpts.AllowZero = false;
    pIntOpts.AllowNegative = false;

    // Define the valid keywords and allow Enter
    pIntOpts.Keywords.Add("Big");
    pIntOpts.Keywords.Add("Small");
    pIntOpts.Keywords.Add("Regular");
    pIntOpts.Keywords.Default = "Regular";
    pIntOpts.AllowNone = true;

    // Get the value entered by the user
    PromptIntegerResult pIntRes = acDoc.Editor.GetInteger(pIntOpts);

    if (pIntRes.Status == PromptStatus.Keyword)
    {
        Application.ShowAlertDialog("Entered keyword: " +
                                    pIntRes.StringResult);
    }
    else
    {
        Application.ShowAlertDialog("Entered value: " +
                                    pIntRes.Value.ToString());
    }
}
```