# Использование ОРТО-режима

При рисовании линий или перемещении объектов можно использовать режим Ortho, чтобы ограничить курсор горизонтальной или вертикальной осью. Ортогональное выравнивание зависит от текущего угла привязки и настроек ПСК. Режим Ortho работает с действиями, требующими указания второй точки, например, при использовании методов GetDistance или GetAngle. Режим Ortho можно использовать не только для установки вертикального или горизонтального выравнивания, но и для обеспечивания параллельности линий или создания новых линий на смещении от данной. С режимом Ortho рисование примитивов значительно ускоряется, особенно если требуется их перпендикулярность. Следующий код включает режим Ortho. В отличие от настроек сетки и привязки, информация о режиме Ortho хранится в базе данных чертежа, а не в активном видовом экране, поэтому специальных действий по обновлению выполнять не требуется. 

```cs
using Autodesk.AutoCAD.ApplicationServices;

[CommandMethod("TurnOnOrthoMode")]
public static void TurnOnOrthoMode()
{
    Application.DocumentManager.MdiActiveDocument.Database.Orthomode = true;
}
[CommandMethod("TurnOffOrthoMode")]
public static void TurnOffOrthoMode()
{
    Application.DocumentManager.MdiActiveDocument.Database.Orthomode = false;
}
```
