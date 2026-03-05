Создаваемый многострочный текст автоматически принимает настройки активного стиля текста (по умолчанию - ГОСТ 2.304). Вы можете переопределить стиль текста целиком или задать отдельные свойства у объекту MText, также вы можете применить форматирование к отдельным символам или словосочетаниям. 

Параметры ориентации, такие как стиль, выравнивание, ширина и поворот, влияют на весь текст в пределах многострочного текста, а не на отдельные слова или символы. Используйте свойство Attachment для изменения выравнивания многострочного текста и свойство Rotation для задания угла поворота. 

Свойство `TextStyleId` задает шрифт и настройки форматирования для многострочного текстового объекта. При изменении стиля многострочного текстового объекта, к которому применено форматирование символов, стиль применяется ко всему объекту, и некоторое форматирование символов может быть утрачено. Например, при смене стиля TrueType на стиль, использующий шрифт SHX, или на другой шрифт TrueType, многострочный текст станет использовать новый шрифт для всего объекта, и любое пользовательское форматирование символов будет утрачено. 

Параметры форматирования, такие как подчеркивание, внрхний\\нижний регистр и пр. можно применять к отдельным словам или символам в абзаце текста. Вы также можете изменять цвет, шрифт и высоту отдельных символов. Можно изменять интервалы между символами текста или увеличивать ширину символов. 

Используйте фигурные скобки ({ }) для задания форматирования только к тексту внутри скобок. Скобки могут быть вложенными друг в друга до восьми уровней. 

Вы также можете использовать ASCII управляющие коды символов, чтобы указать настройки форматирования или специальные символы, например, греческого алфавита или операторов сравнения. 

## Создание МТекста с форматированием

В примере ниже создается многострочный текст в точке (10, 5, 0), содержащий несколько операций форматирования: жирное выделение, текст в верхнем и нижнем регистре. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
 
[CommandMethod("FormatMText")]
public static void FormatMText()
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

        // Create a multiline text object
        using (MText acMText = new MText())
        {
            acMText.Location = new Point3d(2, 2, 0);
            acMText.Width = 4.5;
            acMText.Contents = "{{\\H1.5x; Big text}\\A2; over text\\A1;/\\A0;under text}";

            acBlkTblRec.AppendEntity(acMText);
            acTrans.AddNewlyCreatedDBObject(acMText, true);
        }

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```

<b>Примечание</b>: в некоторых случаях многострочный текст, содержащий форматирование и созданный программно в nanoCAD .NET API, может не отображаться в полной мере, пока не зайти в редактор.