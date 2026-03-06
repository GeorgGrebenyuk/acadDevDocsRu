# Управление текущим видом

Доступ к текущему виду видового экрана (ВЭ далее) в пространстве модели или листа осуществляется с помощью метода Editor.GetCurrentView. Метод GetCurrentView возвращает объект ViewTableRecord, у которого можно отредактировать масштабирование, положение и ориентацию вида. Для применения новых настроек, измененный объект ViewTableRecord необходимо задать текущему виду в активном ВЭ с помощью метода Editor.SetCurrentView. Для изменения доступны следующие настройки вида: 

* CenterPoint : Центр вида в координатах DCS (см. [термины](\Topic_3D_ConvertCoords.md)); 
* Height : Высота вида в координатах DCS (см. [термины](%5CTopic_3D_ConvertCoords.md)); 
* Target : Целевая точка перспективной проекции для данного ВЭ; 
* ViewDirection : вектор от точки Target до камеры вида в координатах DCS (см. [термины](%5CTopic_3D_ConvertCoords.md)); 
* ViewTwist : угол поворота в радианах для вида; 
* Width : Ширина вида в координатах DCS (см. [термины](%5CTopic_3D_ConvertCoords.md)); 
  Увеличение высоты (Height) или ширины (Width) приводит к уменьшению масштаба отображения объектов; уменьшение :: к увеличению масштаба. 
* ## Функции API для управления текущим видом
  
  Пример ниже содержит общие функции, используемые в примерах далее. Функция Zoom принимает четыре параметра для выполнения масштабирования по заданной границе (точки pMin, pMax), точке центра вида чертежа, а также параметр масштабирования вида чертежа в заданном масштабном значении. Процедура Zoom ожидает, что все значения координат будут предоставлены в координатах WCS (см. [термины](%5CTopic_3D_ConvertCoords.md)). В коде содержится инструкция чтения свойства Database.TileMode (оно же значение системной переменной TILEMODE), указывающей какое пространство сейчас активно (модель = 1 (true), лист = 0 (false)). Также в коде используется значение переменной CVPORT, возвращающей идентификатор текущего ВЭ. Если её значение = 1, то это признак общего ВЭ (т.е. когда экран не разделен никаким образом на несколько экранов). 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.Geometry;
 
static void Zoom(Point3d pMin, Point3d pMax, Point3d pCenter, double dFactor)
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    int nCurVport = System.Convert.ToInt32(Application.GetSystemVariable("CVPORT"));

    // Get the extents of the current space when no points 
    // or only a center point is provided
    // Check to see if Model space is current
    if (acCurDb.TileMode == true)
    {
        if (pMin.Equals(new Point3d()) == true && 
            pMax.Equals(new Point3d()) == true)
        {
            pMin = acCurDb.Extmin;
            pMax = acCurDb.Extmax;
        }
    }
    else
    {
        // Check to see if Paper space is current
        if (nCurVport == 1)
        {
            // Get the extents of Paper space
            if (pMin.Equals(new Point3d()) == true && 
                pMax.Equals(new Point3d()) == true)
            {
                pMin = acCurDb.Pextmin;
                pMax = acCurDb.Pextmax;
            }
        }
        else
        {
            // Get the extents of Model space
            if (pMin.Equals(new Point3d()) == true && 
                pMax.Equals(new Point3d()) == true)
            {
                pMin = acCurDb.Extmin;
                pMax = acCurDb.Extmax;
            }
        }
    }

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Get the current view
        using (ViewTableRecord acView = acDoc.Editor.GetCurrentView())
        {
            Extents3d eExtents;

            // Translate WCS coordinates to DCS
            Matrix3d matWCS2DCS;
            matWCS2DCS = Matrix3d.PlaneToWorld(acView.ViewDirection);
            matWCS2DCS = Matrix3d.Displacement(acView.Target - Point3d.Origin) * matWCS2DCS;
            matWCS2DCS = Matrix3d.Rotation(-acView.ViewTwist, 
                                            acView.ViewDirection, 
                                            acView.Target) * matWCS2DCS;

            // If a center point is specified, define the min and max 
            // point of the extents
            // for Center and Scale modes
            if (pCenter.DistanceTo(Point3d.Origin) != 0)
            {
                pMin = new Point3d(pCenter.X - (acView.Width / 2),
                                    pCenter.Y - (acView.Height / 2), 0);

                pMax = new Point3d((acView.Width / 2) + pCenter.X,
                                    (acView.Height / 2) + pCenter.Y, 0);
            }

            // Create an extents object using a line
            using (Line acLine = new Line(pMin, pMax))
            {
                eExtents = new Extents3d(acLine.Bounds.Value.MinPoint,
                                            acLine.Bounds.Value.MaxPoint);
            }

            // Calculate the ratio between the width and height of the current view
            double dViewRatio;
            dViewRatio = (acView.Width / acView.Height);

            // Tranform the extents of the view
            matWCS2DCS = matWCS2DCS.Inverse();
            eExtents.TransformBy(matWCS2DCS);

            double dWidth;
            double dHeight;
            Point2d pNewCentPt;

            // Check to see if a center point was provided (Center and Scale modes)
            if (pCenter.DistanceTo(Point3d.Origin) != 0)
            {
                dWidth = acView.Width;
                dHeight = acView.Height;

                if (dFactor == 0)
                {
                    pCenter = pCenter.TransformBy(matWCS2DCS);
                }

                pNewCentPt = new Point2d(pCenter.X, pCenter.Y);
            }
            else // Working in Window, Extents and Limits mode
            {
                // Calculate the new width and height of the current view
                dWidth = eExtents.MaxPoint.X - eExtents.MinPoint.X;
                dHeight = eExtents.MaxPoint.Y - eExtents.MinPoint.Y;

                // Get the center of the view
                pNewCentPt = new Point2d(((eExtents.MaxPoint.X + eExtents.MinPoint.X) * 0.5),
                                            ((eExtents.MaxPoint.Y + eExtents.MinPoint.Y) * 0.5));
            }

            // Check to see if the new width fits in current window
            if (dWidth > (dHeight * dViewRatio)) dHeight = dWidth / dViewRatio;

            // Resize and scale the view
            if (dFactor != 0)
            {
                acView.Height = dHeight * dFactor;
                acView.Width = dWidth * dFactor;
            }

            // Set the center of the view
            acView.CenterPoint = pNewCentPt;

            // Set the current view
            acDoc.Editor.SetCurrentView(acView);
        }

        // Commit the changes
        acTrans.Commit();
    }
}
```
