События приложения AutoCAD (вернее, для статического класса Application) позволяют отлавливать действия с окном самого AutoCAD и действиями на уровне всего приложения: 

* BeginDoubleClick : при двукратном нажатии на ЛКМ; 
* BeginQuit : перед закрытием nanoCAD; 
* Idle : срабатывает при загрузке AutoCAD (появление меню); 
* QuitAborted : при попытке прервать завершение работы AutoCAD; 
* QuitWillStart : после срабатывания события BeginQuit и перед завершением работы AutoCAD; 
* SystemVariableChanged : после изменения системной переменной; 
* SystemVariableChanging : перед изменением системной переменной; 

<b>Примечание</b>: в nanoCAD .NET API не реализованы события BeginCustomizationMode, DisplayingCustomizeDialog, DisplayingDraftingSettingsDialog, DisplayingOptionDialog, EndCustomizationMode, EnterModal, LeaveModal, PreTranslateMessage 

В примере ниже приведен код, осуществляющий подписку на событие `SystemVariableChanged`. После того, как системная переменная была изменена, появится модальное диалоговое окно с сообщением, какое новое значение у измененной переменной. После запуска метода AddAppEvent для запуска связанной с обработчиком события процедуры (вывода модального окна с новым значением переменной) измените вручную в AutoCAD значение любой системной переменной 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;

[CommandMethod("AddAppEvent")]
public void AddAppEvent()
{
    Application.SystemVariableChanged +=
        new SystemVariableChangedEventHandler(appSysVarChanged);
}
[CommandMethod("RemoveAppEvent")]
public void RemoveAppEvent()
{
    Application.SystemVariableChanged :=
        new SystemVariableChangedEventHandler(appSysVarChanged);
}
public void appSysVarChanged(object senderObj,
                             Autodesk.AutoCAD.ApplicationServices.
                             SystemVariableChangedEventArgs sysVarChEvtArgs)
{
    object oVal = Application.GetSystemVariable(sysVarChEvtArgs.Name);
    // Display a message box with the system variable name and the new value
    Application.ShowAlertDialog(sysVarChEvtArgs.Name + " was changed." +
                                "\\nNew value: " + oVal.ToString());
}
```