Визуальные стили управляют отображением объектов в видовых экранах и при выводе их на печать. Визуальные стили хранятся в чертеже как часть словаря визуальных стилей (`VisualStyleDictionaryId`), можно создать новый визуальный стиль через класс `DBVisualStyle` и различные перечисления из пространства имён Autodesk.AutoCAD.GraphicsInterface. 

## Получение перечня визуальных стилей

В примере ниже приведен код, выводящий в командную строку имена всех визуальных стилей в чертеже

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Colors;
using Autodesk.AutoCAD.GraphicsInterface;

// Lists the available visual styles
[CommandMethod("ListVisualStyle")]
public static void ListVisualStyle()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        DBDictionary vStyles = acTrans.GetObject(acCurDb.VisualStyleDictionaryId, 
                                                 OpenMode.ForRead) as DBDictionary;

        // Output a message to the Command Line history
        acDoc.Editor.WriteMessage("\nVisual styles: ");

        // Step through the dictionary
        foreach (DBDictionaryEntry entry in vStyles)
        {
            // Get the dictionary entry
            DBVisualStyle vStyle = vStyles.GetAt(entry.Key).GetObject(OpenMode.ForRead) as DBVisualStyle;

            // If the visual style is not marked for internal use then output its name
            if (vStyle.InternalUseOnly == false)
            {
                // Output the name of the visual style
                acDoc.Editor.WriteMessage("\n  " + vStyle.Name);
            }
        }
    }
}
```

**Примечание**: в nanoCAD NET API нельзя считать и отредактировать визуальные стили. Ошибка в API, известная.

## Создание нового визуального стиля

В примере ниже создается новый визуальный стиль с именем MyVS. 

**Примечание**: в nanoCAD NET API код ниже будет полностью несовместим, в Teigha.GraphicsInterface совсем другие названия соответствующих структур, классов, перечислений; но тем не менее соответствие есть, но не везде очевидное.

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Colors;
using Autodesk.AutoCAD.GraphicsInterface;

// Creates a new visual style
[CommandMethod("CreateVisualStyle")]
public static void CreateVisualStyle()
{
    // Get the current document and database, and start a transaction
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        DBDictionary vStyles = acTrans.GetObject(acCurDb.VisualStyleDictionaryId,
                                                 OpenMode.ForRead) as DBDictionary;

        try
        {
            // Check to see if the "MyVS" exists or not
            DBVisualStyle vStyle = default(DBVisualStyle);
            if (vStyles.Contains("MyVS") == true)
            {
                vStyle = acTrans.GetObject(vStyles.GetAt("MyVS"), OpenMode.ForWrite) as DBVisualStyle;
            }
            else
            {
                acTrans.GetObject(acCurDb.VisualStyleDictionaryId, OpenMode.ForWrite);

                // Create the visual style
                vStyle = new DBVisualStyle();
                vStyles.SetAt("MyVS", vStyle);

                // Add the visual style to the dictionary
                acTrans.AddNewlyCreatedDBObject(vStyle, true);
            }

            // Set the description of the visual style
            vStyle.Description = "My Visual Style";
            vStyle.Type = VisualStyleType.Custom;

            // Face Settings (Opacity, Face Style, Lighting Quality, Color, 
            //                Monochrome color, Opacity, and Material Display)
            vStyle.SetTrait(VisualStyleProperty.FaceModifier, (int)VSFaceModifiers.FaceOpacityFlag, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.FaceLightingModel, (int)VSFaceLightingModel.Gooch, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.FaceLightingQuality, (int)VSFaceLightingQuality.PerPixelLighting, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.FaceColorMode, (int)VSFaceColorMode.ObjectColor, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.FaceMonoColor, Color.FromColorIndex(ColorMethod.ByAci, 1), VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.FaceOpacity, 0.5, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.DisplayStyle, (int)VSDisplayStyles.MaterialsFlag + (int)VSDisplayStyles.TexturesFlag, VisualStyleOperation.Set);

            // Lighting (Enable Highlight Intensity, 
            //           Highlight Intensity, and Shadow Display)
            vStyle.SetTrait(VisualStyleProperty.FaceModifier, (int)vStyle.GetTrait(VisualStyleProperty.FaceModifier) + (int)VSFaceModifiers.SpecularFlag, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.DisplayStyle, (int)vStyle.GetTrait(VisualStyleProperty.DisplayStyle) + (int)VSDisplayStyles.LightingFlag, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.FaceSpecular, 45.0, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.DisplayShadowType, (int)VSDisplayShadowType.Full, VisualStyleOperation.Set);

            // Environment Settings (Backgrounds)
            vStyle.SetTrait(VisualStyleProperty.DisplayStyle, (int)vStyle.GetTrait(VisualStyleProperty.DisplayStyle) + (int)VSDisplayStyles.BackgroundsFlag, VisualStyleOperation.Set);

            // Edge Settings (Show, Number of Lines, Color, and Always on Top)
            vStyle.SetTrait(VisualStyleProperty.EdgeModel, (int)VSEdgeModel.Isolines, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.EdgeIsolines, 6, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.EdgeColor, Color.FromColorIndex(ColorMethod.ByAci, 2), VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.EdgeModifier, (int)vStyle.GetTrait(VisualStyleProperty.EdgeModifier) + (int)VSEdgeModifiers.AlwaysOnTopFlag, VisualStyleOperation.Set);

            // Occluded Edges (Show, Color, and Linetype)
            if (!(((int)vStyle.GetTrait(VisualStyleProperty.EdgeStyle) + (int)VSEdgeStyles.ObscuredFlag) > 0))
            {
                vStyle.SetTrait(VisualStyleProperty.EdgeStyle, (int)vStyle.GetTrait(VisualStyleProperty.EdgeStyle) + (int)VSEdgeStyles.ObscuredFlag, VisualStyleOperation.Set);
            }
            vStyle.SetTrait(VisualStyleProperty.EdgeObscuredColor, Color.FromColorIndex(ColorMethod.ByAci, 3), VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.EdgeObscuredLinePattern, (int)VSEdgeLinePattern.DoubleMediumDash, VisualStyleOperation.Set);

            // Intersection Edges (Color and Linetype)
            if (!(((int)vStyle.GetTrait(VisualStyleProperty.EdgeStyle) + (int)VSEdgeStyles.IntersectionFlag) > 0))
            {
                vStyle.SetTrait(VisualStyleProperty.EdgeStyle, (int)vStyle.GetTrait(VisualStyleProperty.EdgeStyle) + (int)VSEdgeStyles.IntersectionFlag, VisualStyleOperation.Set);
            }
            vStyle.SetTrait(VisualStyleProperty.EdgeIntersectionColor, Color.FromColorIndex(ColorMethod.ByAci, 4), VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.EdgeIntersectionLinePattern, (int)VSEdgeLinePattern.ShortDash, VisualStyleOperation.Set);

            // Silhouette Edges (Color and Width)
            if (!(((int)vStyle.GetTrait(VisualStyleProperty.EdgeStyle) + (int)VSEdgeStyles.SilhouetteFlag) > 0))
            {
                vStyle.SetTrait(VisualStyleProperty.EdgeStyle, (int)vStyle.GetTrait(VisualStyleProperty.EdgeStyle) + (int)VSEdgeStyles.SilhouetteFlag, VisualStyleOperation.Set);
            }
            vStyle.SetTrait(VisualStyleProperty.EdgeSilhouetteColor, Color.FromColorIndex(ColorMethod.ByAci, 5), VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.EdgeSilhouetteWidth, 2, VisualStyleOperation.Set);

            // Edge Modifiers (Enable Line Extensions, Enable Jitter, 
            //                 Line Extensions, Jitter, Crease Angle, 
            //                 and Halo Gap)
            if (!(((int)vStyle.GetTrait(VisualStyleProperty.EdgeModifier) + (int)VSEdgeModifiers.EdgeOverhangFlag) > 0))
            {
                vStyle.SetTrait(VisualStyleProperty.EdgeModifier, (int)vStyle.GetTrait(VisualStyleProperty.EdgeModifier) + (int)VSEdgeModifiers.EdgeOverhangFlag, VisualStyleOperation.Set);
            }
            if (!(((int)vStyle.GetTrait(VisualStyleProperty.EdgeModifier) + (int)VSEdgeModifiers.EdgeJitterFlag) > 0))
            {
                vStyle.SetTrait(VisualStyleProperty.EdgeModifier, (int)vStyle.GetTrait(VisualStyleProperty.EdgeModifier) + (int)VSEdgeModifiers.EdgeJitterFlag, VisualStyleOperation.Set);
            }
            vStyle.SetTrait(VisualStyleProperty.EdgeOverhang, 3, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.EdgeJitterAmount, (int)VSEdgeJitterAmount.JitterMedium, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.EdgeCreaseAngle, 0.3, VisualStyleOperation.Set);
            vStyle.SetTrait(VisualStyleProperty.EdgeHaloGap, 5, VisualStyleOperation.Set);
        }
        catch (Autodesk.AutoCAD.Runtime.Exception es)
        {
            System.Windows.Forms.MessageBox.Show(es.Message);
        }
        finally
        {
            acTrans.Commit();
        }
    }
}
```