# Создание видовых экранов

Видовые окна в пространстве листа создаются путем создания экземпляров классов Viewport и добавления их к объекту BloctTableRecord для данного листа. Конструктор объекта Viewport не принимает никаких параметров. После создания экземпляра объекта Viewport вы можете задать его расположение на листе с помощью свойств CenterPoint, Width и Height. 

Также вы можете задать свойства самого вида, такие как направление просмотра (свойство ViewDirection), фокусное расстояние для перспетивного вида (свойство LensLength) и флаг отображения сетки (свойство GridOn). Вы также можете управлять свойствами самого видового окна, такими как слой (свойство Layer), тип линии (свойство Linetype) и масштабирование типов линий (свойство LinetypeScale). 

## Создание ВЭ

В примере ниже приводится код, делающий активым область листов, создающий там плавающий ВЭ, задающий вид для данного ВЭ и делающий данный ВЭ активным. Установка ВЭ активным делается с помощью обращения к NRX-методу ncedSetCurrentVPort из "NrxHostGate.dll", для которого прописывается соответствующая точка входа EntryPoint. 

```cs
using System.Runtime.InteropServices;
 
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[DllImport("acad.exe", CallingConvention = CallingConvention.Cdecl,
 EntryPoint = "?acedSetCurrentVPort@@YA?AW4ErrorStatus@Acad@@PBVAcDbViewport@@@Z")]
extern static private int acedSetCurrentVPort(IntPtr AcDbVport);
 
[CommandMethod("CreateFloatingViewport")]
public static void CreateFloatingViewport()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                     OpenMode.ForRead) as BlockTable;

        // Open the Block table record Paper space for write
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.PaperSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;

        // Switch to the previous Paper space layout
        Application.SetSystemVariable("TILEMODE", 0);
        acDoc.Editor.SwitchToPaperSpace();

        // Create a Viewport
        using (Viewport acVport = new Viewport())
        {
            acVport.CenterPoint = new Point3d(3.25, 3, 0);
            acVport.Width = 6;
            acVport.Height = 5;

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acVport);
            acTrans.AddNewlyCreatedDBObject(acVport, true);

            // Change the view direction
            acVport.ViewDirection = new Vector3d(1, 1, 1);

            // Enable the viewport
            acVport.On = true;

            // Activate model space in the viewport
            acDoc.Editor.SwitchToModelSpace();

            // Set the new viewport current via an imported ObjectARX function
            acedSetCurrentVPort(acVport.UnmanagedObject);
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```

Примечание: аналогичная процедура acedSetCurrentVPort для nanoCAD будет выглядеть так:

```csharp
[DllImport("NrxHostGate.dll", CallingConvention = CallingConvention.Cdecl,
          EntryPoint = "?ncedSetCurrentVPort@@YA?AW4ErrorStatus@Nano@@PEBVNcDbViewport@@@Z")]
extern static private int acedSetCurrentVPort(System.IntPtr AcDbVport);
```

<b>Примечание</b>: Чтобы задать параметры вида (направление обзора, фокусное расстояние и т. д.), свойство On объекта Viewport должно быть установлено в значение false, а перед установкой текущего состояния видового окна свойство On должно быть установлено в значение true. 

## Создание нескольких ВЭ

В примере ниже создается 4 ВЭ, каждый из которых имеет фиксированное направление вида (ViewDirection) 

