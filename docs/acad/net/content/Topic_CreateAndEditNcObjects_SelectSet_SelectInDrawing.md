# Выбор объектов в чертеже

Вы можете выбирать объекты, предоставляя пользователю возможность интерактивного выбора, или имитировать различные варианты выбора объектов с помощью API AutoCAD .NET (без участия Пользователя). Если ваша программа выполняет несколько наборов выбора, вам потребуется либо отслеживать каждый возвращаемый набор выбора, либо создать объект ObjectIdCollection для получения всех выбранных объектов. Следующие функции позволяют выбирать объекты из чертежа: 

* `GetSelection` : запрос Пользователя указать объекты на чертеже; 
* `SelectAll` : выбрать все объекты в чертеже (выберутся все объекты в пространстве модели и на листах, а также все объекты на заблокированных и замороженных слоях); 
* `SelectCrossingPolygon` : выбор объектов, расположенных внутри и/или пересекающих некоторый многоугольник, определенный заданными точками. Многоугольник может иметь любую форму, но не может пересекать или касаться самого себя; 
* `SelectCrossingWindow` : выбор объектов, расположенных внутри или пересекающих некоторый прямоугольный контур, заданный двумя вершинами (минимальной и максимальной точками); 
* `SelectFence` : выбор объектов, пересекающих рамку. Выбор с помощью рамки аналогичен SelectCrossingPolygon, за исключением того, что рамка не замкнута, и может пересекать саму себя; 
* `SelectLast` : выбор объекта в данном пространстве, созданного последним; 
* `SelectPrevious` : выбор объектов из ранней выборки; 
* `SelectWindow` : выбор объектов, расположенных строго внутри некоторого прямоугольного контура, заданного двумя вершинами (минимальной и максимальной точками). В отличие от SelectCrossingWindow не допускает пересечения объектами контура; 
* `SelectWindowPolygon` : выбор объектов, расположенных строго внутри некоторого контура, заданного набором точек. Полигон может быть любой формы, но не может пересекать или касаться самого себя; 
* `SelectAtPoint` : выбор объектов, проходящих через заданную точку и добавление их в активный набор выделенных объектов. 
* `SelectByPolygon` : выбор объектов внутри некоторого контура и добавление их в активный набор выделенных объектов. 

## Запрос отображенных на экране объектов и их перебор

Код ниже содержит запрос к Пользователю на выбор объектов, затем для каждого объекта меняется цвет на зеленый (ColorIndex = 3)

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
 
[CommandMethod("SelectObjectsOnscreen")]
public static void SelectObjectsOnscreen()
{
    // Get the current document and database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;

    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Request for objects to be selected in the drawing area
        PromptSelectionResult acSSPrompt = acDoc.Editor.GetSelection();

        // If the prompt status is OK, objects were selected
        if (acSSPrompt.Status == PromptStatus.OK)
        {
            SelectionSet acSSet = acSSPrompt.Value;

            // Step through the objects in the selection set
            foreach (SelectedObject acSSObj in acSSet)
            {
                // Check to make sure a valid SelectedObject object was returned
                if (acSSObj != null)
                {
                    // Open the selected object for write
                    Entity acEnt = acTrans.GetObject(acSSObj.ObjectId,
                                                        OpenMode.ForWrite) as Entity;

                    if (acEnt != null)
                    {
                        // Change the object's color to Green
                        acEnt.ColorIndex = 3;
                    }
                }
            }

            // Save the new object to the database
            acTrans.Commit();
        }

        // Dispose of the transaction
    }
}
```

## Выбор объектов для ограничивающего прямоугольника

Код ниже осуществляет выбор объектов без участия Пользователя для прямоугольной области, заданной двумя крайними точками 2,2,0) и (10,8,0) 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.EditorInput;
 
[CommandMethod("SelectObjectsByCrossingWindow")]
public static void SelectObjectsByCrossingWindow()
{
    // Get the current document editor
    Editor acDocEd = Application.DocumentManager.MdiActiveDocument.Editor;

    // Create a crossing window from (2,2,0) to (10,8,0)
    PromptSelectionResult acSSPrompt;
    acSSPrompt = acDocEd.SelectCrossingWindow(new Point3d(2, 2, 0),
                                                new Point3d(10, 8, 0));

    // If the prompt status is OK, objects were selected
    if (acSSPrompt.Status == PromptStatus.OK)
    {
        SelectionSet acSSet = acSSPrompt.Value;

        Application.ShowAlertDialog("Number of objects selected: " +
                                    acSSet.Count.ToString());
    }
    else
    {
        Application.ShowAlertDialog("Number of objects selected: 0");
    }
}
```
