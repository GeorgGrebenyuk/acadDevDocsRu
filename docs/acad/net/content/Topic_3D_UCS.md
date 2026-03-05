Вы можете определить пользовательскую систему координат (ПСК), чтобы переопределить положение начальной точки (0, 0, 0) и ориентацию плоскости XY и оси Z. Вы можете разместить ПСК в любом месте трехмерного пространства чертежа, а также создать их столько, сколько вам нужно. Ввод координат и их отображение будут относительными по отношению к текущей ПСК. 

Чтобы включить показ начала координат и ориентацию ПСК, вы можете отобразить значок ПСК в её начальной точке, используя свойство `IconAtOrigin` для текущего видового экрана Viewport или через системную переменную `UCSICON`. Если значок ПСК включен (свойство `IconVisible`) и не отображается в начале координат, он отображается в координатах МСК (мировой системы координат), определенных системной переменной UCSORG. 

Вы можете создать новую пользовательскую систему координат, используя метод `Add` коллекции `UCSTable`. Этот метод принимает на вход четыре значения: координаты начала координат, координаты по осям X и Y (задающие векторы направления), а также имя пользовательской системы координат. Имя подчиняется единым правилам для неграфических элементов (см. [статью](\Topic_CreateAndEditNcObjects_EditNamedAnd2D_Named_Rename.md)). 

Чтобы сделать пользовательскую систему координат активной, используйте свойство `ActiveUCS` у текущего документа nanoCAD (описывается классом `Document`). Если в определение ПСК были внесены изменения, то необходимо повторить процедуру задания свойства `ActiveUCS`. В примере ниже создается новая ПСК, делается активной с выводом модального информационного окна, затем у Пользователя запрашивается точка в пространстве чертежа и другом модальном окне выводятся её координаты в значениях текущей ПСК и МСК (мировой системы координат) 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("NewUCS")]
public static void NewUCS()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the UCS table for read
        UcsTable acUCSTbl;
        acUCSTbl = acTrans.GetObject(acCurDb.UcsTableId,
                                        OpenMode.ForRead) as UcsTable;

        UcsTableRecord acUCSTblRec;

        // Check to see if the "New_UCS" UCS table record exists
        if (acUCSTbl.Has("New_UCS") == false)
        {
            acUCSTblRec = new UcsTableRecord();
            acUCSTblRec.Name = "New_UCS";

            // Open the UCSTable for write
            acTrans.GetObject(acCurDb.UcsTableId, OpenMode.ForWrite);

            // Add the new UCS table record
            acUCSTbl.Add(acUCSTblRec);
            acTrans.AddNewlyCreatedDBObject(acUCSTblRec, true);
        }
        else
        {
            acUCSTblRec = acTrans.GetObject(acUCSTbl["New_UCS"],
                                            OpenMode.ForWrite) as UcsTableRecord;
        }

        acUCSTblRec.Origin = new Point3d(4, 5, 3);
        acUCSTblRec.XAxis = new Vector3d(1, 0, 0);
        acUCSTblRec.YAxis = new Vector3d(0, 1, 0);

        // Open the active viewport
        ViewportTableRecord acVportTblRec;
        acVportTblRec = acTrans.GetObject(acDoc.Editor.ActiveViewportId,
                                            OpenMode.ForWrite) as ViewportTableRecord;

        // Display the UCS Icon at the origin of the current viewport
        acVportTblRec.IconAtOrigin = true;
        acVportTblRec.IconEnabled = true;

        // Set the UCS current
        acVportTblRec.SetUcs(acUCSTblRec.ObjectId);
        acDoc.Editor.UpdateTiledViewportsFromDatabase();

        // Display the name of the current UCS
        UcsTableRecord acUCSTblRecActive;
        acUCSTblRecActive = acTrans.GetObject(acVportTblRec.UcsName,
                                                OpenMode.ForRead) as UcsTableRecord;

        Application.ShowAlertDialog("The current UCS is: " +
                                    acUCSTblRecActive.Name);

        PromptPointResult pPtRes;
        PromptPointOptions pPtOpts = new PromptPointOptions("");

        // Prompt for a point
        pPtOpts.Message = "\nEnter a point: ";
        pPtRes = acDoc.Editor.GetPoint(pPtOpts);

        Point3d pPt3dWCS;
        Point3d pPt3dUCS;

        // If a point was entered, then translate it to the current UCS
        if (pPtRes.Status == PromptStatus.OK)
        {
            pPt3dWCS = pPtRes.Value;
            pPt3dUCS = pPtRes.Value;

            // Translate the point from the current UCS to the WCS
            Matrix3d newMatrix = new Matrix3d();
            newMatrix = Matrix3d.AlignCoordinateSystem(Point3d.Origin,
                                                        Vector3d.XAxis,
                                                        Vector3d.YAxis,
                                                        Vector3d.ZAxis,
                                                        acVportTblRec.Ucs.Origin,
                                                        acVportTblRec.Ucs.Xaxis,
                                                        acVportTblRec.Ucs.Yaxis,
                                                        acVportTblRec.Ucs.Zaxis);

            pPt3dWCS = pPt3dWCS.TransformBy(newMatrix);

            Application.ShowAlertDialog("The WCS coordinates are: \n" +
                                        pPt3dWCS.ToString() + "\n" +
                                        "The UCS coordinates are: \n" +
                                        pPt3dUCS.ToString());
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```