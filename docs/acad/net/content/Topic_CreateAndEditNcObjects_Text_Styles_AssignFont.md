# Форматирование шрифта текста

Шрифты определяют форму текстовых символов, составляющих каждый набор символов. Один шрифт может использоваться в нескольких стилях. Свойство FileName используется для задания файла шрифта для текстового стиля. Текстовому стилю можно назначить шрифты TrueType или SHX. 

В следующем примере получается активный стиль текста по свойству `Textstyle` базы данных чертежа, у него изменяется шрифта на "Calibri" редактированием свойства Font. Чтобы увидеть эффект изменения шрифта, добавьте в текущий чертеж несколько новых текстовых объектов. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("UpdateTextFont")]
public static void UpdateTextFont()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;
    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the current text style for write
        TextStyleTableRecord acTextStyleTblRec;
        acTextStyleTblRec = acTrans.GetObject(acCurDb.Textstyle,
                                              OpenMode.ForWrite) as TextStyleTableRecord;
        // Get the current font settings
        Teigha.GraphicsInterface.FontDescriptor acFont;
        acFont = acTextStyleTblRec.Font;
        // Update the text style's typeface with "PlayBill"
        Teigha.GraphicsInterface.FontDescriptor acNewFont;
        acNewFont = new
          Teigha.GraphicsInterface.FontDescriptor("Calibri",
                                                            acFont.Bold,
                                                            acFont.Italic,
                                                            acFont.CharacterSet,
                                                            acFont.PitchAndFamily);
        acTextStyleTblRec.Font = acNewFont;
        acDoc.Editor.Regen();
        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```
