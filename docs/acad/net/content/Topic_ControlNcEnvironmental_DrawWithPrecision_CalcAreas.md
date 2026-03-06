# Расчет площадей

С помощью свойства `Area` можно определить площадь дуги, окружности, эллипса, полилинии (будь она замкнутой), региона (Region), штриховки, плоско-замкнутого сплайна или любого другого объекта, наследующего класс Curve. Если вам нужно вычислить общую площадь нескольких объектов, вы можете суммировать получаемые значения для отдельных объектов или использовать метод Boolean для объединения нескольких объектов в один. Вычисляемая площадь зависит от типа объекта. Если площадь считается для фигуры, состоящей из заданных Пользователем точек, то можно создать в памяти временный объект, например, полилинию и посчитать её площадь. После выполнения расчета временный объект можно будет удалить. Ниже описывается подробно такой механизм действий: 

* Используйте метод GetPoint в цикле для получения точек от пользователя; 
* Создайте определение полилинии (Polyline) из точек, указанных пользователем. Для этого создайте новый объект Polyline, затем укажите количество вершин и точки, в которых они должны находиться; 
* Используйте свойство Area, чтобы получить площадь созданной полилинии; 
* Удалите полилинию с помощью метода Dispose. 

В примере ниже пользователю предлагается ввести 5 точек. По введенным точкам создается полилиния, далее она замыкается, считается её площадь и вводится в диалоговом окне. Так как полилиния не будет записана в пространство блока, необходимо её удалить до завершения команды. 

```cs
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Runtime;

[CommandMethod("CalculateDefinedArea")]
public static void CalculateDefinedArea()
{
    // Prompt the user for 5 points
    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    PromptPointResult pPtRes;
    Point2dCollection colPt = new Point2dCollection();
    PromptPointOptions pPtOpts = new PromptPointOptions("");

    // Prompt for the first point
    pPtOpts.Message = "\nSpecify first point: ";
    pPtRes = acDoc.Editor.GetPoint(pPtOpts);
    colPt.Add(new Point2d(pPtRes.Value.X, pPtRes.Value.Y));

    // Exit if the user presses ESC or cancels the command
    if (pPtRes.Status == PromptStatus.Cancel) return;

    int nCounter = 1;

    while (nCounter <= 4)
    {
        // Prompt for the next points
        switch(nCounter)
        {
            case 1:
                pPtOpts.Message = "\nSpecify second point: ";
                break;
            case 2:
                pPtOpts.Message = "\nSpecify third point: ";
                break;
            case 3:
                pPtOpts.Message = "\nSpecify fourth point: ";
                break;
            case 4:
                pPtOpts.Message = "\nSpecify fifth point: ";
                break;
        }

        // Use the previous point as the base point
        pPtOpts.UseBasePoint = true;
        pPtOpts.BasePoint = pPtRes.Value;

        pPtRes = acDoc.Editor.GetPoint(pPtOpts);
        colPt.Add(new Point2d(pPtRes.Value.X, pPtRes.Value.Y));

        if (pPtRes.Status == PromptStatus.Cancel) return;

        // Increment the counter
        nCounter = nCounter + 1;
    }

    // Create a polyline with 5 points
    using (Polyline acPoly = new Polyline())
    {
        acPoly.AddVertexAt(0, colPt[0], 0, 0, 0);
        acPoly.AddVertexAt(1, colPt[1], 0, 0, 0);
        acPoly.AddVertexAt(2, colPt[2], 0, 0, 0);
        acPoly.AddVertexAt(3, colPt[3], 0, 0, 0);
        acPoly.AddVertexAt(4, colPt[4], 0, 0, 0);

        // Close the polyline
        acPoly.Closed = true;

        // Query the area of the polyline
        Application.ShowAlertDialog("Area of polyline: " +
                                    acPoly.Area.ToString());

        // Dispose of the polyline
    }
}
```
