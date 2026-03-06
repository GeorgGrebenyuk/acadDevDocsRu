# Трёхмерные тела

Твердотельный объект (класс Solid3d) представляет собой полнотелый объект (оболочка с объемом). Сложные твердотельные формы также проще создавать и редактировать, в отличие от каркасных тел и многогранных сетей. Вы можете создавать простые трехмерные тела, такие как параллелепипед, сфера и клин, используя методы и свойства класса Solid3d. Вы также можете создавать сложные тела, полученные на основе выдавливания\\вращения контура вокруг заданной оси. Подобно сетям, твердотельные солиды отображаются в виде оболочек, пока вы не измените визуальный стиль отображения. Кроме того, вы можете извлекать информацию о геометрических свойствах тел (объем (`Volume`), моменты инерции (`MomentOfInertia`), центр тяжести (`Centroid`) и т. д.) с помощью вспомогательной структуры `Solid3dMassProperties`, возвращаемой через свойство `MassProperties` у `Solid3d`. На отображение твердотельного солида влияют текущий визуальный стиль и системные переменные, связанные с 3D-моделированием: 

* `ISOLINES` задает количество контурных линий, которыми отрис на криволинейных поверхностях 3D:тел; 
* `FACETRES` определяет плавность отрисовки перехода от скрытых, затененных и визуализированных объектов; 

В примере ниже создается солид в виде клина. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

[CommandMethod("CreateWedge")]
public static void CreateWedge()
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

        // Create a 3D solid wedge
        using (Solid3d acSol3D = new Solid3d())
        {
            acSol3D.CreateWedge(10, 15, 20);

            // Position the center of the 3D solid at (5,5,0) 
            acSol3D.TransformBy(Matrix3d.Displacement(new Point3d(5, 5, 0) -
                                                        Point3d.Origin));

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acSol3D);
            acTrans.AddNewlyCreatedDBObject(acSol3D, true);
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
