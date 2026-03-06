# Получение доступа к выбранным объектам (PickFirst)

Набор выбора `PickFirst` создается при выборе объектов перед запуском команды. Для получения объектов набора выбора `PickFirst` необходимо выполнить несколько условий: 

* Системная переменная PICKFIRST должна быть установлена в 1; 
* Флаг команды `UsePickSet` должен быть определен с помощью команды, которая должна использовать набор выбора PickFirst; 

```cs
[CommandMethod("ShowObject", CommandFlags.UsePickSet)]
```

* Чтобы получить набор выбора PickFirst используйте метод `Editor.SelectImplied`. 
  Метод SetImpliedSelection используется для очистки текущего набора выбора PickFirst. 

## Получение текущего набора выбора PickFirst

В коде ниже выводится количество объектов в наборе выбора `PickFirst`, а затем пользователю предлагается выбрать дополнительные объекты. Перед тем как предложить пользователю выбрать объекты, текущий набор выбора `PickFirst` очищается с помощью метода `SetImpliedSelection`. 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;

[CommandMethod("CheckForPickfirstSelection", CommandFlags.UsePickSet)]
public static void CheckForPickfirstSelection()
{
    // Get the current document
    Editor acDocEd = Application.DocumentManager.MdiActiveDocument.Editor;

    // Get the PickFirst selection set
    PromptSelectionResult acSSPrompt;
    acSSPrompt = acDocEd.SelectImplied();

    SelectionSet acSSet;

    // If the prompt status is OK, objects were selected before
    // the command was started
    if (acSSPrompt.Status == PromptStatus.OK)
    {
        acSSet = acSSPrompt.Value;

        Application.ShowAlertDialog("Number of objects in Pickfirst selection: " +
                                    acSSet.Count.ToString());
    }
    else
    {
        Application.ShowAlertDialog("Number of objects in Pickfirst selection: 0");
    }

    // Clear the PickFirst selection set
    ObjectId[] idarrayEmpty = new ObjectId[0];
    acDocEd.SetImpliedSelection(idarrayEmpty);

    // Request for objects to be selected in the drawing area
    acSSPrompt = acDocEd.GetSelection();

    // If the prompt status is OK, objects were selected
    if (acSSPrompt.Status == PromptStatus.OK)
    {
        acSSet = acSSPrompt.Value;

        Application.ShowAlertDialog("Number of objects selected: " +
                                    acSSet.Count.ToString());
    }
    else
    {
        Application.ShowAlertDialog("Number of objects selected: 0");
    }
}
```
