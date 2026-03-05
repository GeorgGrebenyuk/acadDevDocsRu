Вы можете редактировать свойства замкнутых или незамкнутых сплайнов и даже преобразовать их в полилинии. Используйте следующие свойства и методы для редактирования сплайнов: 

* Degree : возвращает порядок (степень кривизны) сплайна; 

* EndFitTangent (StartFitTangent) : возвращает вектор касательной сплайна в последней (начальной) вершине; 

* FitTolerance : возвращает или задает точность аппроксимации кривой; 

* NumControlPoints : возвращает количество управляющих вершин у данного сплайна; 

* NumFitPoints : возвращает количество определяющих вершин у данного сплайна; 

**Методы для редактирования геометрии сплайна:** 

* InsertFitPointAt : задает определяющую вершину по данному индексу; 

* ElevateDegree : задает новый порядок (степень кривизны) сплайна; 

* GetControlPointAt : возвращает координаты управляющей вершины для заданного индекса (число управляющих точек хранится в значении свойства NumControlPoints); 

* GetFitPointAt : возвращает координаты определяющей вершины для заданного индекса (число определяющих точек хранится в значении свойства NumFitPoints). Чтобы получить все определяющие вершины вызовите свойство FitData, а у него :: метод GetFitPoints; 

* RemoveFitPointAt : удаляет определяющую вершину в заданной точке; 

* ReverseCurve : обращает направление сплайна; 

* SetControlPointAt : задает координаты управляющей вершины в заданной точке; 

* SetFitPointAt : задает координаты определяющей вершины в заданной точке; 

* SetWeightAt : задает вес определяющей точки сплайна (как каждая точка влияет на его форму: =1 не влияет, \> 1 сплайн "притягивается" к точке, \< 1 сплайн "отталкивается" от точки); 

**Свойства "только для чтения":**

* Area : площадь области, образуемой, если бы сплайн был бы замкнут; 

* Closed : возвращает флаг, замкнут ли сплайн в контур; 

* IsPeriodic : возвращает признак, является ли данный сплайн периодическим (замкнутая сплайн:кривая, в которой кривая и ее производные являются непрерывными в начальной/конечной точках); 

* IsPlanar : возвращает признак, является ли данный сплайн плоским; 

* IsRational : возвращает признак, является ли данный сплайн рациональным (используются такие веса в определяющих точках сплайна, что позволяет ему представлять точные конические сечения (окружности, эллипсы, параболы, гиперболы) и другие сложные кривые, которые не могут быть представлены обычными нерациональными сплайнами); 
  
  ## Редактирование управляющей вершины сплайна

В примере далее создается новый сплайн и затем изменяются координаты его первой определяющей точки 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("EditSpline")]
public static void EditSpline()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                        OpenMode.ForRead) as BlockTable;

        // Open the Block table record Model space for write
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;

        // Create a Point3d Collection
        Point3dCollection acPt3dColl = new Point3dCollection();
        acPt3dColl.Add(new Point3d(1, 1, 0));
        acPt3dColl.Add(new Point3d(5, 5, 0));
        acPt3dColl.Add(new Point3d(10, 0, 0));

        // Set the start and end tangency
        Vector3d acStartTan = new Vector3d(0.5, 0.5, 0);
        Vector3d acEndTan = new Vector3d(0.5, 0.5, 0);

        // Create a spline
        using (Spline acSpline = new Spline(acPt3dColl,
                                        acStartTan,
                                        acEndTan, 4, 0))
        {

            // Set a control point
            acSpline.SetControlPointAt(0, new Point3d(0, 3, 0));

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acSpline);
            acTrans.AddNewlyCreatedDBObject(acSpline, true);
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```