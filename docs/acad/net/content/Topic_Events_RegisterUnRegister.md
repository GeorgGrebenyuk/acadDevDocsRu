Для того, чтобы работать с событием необходимо создать его обработчик и связать его с объектом, для которого вы хотите отловить соответствующее событие. После завершения работы с отловом событий рекомендуется убрать этот обработчик, чтобы минимизировать конфликты с обработчиками других функций и приложений, уменьшить использование системных ресурсов CAD-средой. 

## Подписка на событие

Подписка на событие осуществляется добавлением нового обработчика для события. Обработчик требует некоторой процедуры, которая определена где-либо в вашем проекте (как правило, это некоторый метод класса). Большинство типов обработчиков в основном требуют 2 аргумента -- первый типа object, а второй -- возвращаемые аргументы для данного события. Регистрация события осуществляется с помощью оператора "+=" в C# 

В приведенном ниже коде регистрируется процедура с именем appSysVarChanged для события `SystemVariableChanged`. Процедура appSysVarChanged принимает два параметра: Object и SystemVariableChangedEventArgs. Объект SystemVariableChangedEventArgs возвращает имя системной переменной, измененной при регистрации события. 

## Отмена подписки на событие

Для отмены события необходимо удалить привязанный к нему обработчик, используется тот же синтаксис, что и для добавления события, за исключением того, что оператор для удаления для C# это `-=`. Пример ниже содержит загружаемый в приложение класс, в теле метода Initialize происходит подписка на событие, а в теле Terminate -- отмена подписки. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;

public class Loader : IExtensionApplication
{
    public void Initialize()
    {
        Application.SystemVariableChanged +=
            new SystemVariableChangedEventHandler(appSysVarChanged);
    }
    public void Terminate()
    {
        Application.SystemVariableChanged -=
            new SystemVariableChangedEventHandler(appSysVarChanged);
    }
    private void appSysVarChanged(object sender, SystemVariableChangedEventArgs e)
    {
        //...
    }
}
```