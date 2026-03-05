Метод GetString запрашивает у пользователя строку в командной строке. Объект `PromptStringOptions` позволяет управлять вводом и отображением сообщения подсказки. Свойство `AllowSpaces` объекта PromptStringOptions определяет, разрешены или нет пробелы во вводимой Пользователем строке. Если установлено значение false, нажатие клавиши пробела завершает ввод. Пример ниже демонстрирует использование данного метода; требуется, чтобы ввод данных пользователем был завершен нажатием клавиши Enter (в строке ввода допускаются пробелы). Введенная строка отобразится в окне сообщения. 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Runtime;
 
[CommandMethod("GetStringFromUser")]
public static void GetStringFromUser()
{
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
 
    PromptStringOptions pStrOpts = new PromptStringOptions("\nEnter your name: ");
    pStrOpts.AllowSpaces = true;
    PromptResult pStrRes = acDoc.Editor.GetString(pStrOpts);
 
    Application.ShowAlertDialog("The name entered was: " +
                                pStrRes.StringResult);
}
```