# Получение и редактирование настроек печати

В примере ниже показывается процесс получения настроек печати для текущего листа и их изменение 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.PlottingServices;
 
// Changes the plot settings for a layout directly
[CommandMethod("ChangeLayoutPlotSettings")]
public static void ChangeLayoutPlotSettings()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Reference the Layout Manager
        LayoutManager acLayoutMgr = LayoutManager.Current;

        // Get the current layout and output its name in the Command Line window
        Layout acLayout = acTrans.GetObject(acLayoutMgr.GetLayoutId(acLayoutMgr.CurrentLayout),
                                            OpenMode.ForRead) as Layout;

        // Output the name of the current layout and its device
        acDoc.Editor.WriteMessage("\nCurrent layout: " + acLayout.LayoutName);

        acDoc.Editor.WriteMessage("\nCurrent device name: " + acLayout.PlotConfigurationName);

        // Get a copy of the PlotSettings from the layout
        using (PlotSettings acPlSet = new PlotSettings(acLayout.ModelType))
        {
            acPlSet.CopyFrom(acLayout);

            // Update the PlotConfigurationName property of the PlotSettings object
            PlotSettingsValidator acPlSetVdr = PlotSettingsValidator.Current;
            acPlSetVdr.SetPlotConfigurationName(acPlSet, "DWG To PDF.pc3", "ANSI_B_(11.00_x_17.00_Inches)");

            // Zoom to show the whole paper
            acPlSetVdr.SetZoomToPaperOnUpdate(acPlSet, true);

            // Update the layout
            acTrans.GetObject(acLayoutMgr.GetLayoutId(acLayoutMgr.CurrentLayout), OpenMode.ForWrite);
            acLayout.CopyFrom(acPlSet);
        }

        // Output the name of the new device assigned to the layout
        acDoc.Editor.WriteMessage("\nNew device name: " + acLayout.PlotConfigurationName);

        // Save the new objects to the database
        acTrans.Commit();
    }

    // Update the display
    acDoc.Editor.Regen();
}
```

**Примечание**: метод SetPlotConfigurationName, задающий листу определенный формат для данного устройства печати, в nanoCAD в некоторых случаях может выбрасывать ошибку eInvalidInput.
