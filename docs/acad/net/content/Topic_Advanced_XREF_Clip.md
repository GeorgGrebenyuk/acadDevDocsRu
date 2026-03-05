Вы можете определить границы показа для внешней ссылки, задав прямоугольник подрезки. Несколько экземпляров одной и той же внешней ссылки могут иметь разные границы. 

Для определения свойств границы обрезки для внешней ссылки используются вспомогательные структуры `SpatialFilter` и `SpatialFilterDefinition` из пространства имён `Autodesk.AutoCAD.DatabaseServices.Filters`. Используйте свойство `Enabled` объекта `SpatialFilterDefinition` для отображения или скрытия границы обрезки. 

В примере ниже формируется демонстрационный чертеж, содержащий множество окружностей переменного диаметра между точками (0,0) и (2000, 2000), в данном чертеже на него создается внешняя ссылка, создается её экземпляр в чертеже и для него задается граница подрезки в виде прямоугольника с крайними точками (200, 300) и (1200, 1100). 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.DatabaseServices.Filters;

[CommandMethod("ClippingExternalReference")]
public void ClippingExternalReference()
{
    string tmpDwg = @"C:\Temp\test.dwg";
    using (Database dbTmp = new Database())
    {
        using (Transaction acTrans = dbTmp.TransactionManager.StartTransaction())
        {
            // Open the Block table record for read
            BlockTable acBlkTbl;
            acBlkTbl = acTrans.GetObject(dbTmp.BlockTableId,
                                            OpenMode.ForRead) as BlockTable;
            // Open the Block table record Model space for write
            BlockTableRecord acBlkTblRec;
            acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                            OpenMode.ForWrite) as BlockTableRecord;
            System.Random r = new System.Random();
            for (int i = 0; i < 2000; i += 20)
            {
                for (int j = 0; j < 2000; j += 20)
                {
                    using (Circle acCirc = new Circle(new Point3d(i, j, 0), Vector3d.ZAxis, r.Next(1, 12)))
                    {
                        acBlkTblRec.AppendEntity(acCirc);
                        acTrans.AddNewlyCreatedDBObject(acCirc, true);
                    }
                }
            }
            acTrans.Commit();
        }
        dbTmp.SaveAs(tmpDwg, DwgVersion.Current);
    }
    // Get the current database and start a transaction
    Database acCurDb;
    acCurDb = Application.DocumentManager.MdiActiveDocument.Database;
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Create a reference to a DWG file
        ObjectId acXrefId = acCurDb.AttachXref(tmpDwg, "Test 2");
        // If a valid reference is created then continue
        if (!acXrefId.IsNull)
        {
            // Attach the DWG reference to the current space
            Point3d insPt = new Point3d(1, 1, 0);
            using (BlockReference acBlkRef = new BlockReference(insPt, acXrefId))
            {
                BlockTableRecord acBlkTblRec;
                acBlkTblRec = acTrans.GetObject(acCurDb.CurrentSpaceId, OpenMode.ForWrite) as BlockTableRecord;
                acBlkTblRec.AppendEntity(acBlkRef);
                acTrans.AddNewlyCreatedDBObject(acBlkRef, true);
                Application.ShowAlertDialog("The external reference is attached.");
                Matrix3d mat = acBlkRef.BlockTransform;
                mat.Inverse();
                Point2dCollection ptCol = new Point2dCollection();
                // Define the first corner of the clipping boundary
                Point3d pt3d = new Point3d(200, 300, 0);
                pt3d.TransformBy(mat);
                ptCol.Add(new Point2d(pt3d.X, pt3d.Y));
                // Define the second corner of the clipping boundary
                pt3d = new Point3d(1200, 1100, 0);
                pt3d.TransformBy(mat);
                ptCol.Add(new Point2d(pt3d.X, pt3d.Y));
                // Define the normal and elevation for the clipping boundary
                Vector3d normal;
                double elev = 0;
                if (acCurDb.TileMode == true)
                {
                    normal = acCurDb.Ucsxdir.CrossProduct(acCurDb.Ucsydir);
                    elev = acCurDb.Elevation;
                }
                else
                {
                    normal = acCurDb.Pucsxdir.CrossProduct(acCurDb.Pucsydir);
                    elev = acCurDb.Pelevation;
                }
                // Set the clipping boundary and enable it
                using (SpatialFilter filter = new SpatialFilter())
                {
                    SpatialFilterDefinition filterDef = new SpatialFilterDefinition(ptCol, normal, elev, 0, 0, true);
                    filter.Definition = filterDef;
                    // Define the name of the extension dictionary and entry name
                    string dictName = "ACAD_FILTER";
                    string spName = "SPATIAL";
                    // Check to see if the Extension Dictionary exists, if not create it
                    if (acBlkRef.ExtensionDictionary.IsNull)
                    {
                        acBlkRef.CreateExtensionDictionary();
                    }
                    // Open the Extension Dictionary for write
                    DBDictionary extDict = acTrans.GetObject(acBlkRef.ExtensionDictionary, OpenMode.ForWrite) as DBDictionary;
                    // Check to see if the dictionary for clipped boundaries exists,
                    // and add the spatial filter to the dictionary
                    if (extDict.Contains(dictName))
                    {
                        DBDictionary filterDict = acTrans.GetObject(extDict.GetAt(dictName), OpenMode.ForWrite) as DBDictionary;
                        if (filterDict.Contains(spName))
                        {
                            filterDict.Remove(spName);
                        }
                        filterDict.SetAt(spName, filter);
                    }
                    else
                    {
                        using (DBDictionary filterDict = new DBDictionary())
                        {
                            extDict.SetAt(dictName, filterDict);
                            acTrans.AddNewlyCreatedDBObject(filterDict, true);
                            filterDict.SetAt(spName, filter);
                        }
                    }
                    // Append the spatial filter to the drawing
                    acTrans.AddNewlyCreatedDBObject(filter, true);
                }
            }
            Application.ShowAlertDialog("The external reference is clipped.");
        }
        // Save the new objects to the database
        acTrans.Commit();
        // Dispose of the transaction
    }
}
```