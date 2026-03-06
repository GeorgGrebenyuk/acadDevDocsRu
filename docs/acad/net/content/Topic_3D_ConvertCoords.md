# Преобразования координат

Метод TransformBy также может выполнять преобразования координат из одной ПСК в другую, для этого у структуры матрицы трансформации Matrix3d имеется метод AlignCoordinateSystem, требующий указания нескольких аргументов: 

* Координаты точки начала исходной системы координат; 
* Три вектора в пространстве, задающие оси ПСК по компонентам X, Y, Z исходной системы координат; 
* Координаты точки начала целевой системы координат; 
* Три вектора в пространстве, задающие оси ПСК по компонентам X, Y, Z целевой системы координат; 

В случае плоской матрицы (Matrix2d), векторов будет по два, а точка начала будет представлена плоской точкой, а не трехмерной. Необходимо также ввести некоторые термины по системам координат: 

* WCS (World coordinate system, МСК) : Мировая система координат. Все остальные системы координат определяются относительно WCS, она которая никогда не изменяется. Значения, измеренные относительно WCS, остаются постоянными при изменении других систем координат. Все точки, передаваемые в методы и свойства .NET API, выражаются в WCS, если не указано иное; 
* UCS (User coordinate system , ПСК) : Пользовательская система координат (UCS). UCS используются для упрощения задач разработки чертежей. Все точки, передаваемые командам nanoCAD, включая точки, возвращаемые различными функциями, являются точками в текущей ПСК (если пользователь не поставил перед ними * в командной строке). Если вы хотите, чтобы ваше приложение отправляло координаты в WCS, OCS или DCS командам nanoCAD, вы должны сначала преобразовать их в UCS (ПСК), вызвав метод преобразования, а затем преобразовать объект Point3d или Point2d с помощью метода TransformBy, представляющего значение компонентов координат; 
* OCS (Object coordinate system) :также известная, как система координат элемента или ECS: значения точек, заданные определенными методами и свойствами для объектов Polyline2d и Polyline, выражаются в этой системе координат относительно объекта. Эти точки обычно преобразуются в WCS, текущую UCS или текущую DCS в зависимости от предполагаемого использования объекта. И наоборот, точки в WCS, UCS или DCS должны быть преобразованы в OCS перед записью в базу данных с помощью тех же свойств. При преобразовании координат в OCS или из OCS необходимо учитывать нормаль OCS; 
* DCS (Display coordinate system): система координат, в которую объекты преобразуются при отрисовке на экране. Начало DCS находится в точке, хранимой в системной переменной TARGET, а направление оси Z соответствует направлению данного видового экрана (ВЭ). Другими словами, ВЭ всегда является плоским видом для данной DCS. 

Для получения матрицы преобразования между мировыми координатами и DCS можно использовать следующий код: 

```cs
Document acDoc;
Database acCurDb;
using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
{
    // Get the current view
    using (ViewTableRecord acView = acDoc.Editor.GetCurrentView())
    {
        Extents3d eExtents;
        // Translate WCS coordinates to DCS
        Matrix3d matWCS2DCS;
        matWCS2DCS = Matrix3d.PlaneToWorld(acView.ViewDirection);
        matWCS2DCS = Matrix3d.Displacement(acView.Target : Point3d.Origin) * matWCS2DCS;
        matWCS2DCS = Matrix3d.Rotation(:acView.ViewTwist,
                                        acView.ViewDirection,
                                        acView.Target) * matWCS2DCS;
    }
}
```

* PSDCS (Paper space DCS) : Система координат листа. По сути, это двумерное преобразование, где координаты X и Y отмасштабированы относительно целевой СК (здесь, DCS). Поэтому ее можно использовать для определения коэффициента масштабирования между двумя системами координат. Координаты в данной СК могут быть преобразованы только в DCS модели и аналогично обратно; 

## Преобразование из OCS в WCS

В примере ниже создается полилиния в пространстве модели. Выводится информация, какие координаты у первой вершины полилинии в системе координат полилинии и в мировой системе координат 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("TranslateCoordinates")]
public static void TranslateCoordinates()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table record for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                     OpenMode.ForRead) as BlockTable;

        // Open the Block table record Model space for write
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;

        // Create a 2D polyline with two segments (3 points)
        using (Polyline2d acPoly2d = new Polyline2d())
        {
            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acPoly2d);
            acTrans.AddNewlyCreatedDBObject(acPoly2d, true);

            // Before adding vertexes, the polyline must be in the drawing
            Point3dCollection acPts2dPoly = new Point3dCollection();
            acPts2dPoly.Add(new Point3d(1, 1, 0));
            acPts2dPoly.Add(new Point3d(1, 2, 0));
            acPts2dPoly.Add(new Point3d(2, 2, 0));
            acPts2dPoly.Add(new Point3d(3, 2, 0));
            acPts2dPoly.Add(new Point3d(4, 4, 0));

            foreach (Point3d acPt3d in acPts2dPoly)
            {
                Vertex2d acVer2d = new Vertex2d(acPt3d, 0, 0, 0, 0);
                acPoly2d.AppendVertex(acVer2d);
                acTrans.AddNewlyCreatedDBObject(acVer2d, true);
            }

            // Set the normal of the 2D polyline
            acPoly2d.Normal = new Vector3d(0, 1, 2);

            // Get the first coordinate of the 2D polyline
            Point3dCollection acPts3d = new Point3dCollection();
            Vertex2d acFirstVer = null;

            foreach (ObjectId acObjIdVert in acPoly2d)
            {
                acFirstVer = acTrans.GetObject(acObjIdVert,
                                               OpenMode.ForRead) as Vertex2d;

                acPts3d.Add(acFirstVer.Position);

                break;
            }

            // Get the first point of the polyline and 
            // use the eleveation for the Z value
            Point3d pFirstVer = new Point3d(acFirstVer.Position.X,
                                            acFirstVer.Position.Y,
                                            acPoly2d.Elevation);

            // Translate the OCS to WCS
            Matrix3d mWPlane = Matrix3d.WorldToPlane(acPoly2d.Normal);
            Point3d pWCSPt = pFirstVer.TransformBy(mWPlane);

            Application.ShowAlertDialog("The first vertex has the following " +
                                        "coordinates:" +
                                        "\nOCS: " + pFirstVer.ToString() +
                                        "\nWCS: " + pWCSPt.ToString());
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```
