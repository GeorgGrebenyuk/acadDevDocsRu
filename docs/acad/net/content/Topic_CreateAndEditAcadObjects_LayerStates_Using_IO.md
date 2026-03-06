# Экспорт и загрузка набора состояний

Вы можете экспортировать и импортировать сохраненные наборы состояний слоев, чтобы использовать те же настройки слоев в других чертежах (помимо метода ImportLayerStateFromDb). Используйте метод ExportLayerState для экспорта сохраненного состояния слоев в обменный файл LAS; используйте метод ImportLayerState для импорта файла LAS в чертеж.

**Примечание**: Импорт набора состояний слоев не восстанавливает их; для восстановления состояния слоев после импорта необходимо использовать метод `RestoreLayerState`.
Метод `ExportLayerState` принимает два аргумента. Первый аргумент — это наименование экспортируемого набора состояний слоев. Второй аргумент — это имя файла, в который вы сохраняете эти настройки. Если вы не укажете путь к файлу, он будет сохранен в том же каталоге, из которого был открыт чертеж. Если указанное вами имя файла уже существует, существующий файл будет перезаписан. Используйте расширение .las при именовании файлов; это расширение распознается AutoCAD для файлов состояний слоев.
Метод `ImportLayerState` принимает один параметр: путь к файлу с набором состояний. Если набор состояний слоев, который вы хотите импортировать, отсутствует в файле LAS, но существует в файле чертежа, вы можете открыть базу данных целевого чертежа, а затем использовать метод ImportLayerStateFromDb для импорта данных из неё.
При импорте состояний слоев могут возникнуть ошибки, если указанные в настройках данные недоступны в данном чертеже, в этом случае недоступные данные заменятся на настройки по умолчанию. Например, если слою по настройкам был задан тип линии, который не загружен в чертеж, в который он импортируется, возникнет ошибка обработки, и подставится тип линии по умолчанию для текущего чертежа. При программной работе у вас отловится ошибка, но сама процедура обработки должна продолжиться.
Если импортируемый файл определяет настройки для слоев, которые не существуют в текущем чертеже, эти слои создаются в текущем чертеже с заданными настройками. При использовании метода RestoreLayerState новым слоям присваиваются свойства, указанные при сохранении настроек; всем остальным свойствам новых слоев присваиваются значения по умолчанию.

## Экспорт настроек состояний

Пример ниже сохраняет набор состояний "ColorLinetype", созданный в примерах раннее, в файл на ПК. 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("ExportLayerState")]
public static void ExportLayerState()
{
    // Get the current document
    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    LayerStateManager acLyrStMan;
    acLyrStMan = acDoc.Database.LayerStateManager;

    string sLyrStName = "ColorLinetype";

    if (acLyrStMan.HasLayerState(sLyrStName) == true)
    {
        acLyrStMan.ExportLayerState(sLyrStName, "c:\\my documents\\" +
                                                sLyrStName + ".las");
    }
}
```

## Импорт настроек состояний

Пример ниже загружает из файла настройки состояний слоев (но не делает их активными, для этого используйте `RestoreLayerState`). 

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("ImportLayerState")]
public static void ImportLayerState()
{
    // Get the current document
    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    LayerStateManager acLyrStMan;
    acLyrStMan = acDoc.Database.LayerStateManager;

    string sLyrStFileName = "c:\\my documents\\ColorLinetype.las";

    if (System.IO.File.Exists(sLyrStFileName))
    {
        try
        {
            acLyrStMan.ImportLayerState(sLyrStFileName);
        }
        catch (Autodesk.AutoCAD.Runtime.Exception ex)
        {
            Application.ShowAlertDialog(ex.Message);
        }
    }
}
```
