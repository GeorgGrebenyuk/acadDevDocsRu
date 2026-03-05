При определении функции AutoLISP (LISP) используется атрибут `LispFunction` (полное имя Autodesk.AutoCAD.Runtime.LispFunctionAttribute). Атрибут LispFunction ожидает строковое значение для использования в качестве глобального имени определяемой функции AutoLISP. Наряду с глобальным именем функции структура LispFunction может принимать те же значения, что и CommandMethod (о нём см. статью раннее). 

```cs
[LispFunction("DisplayFullName")]
public static void DisplayFullName(ResultBuffer rbArgs)
{
  //...
}
```

Вызов из-под LISP: 

```cs
(displayfullname "First" "Last")
```

## Получение значений, переданных в LISP-функцию

Используйте цикл foreach для перебора значений, возвращаемых в ResultBuffer функцией AutoLISP. [ResultBuffer](/Topic_CreateAndEditNcObjects_ResultBuffer.md) - это коллекция объектов TypedValue. Свойство TypeCode объекта TypedValue можно использовать для определения типа значения для каждого значения, переданного в функцию AutoLISP. Свойство Value используется для возврата значения объекта TypedValue. Поддерживаются следующие типы данных: 

* Boolean или bool 

* Double или double 

* Integer или int 

* Null или void 

* ObjectId 

* Point2d 

* Point3d 

* ResultBuffer 

* SelectionSet 

* String или string 

* TypedValue 
  
  ## Пример реализации метода

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

public class Loader
{
    [LispFunction("DisplayFullName")]
    public static void DisplayFullName(ResultBuffer rbArgs)
    {
        if (rbArgs != null)
        {
            string strVal1 = "";
            string strVal2 = "";
            int nCnt = 0;
            foreach (TypedValue rb in rbArgs)
            {
                if (rb.TypeCode == (int)HostMgd.Runtime.LispDataType.Text)
                {
                    switch (nCnt)
                    {
                        case 0:
                            strVal1 = rb.Value.ToString();
                            break;
                        case 1:
                            strVal2 = rb.Value.ToString();
                            break;
                    }
                    nCnt = nCnt + 1;
                }
            }
            Application.DocumentManager.MdiActiveDocument.Editor.
               WriteMessage("\\nName: " + strVal1 + " " + strVal2);
        }
    }
}
```

Пример кода выше определяет LISP-функцию с именем DisplayFullName. В то время как в .NET-проекте метод принимает только одно значение (ResultBuffer), соответствующая функция в AutoLISP ожидает 2 строковых значения для получения правильного вывода в .NET (см. реализацию). Загрузите скомпилированную библиотеку классов в AutoCAD и затем обратитесь к команде из-под LISP: 

```cs
(displayfullname "First" "Last")
```

Выводом в консоль будут следующие данные: 

```cs
Name: First Last
```