Методы класса Editor, а также классов из пространств имён Autodesk.AutoCAD.Geometry, Autodesk.AutoCAD.Runtime позволяют быстро работать с выборкой точек из чертежа и/или производить некоторые математические вычисления. Среди них: 

* Получение расстояния между двумя плоскими или трехмерными точками через методы GetDistanceTo или DistanceTo; 
* Получение угла относительно оси X используя 2 плоские точки и метод GetVectorTo со свойством Angle для возвращаемого значения; 
* Преобразование значения угла из строкового в число double с методом StringToAngle; 
* Преобразование значения угла из числа double в строку с методом AngleToString; 
* Преобразование расстояния из строки в число double с помощью метода StringToDistance; 
* Вычисление расстояния между двумя точками, введенными пользователем, с помощью метода GetDistance; 

<b>Примечание</b>: AutoCAD .NET API не содержит методов для расчета точки для заданных удаления и углу поворота (полярные координаты) и для преобразования координат между разными ПСК. Для этого используйте ActiveX API: методы Utility.PolarPoint и Utility.TranslateCoordinates, либо их численные реализации на стороне .NET (см. второй пример ниже). 

## Получение угла относительно оси X

В примере ниже идет расчет вектора между двумя точками и определение угла относительно оси X 

```cs
[CommandMethod("AngleFromXAxis")]
public static void AngleFromXAxis()
{
    Point2d pt1 = new Point2d(2, 5);
    Point2d pt2 = new Point2d(5, 2);
    Application.ShowAlertDialog("Angle from XAxis: " +
                                pt1.GetVectorTo(pt2).Angle.ToString());
}
```

## Определение полярных координат точки

Пример ниже вычисляет координаты точки относительно данной базовой точки, угла и расстояния. 

```cs
using System;

using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.Geometry;

using Autodesk.AutoCAD.Interop;

static Point2d PolarPoints(Point2d pPt, double dAng, double dDist)
{
    return new Point2d(pPt.X + dDist * Math.Cos(dAng),
                       pPt.Y + dDist * Math.Sin(dAng));
}
static Point3d PolarPoints(Point3d pPt, double dAng, double dDist)
{
    return new Point3d(pPt.X + dDist * Math.Cos(dAng),
                       pPt.Y + dDist * Math.Sin(dAng),
                       pPt.Z);
}
//Реализация через расчетные методы
[CommandMethod("PolarPoints")]
public static void PolarPoints()
{
    Point2d pt1 = PolarPoints(new Point2d(5, 2), 0.785398, 12);
    Application.ShowAlertDialog("\\nPolarPoint: " +
                                "\\nX = " + pt1.X +
                                "\\nY = " + pt1.Y);
    Point3d pt2 = PolarPoints(new Point3d(5, 2, 0), 0.785398, 12);
    Application.ShowAlertDialog("\\nPolarPoint: " +
                                "\\nX = " + pt2.X +
                                "\\nY = " + pt2.Y +
                                "\\nZ = " + pt2.Z);
}
//Реализация через ActiveX
[CommandMethod("PolarPoints2")]
public static void PolarPoints2()
{
    double[] basePnt = new double[] { 5, 2, 0 };
    double angle = 0.785398;
    double distance = 12;
    Document doc = Application.DocumentManager.MdiActiveDocument;
    AcadDocument docCOM = doc.GetAcadDocument() as AcadDocument;
    var polarPnt = (double[])docCOM.Utility.PolarPoint(basePnt, angle, distance);
    Application.ShowAlertDialog("\\nPolarPoint: " +
                                "\\nX = " + polarPnt[0] +
                                "\\nY = " + polarPnt[1] +
                                "\\nZ = " + polarPnt[2]);
}
```

## Вычисление расстояния между двумя точками по методу GetDistance

```cs
[CommandMethod("GetDistanceBetweenTwoPoints")]
public static void GetDistanceBetweenTwoPoints()
{
  Document acDoc = Application.DocumentManager.MdiActiveDocument;
  PromptDoubleResult pDblRes;
  pDblRes = acDoc.Editor.GetDistance("\\nPick two points: ");
  Application.ShowAlertDialog("\\nDistance between points: " +
                              pDblRes.Value.ToString());
}
```