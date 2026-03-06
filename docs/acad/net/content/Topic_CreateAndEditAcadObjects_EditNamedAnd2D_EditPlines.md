# Редактирование полилиний

2D- и 3D-полилинии, прямоугольники, многоугольники, кольца являются разновидностями полилиний и редактируются с использованием сходных подходов. 

**Примечание**: в оригинальном тексте сказано также и про "3D polygon meshes", я не понял, как PolufaceMesh может редактироваться аналогично полилинии и не стал это включать.

Полилинии также можно задать сглаживание, которое может быть двух типов -- круговыми дугами или одной из двух форм сплайновой кривой (B-сплайн): квадратичным или кубическим сплайном. 

Для редактирования полилинии используйте свойства и методы объекта Polyline, Polyline2d или Polyline3d в зависимости от того, каким классом описывается данный объект в чертеже. Используйте следующие свойства и методы, чтобы замкнуть\\разомкнуть полилинию, изменить координаты отдельной вершины или добавить новую вершину: 

* Свойство Closed : возвращает или задает замкнутость полилинии; 
* Свойство ConstantWidth : возвращает или задает постоянную ширины плоской полилинии; 
* Метод AppendVertex : добавляет новую вершину для плоской или пространственной полилинии; 
* Метод AddVertexAt : задает значение вершины в заданной точке кривой; 
* Метод ReverseCurve : обращает направление кривой; 
* Метод SetBulgeAt : задает величину выпуклости для данного сегмента кривой; 
* Метод SetStartWidthAt : задет ширину в начале сегмента кривой; 
* Метод Straighten : удаляет из полилинии все вершины сплайна и аппроксимирующей кривой и определяет все оставшиеся вершины в качестве простых вершин. Эта операция эквивалентна команде PEDIT с опцией "Decurve" 

В примере ниже создается плоская полилиния. Затем третьему сегменту полилинии задается выпуклость = :0.5, к полилинии добавляется вершина, изменяется ширина последнего сегмента и, наконец, полилиния замыкается. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("EditPolyline")]
public static void EditPolyline()
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

        // Create a lightweight polyline
        using (Polyline acPoly = new Polyline())
        {
            acPoly.AddVertexAt(0, new Point2d(1, 1), 0, 0, 0);
            acPoly.AddVertexAt(1, new Point2d(1, 2), 0, 0, 0);
            acPoly.AddVertexAt(2, new Point2d(2, 2), 0, 0, 0);
            acPoly.AddVertexAt(3, new Point2d(3, 2), 0, 0, 0);
            acPoly.AddVertexAt(4, new Point2d(4, 4), 0, 0, 0);

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acPoly);
            acTrans.AddNewlyCreatedDBObject(acPoly, true);

            // Sets the bulge at index 3
            acPoly.SetBulgeAt(3, -0.5);

            // Add a new vertex
            acPoly.AddVertexAt(5, new Point2d(4, 1), 0, 0, 0);

            // Sets the start and end width at index 4
            acPoly.SetStartWidthAt(4, 0.1);
            acPoly.SetEndWidthAt(4, 0.5);

            // Close the polyline
            acPoly.Closed = true;
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```
