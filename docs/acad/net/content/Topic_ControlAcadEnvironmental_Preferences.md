# Установка параметров приложения

AutoCAD .NET API не предоставляет полного доступа к редактированию параметров приложения, как со стороны UI, доступных в окне `_options`. Доступ к этим параметрам осуществляется через ActiveX API для объекта, возвращаемого из свойства Preferences объекта Application. 

```cs
AutoCAD.AcadPreferences pref = Application.Preferences as AutoCAD.AcadPreferences;
```

Получив COM-объект Preferences, можно получить доступ к девяти объектам, описываемых соответствующими интерфейсами, каждый из которых представляет собой вкладку диалогового окна Options. Эти объекты предоставляют доступ ко всем хранящимся в реестре параметрам диалогового окна «Параметры». С помощью свойств этих объектов можно настроить многие параметры AutoCAD. К этим объектам относятся (в скобках приведены свойства AutoCAD.AcadPreferences, по которым можно получить соответствующие объекты): 

* PreferencesDisplay (Display); 
* PreferencesDrafting (Drafting);
* PreferencesFiles (Files); 
* PreferencesOpenSave (OpenSave);
* PreferencesOutput (Output);
* PreferencesProfiles (Profiles); 
* PreferencesSelection (Selection); 
* PreferencesSystem (System);
* PreferencesUser (User);

Код ниже меняет цвет фона в пространстве модели на новый цвет 

```cs
using Autodesk.AutoCAD.ApplicationServices;

[CommandMethod("EditColor")]
public static void EditColor()
{
    // Access the Preferences object
    AutoCAD.AcadApplication acApp = Application.AcadApplication as AutoCAD.AcadApplication;
    AutoCAD.AcadPreferences acPrefComObj = acApp.Preferences;
    //Edit GraphicsWinModelBackgrndColor
    AutoCAD.AcadPreferencesDisplay PreferencesDisplay = acPrefComObj.Display;
    PreferencesDisplay.GraphicsWinModelBackgrndColor = 182070;
}
```

Код ниже задает полный размер перекрестию курсора

```csharp
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.Interop;
 
[CommandMethod("PrefsSetCursor")]
public static void PrefsSetCursor()
{
    // This example sets the crosshairs for the drawing window
    // to full screen.
 
    // Access the Preferences object
    AcadPreferences acPrefComObj = (AcadPreferences)Application.Preferences;
 
    // Use the CursorSize property to set the size of the crosshairs
    acPrefComObj.Display.CursorSize = 100;
}
```
