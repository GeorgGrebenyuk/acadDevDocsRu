# Управление видимостью объектов

Если текущий вид это 3D-пространство модели, план, сборка или чертёж, для него можно получить COM-оболочку `Renga.IModelView`, предоставляющую доступ к чтению и редактированию параметров видимости объектов, заданию визуального стиля.

Кроме того, у `IModelView` имеется метод `GetInterfaceByName`, позволяющий безопасно получить [сервис для создания снимков](./Topic_RengaDevGuide_AppProcessing_View_Screens.md).

Методы COM-оболочки `Renga.IModelView` можно разделить на 2 группы:
- управление видимостью объектов;
- управление визуальным стилем вида и отдельных объектов;

## Видимость объектов
- GetHiddenObjects - возвращает массив int-идентификаторов скрытых объектов на данном виде;
- GetVisibleObjects - возвращает массив int-идентификаторов видимых объектов на данном виде;
- IsObjectVisible - возвращает признак, видим ли объект по заданному int-идентификатору на данном виде;
- SetObjectsVisibility - задает признак видимости (или невидимости) для заданной группы int-идентификаторов объектов на данном виде;
- ShowObjects - задает видимость объектов для заданной группы int-идентификаторов объектов на данном виде (только для 3D-вида);
Ниже предлагается авторский метод расширения, задающий видимость объектов для 4 случаев:
```cs
public enum ObjectsVisibilityVariant
{
    ShowAll, //показать все объекты
    HideAll, // скрыть все
    ShowOnlySelected, // скрыть все, кроме выбранных
    HideOnlySelected // показать все, кроме выбранных
}

public static void SetObjectsVisibility2(this Renga.IModelView rengaModelView,
        ObjectsVisibilityVariant mode, int[]? ids)
{
    Renga.IApplication rengaApp;

    Renga.IModel model = rengaApp.Project.Model;
    Renga.IModelObjectCollection rengaObjectsCollection
        = model.GetObjects();

    List<int> idsAll = new List<int>();
    for (int rengaObjectIndex = 0; rengaObjectIndex <
        rengaObjectsCollection.Count; rengaObjectIndex++)
    {
        Renga.IModelObject rengaObject =
            rengaObjectsCollection.GetByIndex(rengaObjectIndex);
        idsAll.Add(rengaObject.Id);
    }

    if (mode == ObjectsVisibilityVariant.ShowAll)
        rengaModelView.SetObjectsVisibility(idsAll.ToArray(), true);
    else if (mode == ObjectsVisibilityVariant.HideAll)
        rengaModelView.SetObjectsVisibility(idsAll.ToArray(), false);
    else if (ids == null || !ids.Any()) return;


    if (mode == ObjectsVisibilityVariant.ShowOnlySelected)
    {
        var idsToHide = idsAll.Except(ids);

        rengaModelView.SetObjectsVisibility(ids, true);
        if (idsToHide.Any()) rengaModelView.
                SetObjectsVisibility(idsToHide.ToArray(), false);
    }
    else if (mode == ObjectsVisibilityVariant.HideOnlySelected)
    {
        var idsToShow = idsAll.Except(ids);

        rengaModelView.SetObjectsVisibility(ids, false);
        if (idsToShow.Any()) rengaModelView.
                SetObjectsVisibility(idsToShow.ToArray(), true);
    }
}
```

### Визуальный стиль
- GetObjectVisualStyle - возвращает визуальный стиль объекта по его int-идентификатору;
- SetObjectsVisualStyle - задает объектам визуальный стиль по их int-идентификаторам;
Свойство VisualStyle - возвращает или задает визуальный стиль для всего вида.


Как правило, 