Стили печати используются для переопределения настроек отображения объекта в печатаемом виде. Стиль печати, назначенный листу, хранится в свойстве CurrentStyleSheet. Для назначения стиля печати объекту `PlotSettings` используется метод `SetCurrentStyleSheet` объекта `PlotSettingsValidator`. ​​Для определения типа стиля печати можно использовать свойство `PlotStyleMode` текущей базы данных. Список всех доступных стилей печати можно получить с помощью метода `GetPlotStyleSheetList` объекта `PlotSettingsValidator`. 

Перечисленные стили печати совпадают с теми, которые отображаются в диалоговых окнах «Печать» или «Параметры листа». 

В примере ниже выводятся все доступные стили печати в командную строку 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

// Lists the available plot styles
[CommandMethod("PlotStyleList")]
public static void PlotStyleList()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    acDoc.Editor.WriteMessage("\nPlot styles: ");

    foreach (string plotStyle in PlotSettingsValidator.Current.GetPlotStyleSheetList())
    {
        // Output the names of the available plot styles
        acDoc.Editor.WriteMessage("\n  " + plotStyle);
    }
}
```