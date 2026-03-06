# Использование пространственных координат

Ввод трехмерных координат мировой системы координат (WCS) аналогичен вводу двумерных координат WCS. Помимо значений X и Y, вы также указываете значение Z. Двумерные координаты представляются структурой Point2d, а для представления трехмерных координат используется структура Point3d. Большинство свойств и методов объектов в AutoCAD .NET API используют трехмерные координаты. 

В примере ниже создаются 2 трехмерные полилинии, первая полилиния -- классическая плоская полилиния на фиксированной отметке (описывается классом Polyline), вторая -- трехмерная полилиния (описывается классом Polyline3d). После создания объектов показывается механизм чтения координат созданных полилиний, информация о количество точек выводится в диалоговые окна. 

```cs
using Teigha.Runtime;
using HostMgd.ApplicationServices;
using Teigha.DatabaseServices;
using Teigha.Geometry;
[CommandMethod("Polyline_2D_3D")]
public static void Polyline_2D_3D()
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
        // Create a polyline with two segments (3 points)
        using (Polyline acPoly = new Polyline())
        {
            acPoly.AddVertexAt(0, new Point2d(1, 1), 0, 0, 0);
            acPoly.AddVertexAt(1, new Point2d(1, 2), 0, 0, 0);
            acPoly.AddVertexAt(2, new Point2d(2, 2), 0, 0, 0);
            acPoly.ColorIndex = 1;
            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acPoly);
            acTrans.AddNewlyCreatedDBObject(acPoly, true);
            // Create a 3D polyline with two segments (3 points)
            using (Polyline3d acPoly3d = new Polyline3d())
            {
                acPoly3d.ColorIndex = 5;
                // Add the new object to the block table record and the transaction
                acBlkTblRec.AppendEntity(acPoly3d);
                acTrans.AddNewlyCreatedDBObject(acPoly3d, true);
                // Before adding vertexes, the polyline must be in the drawing
                Point3dCollection acPts3dPoly = new Point3dCollection();
                acPts3dPoly.Add(new Point3d(1, 1, 0));
                acPts3dPoly.Add(new Point3d(2, 1, 0));
                acPts3dPoly.Add(new Point3d(2, 2, 0));
                foreach (Point3d acPt3d in acPts3dPoly)
                {
                    using (PolylineVertex3d acPolVer3d = new PolylineVertex3d(acPt3d))
                    {
                        acPoly3d.AppendVertex(acPolVer3d);
                        acTrans.AddNewlyCreatedDBObject(acPolVer3d, true);
                    }
                }
                // Get the coordinates of the lightweight polyline
                Point2dCollection acPts2d = new Point2dCollection();
                for (int nCnt = 0; nCnt \< acPoly.NumberOfVertices; nCnt++)
                {
                    acPts2d.Add(acPoly.GetPoint2dAt(nCnt));
                }
                // Get the coordinates of the 3D polyline
                Point3dCollection acPts3d = new Point3dCollection();
                foreach (ObjectId acObjIdVert in acPoly3d)
                {
                    PolylineVertex3d acPolVer3d;
                    acPolVer3d = acTrans.GetObject(acObjIdVert,
                                                    OpenMode.ForRead) as PolylineVertex3d;
                    acPts3d.Add(acPolVer3d.Position);
                }
                // Display the Coordinates
                Application.ShowAlertDialog("2D polyline (red): \\n" +
                                            acPts2d[0].ToString() + "\\n" +
                                            acPts2d[1].ToString() + "\\n" +
                                            acPts2d[2].ToString());
                Application.ShowAlertDialog("3D polyline (blue): \\n" +
                                            acPts3d[0].ToString() + "\\n" +
                                            acPts3d[1].ToString() + "\\n" +
                                            acPts3d[2].ToString());
            }
        }
        // Save the new object to the database
        acTrans.Commit();
    }
}
```
