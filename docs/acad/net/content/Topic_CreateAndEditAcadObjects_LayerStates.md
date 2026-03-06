# Состояния слоев

Со слоем также связано понятие "Состояние слоя" (в AutoCAD он также называется "Фильтр" в окне СЛОЙ). Оно включают в себя информацию о том, включен ли слой, заморожен ли он, заблокирован ли, выведен ли на печать и автоматически замораживается ли в видовых экранах, а также хранит информацию о цвете слоя, связанных типа линии, толщины линии и стиля печати. Данные о состоянии слоя можно сохранить и обратиться к ним позднее; этот инструмент облегчает хранение различных конфигураций настроек слоев. 

Доступ к состояниям слоев осуществляется через вспомогательный класс `LayerStateManager` (состоит из набора словарей), возвращаемый через одноименное свойство у объекта Database. 

## Подробнее о механике сохранения состояний слоя

AutoCAD сохраняет информацию о настройках слоев в словаре расширений объекта `LayerTable`. При первом сохранении состояния слоя AutoCAD выполняет следующие действия: 

* Создает словарь расширений в таблице слоев; 
* Создает объект Dictionary с именем ACAD_LAYERSTATE в словаре расширений; 
* Сохраняет свойства каждого слоя чертежа в объекте XRecord в словаре ACAD_LAYERSTATE. AutoCAD сохраняет все настройки слоев в XRecord, но в дальнейшем при восстановлении будет использоваться только те, которые вы выбрали для сохранения; 

При сохранении других настроек слоев в чертеже, AutoCAD создает другой объект XRecord, описывающий сохраненные настройки, и сохраняет XRecord в словаре ACAD_LAYERSTATE. 

## Сохранение и чтение состояний слоев

Пример ниже сохраняет информацию о состоянии слоев (заморозка, видимость, цвет) в набор "Config1": 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("SaveLayerStates")]
public static void SaveLayerStates()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;
    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        LayerStateManager acLyrStMan;
        acLyrStMan = acCurDb.LayerStateManager;
        acLyrStMan.SaveLayerState("Config1", LayerStateMasks.Frozen | LayerStateMasks.On |
LayerStateMasks.Color, ObjectId.Null);
        acTrans.Commit();
    }
}
```

Пример ниже выводит информации в модальное окно о конфигурациях слоев, имеющихся в данном чертеже 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("ListLayerStates")]
public static void ListLayerStates()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;
    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        LayerStateManager acLyrStMan;
        acLyrStMan = acCurDb.LayerStateManager;
        DBDictionary acDbDict;
        acDbDict = acTrans.GetObject(acLyrStMan.LayerStatesDictionaryId(true),
                                        OpenMode.ForRead) as DBDictionary;
        string sLayerStateNames = "";
        foreach (DBDictionaryEntry acDbDictEnt in acDbDict)
        {
            sLayerStateNames = sLayerStateNames + "\\n" + acDbDictEnt.Key;
        }
        Application.ShowAlertDialog("The saved layer settings in this drawing are:" +
                                    sLayerStateNames);
        // Dispose of the transaction
    }
}
```
