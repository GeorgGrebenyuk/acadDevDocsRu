# Работа с системными переменными

Доступ к чтению и записи системных переменных осуществляется через методы статического класса Autodesk.AutoCAD.ApplicationServices.Application: 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;

[CommandMethod("TestSysVars")]
public static void TestSysVars()
{
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Application.SetSystemVariable("ANNOTATIVEDWG", 0);
    acDoc.Editor.WriteMessage("Current ANNOTATIVEDWG = " + Application.GetSystemVariable("ANNOTATIVEDWG"));
    Application.SetSystemVariable("ANNOTATIVEDWG", 1);
    aDoc.Editor.WriteMessage("New ANNOTATIVEDWG = " + Application.GetSystemVariable("ANNOTATIVEDWG"));
}
```
