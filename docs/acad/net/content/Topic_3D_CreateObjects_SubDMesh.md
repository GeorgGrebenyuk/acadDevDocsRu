# Сети SubDMesh и грани Face

Несмотря на то, что PolyFaceMesh называется "многогранной", всё же она имеет ограничение на величину граней в \~65 тысяч объектов. Вероятно всего, вы не не столкнетесь в обычной практике программирования с этим лимитом, но в противном случае важно знать, что существует ещё один трехмерный объект "Сеть" с неограниченным числом граней, описываемый классом SubDMesh.

Объект "3D-грань" описывается классом Face и может сотоять из 3 или 4 вершин. В примере "Чтение сети" ниже именно она и создается на гранях сети SubDMesh.

## Создание сети

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

## Чтение сети

Чтение сети имеет особенность, дело в том, что информация о гранях сохраняется в формат одномерного массива int, а грань может состоять из 3 или 4 вершин. В этом случае чтение информации о гранях должно быть аккуратным. В примере ниже приводится такая реализация. Для существующей сети в месте вершин создаются точки красного цвета, а также создаются грани типа `Face`.

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.EditorInput;

[CommandMethod("ExtractSubDMesh")]
public void ExtractSubDMesh()
{
    Document acCurDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acCurDoc.Database;

    PromptEntityOptions selMeshOpts = new PromptEntityOptions("\nSelect a SubDMesh");
    selMeshOpts.AddAllowedClass(typeof(SubDMesh), true);
    PromptEntityResult selMeshResult = acCurDoc.Editor.GetEntity(selMeshOpts);
    if (selMeshResult.Status != PromptStatus.OK) return;

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


        SubDMesh? meshEntity = acTrans.GetObject(selMeshResult.ObjectId, OpenMode.ForRead) as SubDMesh;
        if (meshEntity == null) return;

        acCurDoc.Editor.WriteMessage($"SubDMesh Vertices {meshEntity.NumberOfVertices}");
        acCurDoc.Editor.WriteMessage($"SubDMesh Faces {meshEntity.NumberOfFaces}");
        acCurDoc.Editor.WriteMessage($"SubDMesh Faces's vertextes {meshEntity.FaceArray.Count}");

        for (int vertexIndex = 0; vertexIndex < meshEntity.NumberOfVertices; vertexIndex++)
        {
            DBPoint meshVertex = new DBPoint(meshEntity.Vertices[vertexIndex]);
            meshVertex.ColorIndex = 1;

            acBlkTblRec.AppendEntity(meshVertex);
            acTrans.AddNewlyCreatedDBObject(meshVertex, true);
        }

        // Because the faces can contains 3 or 4 vertexes, we need read it with accuracy in tmpFaceRecordDef
        int[] tmpFaceRecordDef = new int[] { };
        int tmpCounter = -1;
        for (int faceVertexIndex = 0; faceVertexIndex < meshEntity.FaceArray.Count; faceVertexIndex++)
        {
            int data = meshEntity.FaceArray[faceVertexIndex];

            if (tmpFaceRecordDef.Length == 0) tmpFaceRecordDef = new int[data];
            else tmpFaceRecordDef[tmpCounter] = data;

            tmpCounter++;

            if (tmpCounter == tmpFaceRecordDef.Length)
            {
                faceProcessing();
            }
        }
        faceProcessing();

        void faceProcessing()
        {
            if (tmpFaceRecordDef.Length < 3) return;
            // Create a 3dface
            Face meshFace = new Face();
            Point3d vertex1 = meshEntity.Vertices[tmpFaceRecordDef[0]];
            Point3d vertex2 = meshEntity.Vertices[tmpFaceRecordDef[1]];
            Point3d vertex3 = meshEntity.Vertices[tmpFaceRecordDef[2]];
            Point3d vertex4 = new Point3d();
            if (tmpFaceRecordDef.Length == 4) vertex4 = meshEntity.Vertices[tmpFaceRecordDef[3]];

            if (tmpFaceRecordDef.Length == 3) meshFace = new Face(vertex1, vertex2, vertex3, true, true, true, true);
            else meshFace = new Face(vertex1, vertex2, vertex3, vertex4, true, true, true, true);

            meshFace.ColorIndex = 1;

            acBlkTblRec.AppendEntity(meshFace);
            acTrans.AddNewlyCreatedDBObject(meshFace, true);

            // Reset temp data
            tmpCounter = -1;
            tmpFaceRecordDef = new int[] { };
        }

        acTrans.Commit();
    }
}
```
