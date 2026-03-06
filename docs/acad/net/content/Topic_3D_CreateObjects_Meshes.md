# Полигональные сети

Полигональная сеть (класс PolygonMesh) представляет собой поверхность (совокупность 3D-граней) в виде регулярной сети с заданным числом строк (N штук) и столбцов (M штук). Информация об отметках хранится в виде матрицы (массива) размером M x N. 

Для создания полигональной сети создайте экземпляр класса PolygonMesh, а затем задайте плотность сети (параметры M, N) и информацию об отметках. Конструктор класса PolygonMesh также имеет перегрузку для всех параметров: 

* тип сглаживания; 
* Количество вершин в направлении M; 
* Количество вершин в направлении N; 
* Коллекция вершин (Point3dCollection); 
* Флаг замкнутости сети в направлении M; 
* Флаг замкнутости сети в направлении N; 

В примере ниже создается полигональная сеть размера 4х4, после создания изменяется положение камеры текущего видового экрана, чтобы отобразить сеть в пространстве 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("Create3DMesh")]
public static void Create3DMesh()
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

        // Create a polygon mesh
        using (PolygonMesh acPolyMesh = new PolygonMesh())
        {
            acPolyMesh.MSize = 4;
            acPolyMesh.NSize = 4;

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acPolyMesh);
            acTrans.AddNewlyCreatedDBObject(acPolyMesh, true);

            // Before adding vertexes, the polyline must be in the drawing
            Point3dCollection acPts3dPMesh = new Point3dCollection();
            acPts3dPMesh.Add(new Point3d(0, 0, 0));
            acPts3dPMesh.Add(new Point3d(2, 0, 1));
            acPts3dPMesh.Add(new Point3d(4, 0, 0));
            acPts3dPMesh.Add(new Point3d(6, 0, 1));

            acPts3dPMesh.Add(new Point3d(0, 2, 0));
            acPts3dPMesh.Add(new Point3d(2, 2, 1));
            acPts3dPMesh.Add(new Point3d(4, 2, 0));
            acPts3dPMesh.Add(new Point3d(6, 2, 1));

            acPts3dPMesh.Add(new Point3d(0, 4, 0));
            acPts3dPMesh.Add(new Point3d(2, 4, 1));
            acPts3dPMesh.Add(new Point3d(4, 4, 0));
            acPts3dPMesh.Add(new Point3d(6, 4, 0));

            acPts3dPMesh.Add(new Point3d(0, 6, 0));
            acPts3dPMesh.Add(new Point3d(2, 6, 1));
            acPts3dPMesh.Add(new Point3d(4, 6, 0));
            acPts3dPMesh.Add(new Point3d(6, 6, 0));

            foreach (Point3d acPt3d in acPts3dPMesh)
            {
                PolygonMeshVertex acPMeshVer = new PolygonMeshVertex(acPt3d);
                acPolyMesh.AppendVertex(acPMeshVer);
                acTrans.AddNewlyCreatedDBObject(acPMeshVer, true);
            }
        }

        // Open the active viewport
        ViewportTableRecord acVportTblRec;
        acVportTblRec = acTrans.GetObject(acDoc.Editor.ActiveViewportId,
                                            OpenMode.ForWrite) as ViewportTableRecord;

        // Rotate the view direction of the current viewport
        acVportTblRec.ViewDirection = new Vector3d(-1, -1, 1);
        acDoc.Editor.UpdateTiledViewportsFromDatabase();

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```
