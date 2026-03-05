Для сохранения содержимого файла используйте метод Database.SaveAs. При использовании метода SaveAs можно указать новый путь для сохранения файла, а при флаге bBakAndRename = true соответствующие временные файлы BAK также будут переименованы для нового файлового пути. Определить, используется ли в базе данных чертежа имя по умолчанию можно, проверив значение системной переменной DWGTITLED. Если DWGTITLED равна 0, чертеж не был переименован пользователем и имеет имя по умолчанию. 

Иногда возникает необходимость проверить, нет ли в чертеже несохраненных изменений. Делать это следует перед выходом из сеанса nanoCAD или перед началом работы над новым чертежом. Чтобы проверить, был ли изменен файл чертежа, необходимо проверить значение системной переменной DBMOD. 

## Закрытие чертежа

Методы Document.CloseAndSave и Document.CloseAndDiscard используются для закрытия открытого чертежа с сохранением изменений и без сохранения соответственно. Также имеется метод DocumentCollection.CloseAll, закрывающий все открытые чертежи в данной сессии AutoCAD. 

## Сохранение активного чертежа

Пример ниже сохраняет активный чертеж по указанному пути с проверкой, отлично ли его имя от данного по умолчанию с помощью переменной DWGTITLED. 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.Runtime;
 
[CommandMethod("SaveActiveDrawing")]
public static void SaveActiveDrawing()
{
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    string strDWGName = acDoc.Name;
 
    object obj = Application.GetSystemVariable("DWGTITLED");
 
    // Check to see if the drawing has been named
    if (System.Convert.ToInt16(obj) == 0)
    {
        // If the drawing is using a default name (Drawing1, Drawing2, etc)
        // then provide a new name
        strDWGName = "c:\\MyDrawing.dwg";
    }
 
    // Save the active drawing
    acDoc.Database.SaveAs(strDWGName, true, DwgVersion.Current,
                          acDoc.Database.SecurityParameters);
}
```

## Проверка, имеются ли не сохраненные изменения

Пример ниже проверяет, имеются ли в чертеже не сохраненные изменения, выводит окно с предложением их сохранить и производит сохранение чертежа. Если сохраняемый чертеж раннее не был сохранен, то сохранение способом ниже будет произведено в тот же каталог, в котором лежит исполняемая библиотека, а расширение файла будет отсутствовать. 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Runtime;
 
[CommandMethod("DrawingSaved")]
public static void DrawingSaved()
{
    object obj = Application.GetSystemVariable("DBMOD");
 
    // Check the value of DBMOD, if 0 then the drawing has no unsaved changes
    if (System.Convert.ToInt16(obj) != 0)
    {
        if (System.Windows.Forms.MessageBox.Show("Do you wish to save this drawing?",
                                  "Save Drawing",
                                  System.Windows.Forms.MessageBoxButtons.YesNo,
                                  System.Windows.Forms.MessageBoxIcon.Question)
                                  == System.Windows.Forms.DialogResult.Yes)
        {
            Document acDoc = Application.DocumentManager.MdiActiveDocument;
            acDoc.Database.SaveAs(acDoc.Name, true, DwgVersion.Current,
                                  acDoc.Database.SecurityParameters);
        }
    }
}
```