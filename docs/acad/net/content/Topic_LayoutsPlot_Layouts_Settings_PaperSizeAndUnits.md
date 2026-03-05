Выбор размера (формата) бумаги зависит от используемого для вывода устройства или плоттера. Каждое устройство имеет свой стандартный список доступных форматов бумаги, который можно получить с помощью метода `GetCanonicalMediaNameList` у класса `PlotSettingsValidator` (получается через статическое поля класса Current). Другой метод GetLocaleMediaName можно использовать для отображения локализованного наименования формата, какой доступен в диалоговых окнах со стороны UI. Формат бумаги, назначенный листу можно запросить с помощью свойства CanonicalMediaName у объекта Layout. 

Вы также можете получить единицы измерения листа с помощью свойства PlotPaperUnits. Это свойство возвращает одно из трех значений, определенных перечислением PlotPaperUnit: дюймы, миллиметры или пиксели. Если ваше устройство печати настроено для растрового вывода, размер вывода будет возвращен в пикселях. Задать единицы измерения можно с помощью метода SetPlotPaperUnits класса PlotSettingsValidator. 

В примере ниже показывается размеров бумаги для конфигурации "DWF6 ePlot.pc3"

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.PlottingServices;

// Lists the available local media names for a specified plot configuration (PC3) file
[CommandMethod("PlotterLocalMediaNameList")]
public static void PlotterLocalMediaNameList()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    using(PlotSettings plSet = new PlotSettings(true))
    {
        PlotSettingsValidator acPlSetVdr = PlotSettingsValidator.Current;

        // Set the Plotter and page size
        acPlSetVdr.SetPlotConfigurationName(plSet, "DWF6 ePlot.pc3",
                                            "ANSI_A_(8.50_x_11.00_Inches)");

        acDoc.Editor.WriteMessage("\nCanonical and Local media names: ");

        int cnt = 0;

        foreach (string mediaName in acPlSetVdr.GetCanonicalMediaNameList(plSet))
        {
            // Output the names of the available media for the specified device
            acDoc.Editor.WriteMessage("\n  " + mediaName + " | " +
                                      acPlSetVdr.GetLocaleMediaName(plSet, cnt));

            cnt = cnt + 1;
        }
    }
}
```