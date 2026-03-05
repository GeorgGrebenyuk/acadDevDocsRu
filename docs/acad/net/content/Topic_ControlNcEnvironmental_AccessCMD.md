Возможно отправлять команды непосредственно в командную строку используя метод `SendStringToExecute` (он отправляет на исполнение по одной строке). Передаваемая методу строка обязательно должна содержать аргументы (командной строки), перечисленные в порядке, ожидаемом последовательностью ввода данных со стороны выполняемой команды. Пустой пробел или ASCII-эквивалент возврата каретки в строке эквивалентен нажатию Enter на клавиатуре. В отличие от среды AutoLISP, вызов метода SendStringToExecute без аргумента недопустим. Команды, выполняемые с помощью SendStringToExecute, являются асинхронными и не вызываются до тех пор, пока команда .NET не завершится. Если вам нужно выполнить команду немедленно (синхронно), вы должны: 

* Использовать метод `SendCommand` (ActiveX API, метод у AcadDocument); 
* Вызвать нативный метод `acedCommand` или `acedCmd` из ObjectARX для команд из библиотек .NET или ObjectARX; 
* Вызвать нативный метод `acedInvoke` из ObjectARX для команд из AutoLISP; 

В примере ниже рисуется окружность с центром (2, 2, 0) и радиусом "4". Затем чертеж центрируется на всей видимой геометрии. Обратите внимание, что в конце строки есть пробел, который означает завершающий Enter для начала выполнения команды. 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.Runtime;
 
[CommandMethod("SendACommandToAutoCAD")]
public static void SendACommandToAutoCAD()
{
  Document acDoc = Application.DocumentManager.MdiActiveDocument;
 
  // Draws a circle and zooms to the extents or 
  // limits of the drawing
  acDoc.SendStringToExecute("._circle 2,2,0 4 ", true, false, false);
  acDoc.SendStringToExecute("._zoom _all ", true, false, false);
}
```

**Примечание**: Обратите внимание, что запись команды будет отличаться от  nanoCAD.