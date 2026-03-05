Имя устройства печати, назначенное листу, хранится в свойстве PlotConfigurationName. Имя будет содержать одно из системных устройств вывода, если не назначено устройство по умолчанию. Вы можете получить список всех возможных устройств вывода из числа системных и AutoCAD, получив их список через метод `GetPlotDeviceList` объекта `PlotSettingsValidator`. 

В примере ниже показан использование данного метода, устройства выводятся списком в командную строку. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.PlottingServices;

// Lists the available plotters (plot configuration [PC3] files)
[CommandMethod("PlotterList")]
public static void PlotterList()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    acDoc.Editor.WriteMessage("\nPlot devices: ");

    foreach (string plotDevice in PlotSettingsValidator.Current.GetPlotDeviceList())
    {
        // Output the names of the available plotter devices
        acDoc.Editor.WriteMessage("\n  " + plotDevice);
    }
}
```