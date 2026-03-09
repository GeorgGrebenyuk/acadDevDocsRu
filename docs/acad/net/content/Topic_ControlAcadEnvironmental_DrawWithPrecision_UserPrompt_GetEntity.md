# Запрос одного объекта

Для того, чтобы попросить Пользователя выбрать объект в чертеже имеется метод `Editor.GetEntity` с несколькими перегрузками. Он возвращает экземпляр класса `PromptEntityResult`, свойство которого `ObjectId` возвращает идентификатор выбранного объекта.

Чтобы ограничить выбор конкретными классами, задать иные настройки выбора используется класс `PromptEntityOptions`, затем он подается как аргумент в метод `Editor.GetEntity`.

Добавление фильтра по типу осуществляется с помощью метода `AddAllowedClass`. Можно задавать фильтр как строго для данного объекта, так и для всех типов, наследующих данный класс. К примеру, если `AddAllowedClass(typeof(Curve), false)`, то выберутся все полилинии, отрезки и иные объекты, описываемые классами, производными от `Curve`, а если второй аргумент будет `true`, то в выбор не попадут никакие объекты, так как класс `Curve` является абстрактным.

В примере ниже задается фильтр на выбор полилинии и выводится её длина

```csharp
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;

[CommandMethod("SelectPolyline")]
public void SelectPolyline()
{
    Document doc = Application.DocumentManager.MdiActiveDocument;
    PromptEntityOptions selOpts = new PromptEntityOptions("Select polyline");
    selOpts.SetRejectMessage("Object is not polyline");
    selOpts.AddAllowedClass(typeof(Polyline), true);

    PromptEntityResult selResult = doc.Editor.GetEntity(selOpts);
    if (selResult.Status != PromptStatus.OK) return;
    using (Polyline plineObj = selResult.ObjectId.Open(OpenMode.ForRead, true) as Polyline)
    {
        doc.Editor.WriteMessage($"\nPolyline's length: {plineObj.Length}\n");
    }
}
```

**Примечание**: в AutoCAD .NET API при использовании `AddAllowedClass` важно также задать `RejectMessage`, иначе при использовании метода будет ошибка, что это свойство не задано. В nanoCAD, например, это не обязательно.
