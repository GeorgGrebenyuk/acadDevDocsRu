# Многогранные сети

Многогранная сеть представляет собой триангулированную поверхность, представленную набором вершин и связанных с ними гранями. Создание многогранной сети аналогично созданию полигональной сети. Вы создаете объект класса `PolyFaceMesh`, а затем используйте свойства и методы класса для задания геометрии. Чтобы добавить вершину к многогранной сети, создайте объект `PolyFaceMeshVertex` и добавьте его к сети `PolyFaceMesh` с помощью метода `AppendVertex`. 

Информация о гранях задается с помощью метода `AppendFaceRecord`, который принимает в себя объект класса `FaceRecord`. Рёбрам грани можно задать видимость, конкретный слой или цвет. 

В примере ниже создается многогранная сеть в пространстве модели. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("CreatePolyfaceMesh")]
public static void CreatePolyfaceMesh()
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

        // Create a polyface mesh
        using (PolyFaceMesh acPFaceMesh = new PolyFaceMesh())
        {
            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acPFaceMesh);
            acTrans.AddNewlyCreatedDBObject(acPFaceMesh, true);

            // Before adding vertexes, the polyline must be in the drawing
            Point3dCollection acPts3dPFMesh = new Point3dCollection();
            acPts3dPFMesh.Add(new Point3d(4, 7, 0));
            acPts3dPFMesh.Add(new Point3d(5, 7, 0));
            acPts3dPFMesh.Add(new Point3d(6, 7, 0));

            acPts3dPFMesh.Add(new Point3d(4, 6, 0));
            acPts3dPFMesh.Add(new Point3d(5, 6, 0));
            acPts3dPFMesh.Add(new Point3d(6, 6, 1));

            foreach (Point3d acPt3d in acPts3dPFMesh)
            {
                PolyFaceMeshVertex acPMeshVer = new PolyFaceMeshVertex(acPt3d);
                acPFaceMesh.AppendVertex(acPMeshVer);
                acTrans.AddNewlyCreatedDBObject(acPMeshVer, true);
            }

            using (FaceRecord acFaceRec1 = new FaceRecord(1, 2, 5, 4))
            {
                acPFaceMesh.AppendFaceRecord(acFaceRec1);
                acTrans.AddNewlyCreatedDBObject(acFaceRec1, true);
            }

            using (FaceRecord acFaceRec2 = new FaceRecord(2, 3, 6, 5))
            {
                acPFaceMesh.AppendFaceRecord(acFaceRec2);
                acTrans.AddNewlyCreatedDBObject(acFaceRec2, true);
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