```cs
using System.Runtime.InteropServices;
 
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[DllImport("acad.exe", CallingConvention = CallingConvention.Cdecl,
 EntryPoint = "?acedSetCurrentVPort@@YA?AW4ErrorStatus@Acad@@PBVAcDbViewport@@@Z")]
extern static private int acedSetCurrentVPort(IntPtr AcDbVport);
 
[CommandMethod("FourFloatingViewports")]
public static void FourFloatingViewports()
{
  // Get the current document and database, and start a transaction
  Document acDoc = Application.DocumentManager.MdiActiveDocument;
  Database acCurDb = acDoc.Database;
 
  using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
  {
      // Open the Block table for read
      BlockTable acBlkTbl;
      acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                   OpenMode.ForRead) as BlockTable;
 
      // Open the Block table record Paper space for write
      BlockTableRecord acBlkTblRec;
      acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.PaperSpace],
                                      OpenMode.ForWrite) as BlockTableRecord;
 
      // Switch to the previous Paper space layout
      Application.SetSystemVariable("TILEMODE", 0);
      acDoc.Editor.SwitchToPaperSpace();
 
      Point3dCollection acPt3dCol = new Point3dCollection();
      acPt3dCol.Add(new Point3d(2.5, 5.5, 0));
      acPt3dCol.Add(new Point3d(2.5, 2.5, 0));
      acPt3dCol.Add(new Point3d(5.5, 5.5, 0));
      acPt3dCol.Add(new Point3d(5.5, 2.5, 0));
 
      Vector3dCollection acVec3dCol = new Vector3dCollection();
      acVec3dCol.Add(new Vector3d(0, 0, 1));
      acVec3dCol.Add(new Vector3d(0, 1, 0));
      acVec3dCol.Add(new Vector3d(1, 0, 0));
      acVec3dCol.Add(new Vector3d(1, 1, 1));
 
      double dWidth = 2.5;
      double dHeight = 2.5;
 
      Viewport acVportLast = null;
      int nCnt = 0;
 
      foreach (Point3d acPt3d in acPt3dCol)
      {
          using (Viewport acVport = new Viewport())
          {
              acVport.CenterPoint = acPt3d;
              acVport.Width = dWidth;
              acVport.Height = dHeight;

              // Add the new object to the block table record and the transaction
              acBlkTblRec.AppendEntity(acVport);
              acTrans.AddNewlyCreatedDBObject(acVport, true);

              // Change the view direction
              acVport.ViewDirection = acVec3dCol[nCnt];

              // Enable the viewport
              acVport.On = true;

              // Record the last viewport created
              acVportLast = acVport;

              // Increment the counter by 1
              nCnt = nCnt + 1;
          }
      }
 
      if (acVportLast != null)
      {
          // Activate model space in the viewport
          acDoc.Editor.SwitchToModelSpace();
 
          // Set the new viewport current via an imported ObjectARX function
          acedSetCurrentVPort(acVportLast.UnmanagedObject);
      }
 
      // Save the new objects to the database
      acTrans.Commit();
  }
}
```

## Создание непрямоугольных ВЭ

В примере ниже создается прямоугольный ВЭ, а затем используется окружность для задания его границы 

```cs
using System.Runtime.InteropServices;
 
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[DllImport("acad.exe", CallingConvention = CallingConvention.Cdecl,
 EntryPoint = "?acedSetCurrentVPort@@YA?AW4ErrorStatus@Acad@@PBVAcDbViewport@@@Z")]
extern static private int acedSetCurrentVPort(IntPtr AcDbVport);
 
[CommandMethod("CreateNonRectangularFloatingViewport")]
public static void CreateNonRectangularFloatingViewport()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                     OpenMode.ForRead) as BlockTable;

        // Open the Block table record Paper space for write
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.PaperSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;

        // Switch to the previous Paper space layout
        Application.SetSystemVariable("TILEMODE", 0);
        acDoc.Editor.SwitchToPaperSpace();

        // Create a Viewport
        using (Viewport acVport = new Viewport())
        {
            acVport.CenterPoint = new Point3d(9, 6.5, 0);
            acVport.Width = 2.5;
            acVport.Height = 2.5;

            // Set the scale to 1" = 8'
            acVport.CustomScale = 96;

            // Create a circle
            using (Circle acCirc = new Circle())
            {
                acCirc.Center = acVport.CenterPoint;
                acCirc.Radius = 1.25;

                // Add the new object to the block table record and the transaction
                acBlkTblRec.AppendEntity(acCirc);
                acTrans.AddNewlyCreatedDBObject(acCirc, true);

                // Clip the viewport using the circle  
                acVport.NonRectClipEntityId = acCirc.ObjectId;
                acVport.NonRectClipOn = true;
            }

            // Add the new object to the block table record and the transaction
            acBlkTblRec.AppendEntity(acVport);
            acTrans.AddNewlyCreatedDBObject(acVport, true);

            // Change the view direction
            acVport.ViewDirection = new Vector3d(0, 0, 1);

            // Enable the viewport
            acVport.On = true;

            // Activate model space in the viewport
            acDoc.Editor.SwitchToModelSpace();

            // Set the new viewport current via an imported ObjectARX function
            acedSetCurrentVPort(acVport.UnmanagedObject);
        }

        // Save the new objects to the database
        acTrans.Commit();
    }
}
```
