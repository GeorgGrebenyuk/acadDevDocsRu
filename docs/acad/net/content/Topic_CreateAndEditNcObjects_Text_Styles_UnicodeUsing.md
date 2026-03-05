AutoCAD поддерживает стандарт кодирования символов Unicode. Шрифт Unicode может содержать 65 535 символов для различных языков мира. Все шрифты SHX, поставляемые с продуктом, поддерживают символы Unicode. 

Текстовые файлы для некоторых алфавитов содержат тысячи символов, не входящих в ASCII. Для работы с таким текстом AutoCAD поддерживает специальный тип определения символов, известный как файл Big Font. Можно установить текстовый стиль для использования как обычных шрифтов, так и специальных файлов Big Font. Обычные шрифты указываются с помощью свойства `FileName`. Шрифты Big Font указываются с помощью свойства `BigFontFileName`. 
**Примечание**: Имена файлов шрифтов не могут содержать запятые. AutoCADпозволяет указать шрифт по умолчанию, который будет использоваться, если указанный файл шрифта не может быть найден. Для его установки используйте системную переменную `FONTALT` или метод `SetSystemVariable` приложения Application. В следующем примере кода изменяются свойства FileName и BigFontFileName для bigfont.shx. Вам необходимо отредактировать пути к файлам на вашем ПК, в примере ниже они приведены для AutoCAD 2022.

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("ChangeFontFiles")]
public static void ChangeFontFiles()
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

        // Change the font files used for both Big and Regular fonts
        acTextStyleTblRec.BigFontFileName = @"C:\Program Files\Autodesk\AutoCAD 2022\Fonts\bigfont.shx";
        acTextStyleTblRec.FileName = @"C:\Program Files\Autodesk\AutoCAD 2022\Fonts\italic.shx";

        // Save the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```