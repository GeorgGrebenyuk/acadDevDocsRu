Опорная сеть (GRID) - это вспомогательный инструмент для визуального измерения длины объектов (в AutoCAD включается клавишами F7 или Ctrl+G или командой GRID). При помощи API возможно настроить шаг сетки, шаг и тип привязки (ортогональная, изометрическая), После изменения настроек привязки и сетки для активного видового экрана следует использовать метод `Editor.UpdateTiledViewportsFromDatabase` для обновления отображения текущей области рисования. 

**Примечание**: Настройки привязки и сетки не влияют на точки, указанные через .NET API, но влияют на точки, указанные в области чертежа пользователем, если ему предлагается ввести данные с помощью таких методов, как GetPoint или GetEntity. 

## Изменение настроек сетки и привязки

Пример ниже иллюстрирует смену базовой точки привязки на (1,1) и угол привязки на 30 градусов. Включите видимость сетки и самостоятельно отрегулируйте расстояние между точками так, чтобы изменения были заметны. 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("ChangeGridAndSnap")]
public static void ChangeGridAndSnap()
{
  // Get the current database
  Document acDoc = Application.DocumentManager.MdiActiveDocument;
  Database acCurDb = acDoc.Database;
 
  // Start a transaction
  using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
  {
      // Open the active viewport
      ViewportTableRecord acVportTblRec;
      acVportTblRec = acTrans.GetObject(acDoc.Editor.ActiveViewportId,
                                        OpenMode.ForWrite) as ViewportTableRecord;
 
      // Turn on the grid for the active viewport
      acVportTblRec.GridEnabled = true;
 
      // Adjust the spacing of the grid to 1, 1
      acVportTblRec.GridIncrements = new Point2d(1, 1);
 
      // Turn on the snap mode for the active viewport
      acVportTblRec.SnapEnabled = true;
 
      // Adjust the snap spacing to 0.5, 0.5
      acVportTblRec.SnapIncrements = new Point2d(0.5, 0.5);
 
      // Change the snap base point to 1, 1
      acVportTblRec.SnapBase = new Point2d(1, 1);
 
      // Change the snap rotation angle to 30 degrees (0.524 radians)
      acVportTblRec.SnapAngle = 0.524;
 
      // Update the display of the tiled viewport
      acDoc.Editor.UpdateTiledViewportsFromDatabase();
 
      // Commit the changes and dispose of the transaction
      acTrans.Commit();
  }
}
```