Настройки пользовательского ввода также позволяют указать набор ключевых слов, фактически являющихся аналогов некоторых enum на стороне исходного кода. Задание ключевых слов реализуется через метод `SetKeywords` объекта класса `PromptSelectionOptions`. Для передачи Пользователю созданных настроек необходимо передать сформированный объект класса PromptSelectionOptions в метод `Editor.GetSelection()`. 

Событие `PromptSelectionOptions.KeywordInput` срабатывает при выборе Пользователем одного из заданных ключевых слов. 

Обработчик `KeywordInput` имеет аргумент `SelectionTextInputEventArgs`, который служит как входным, так и выходным параметром. Свойство `Input` аргумента `SelectionTextInputEventArgs` указывает выбранное ключевое слово. Обработчик сравнивает это ключевое слово с ключевыми словами в списке заданных ключевых слов и вызывает соответствующий метод выбора. Если метод выбора (GetSelection) возвращает какие-либо элементы модели, приложение добавляет их в аргумент `SelectionTextInputEventArgs` с помощью метода `SelectionTextInputEventArgs.AddObjects`. 

В следующем примере определены пять ключевых слов и добавлен обработчик события `KeywordInput` для перехвата ключевого слова, указанного Пользователем. 

```cs
private static void SelectionKeywordInputHandler(object sender, SelectionTextInputEventArgs eSelectionInput)
{
	// Gets the current document editor and define other variables for the current scope
	Editor acDocEd = Application.DocumentManager.MdiActiveDocument.Editor;
    PromptSelectionResult acSSPrompt = null;
    SelectionSet acSSet = null;
    ObjectId[] acObjIds = null;

	   // See if the user choose the myFence keyword
	   switch (eSelectionInput.Input) {
        case "myFence":
			         // Uses the four points to define a fence selection
            Point3dCollection ptsFence = new Point3dCollection();
            ptsFence.Add(new Point3d(5.0, 5.0, 0.0));
            ptsFence.Add(new Point3d(13.0, 15.0, 0.0));
            ptsFence.Add(new Point3d(12.0, 9.0, 0.0));
            ptsFence.Add(new Point3d(5.0, 5.0, 0.0));

            acSSPrompt = acDocEd.SelectFence(ptsFence);
			         break;
        case "myWindow":
			         // Defines a rectangular window selection
            acSSPrompt = acDocEd.SelectWindow(new Point3d(1.0, 1.0, 0.0), new Point3d(30.0, 20.0, 0.0));
			         break;
        case "myWPoly":
			         // Uses the four points to define a polygon window selection
            Point3dCollection ptsPolygon = new Point3dCollection();
            ptsPolygon.Add(new Point3d(5.0, 5.0, 0.0));
            ptsPolygon.Add(new Point3d(13.0, 15.0, 0.0));
            ptsPolygon.Add(new Point3d(12.0, 9.0, 0.0));
            ptsPolygon.Add(new Point3d(5.0, 5.0, 0.0));

            acSSPrompt = acDocEd.SelectWindowPolygon(ptsPolygon);
			         break;
		      case "myLastSel":
			        // Gets the last object created
			        acSSPrompt = acDocEd.SelectLast();
			        break;
		      case "myPrevSel":
			        // Gets the previous object selection set
			        acSSPrompt = acDocEd.SelectPrevious();
			        break;
	   }

    // If the prompt status is OK, objects were selected and return
    if (acSSPrompt != null)
    {
        if (acSSPrompt.Status == PromptStatus.OK)
        {
            // Objects were selected, so add them to the current selection
            acSSet = acSSPrompt.Value;
            acObjIds = acSSet.GetObjectIds();
            eSelectionInput.AddObjects(acObjIds);
        }
    }
}

[CommandMethod("SelectionKeywordInput")]
public static void SelectionKeywordInput()
{
    // Gets the current document editor
    Editor acDocEd = Application.DocumentManager.MdiActiveDocument.Editor;

    // Setups the keyword options
    PromptSelectionOptions acKeywordOpts = new PromptSelectionOptions();
    acKeywordOpts.Keywords.Add("myFence");
    acKeywordOpts.Keywords.Add("myWindow");
    acKeywordOpts.Keywords.Add("myWPoly");
    acKeywordOpts.Keywords.Add("myLastSel");
    acKeywordOpts.Keywords.Add("myPrevSel");

    // Adds the event handler for keyword input
    acKeywordOpts.KeywordInput += new SelectionTextInputEventHandler(SelectionKeywordInputHandler);

    // Prompts the user for a selection set
    PromptSelectionResult acSSPrompt = acDocEd.GetSelection(acKeywordOpts);

    // If the prompt status is OK, objects were selected
    if (acSSPrompt.Status == PromptStatus.OK)
    {
        // Gets the selection set
        SelectionSet acSSet = acSSPrompt.Value;

        // Gets the objects from the selection set
        ObjectId[] acObjIds = acSSet.GetObjectIds();
        Database acCurDb = Application.DocumentManager.MdiActiveDocument.Database;

        // Starts a transaction
        using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
        {
            try
            {
                // Gets information about each object
                foreach (ObjectId acObjId in acObjIds)
                {
                    Entity acEnt = (Entity)acTrans.GetObject(acObjId, OpenMode.ForWrite, true);
                    acDocEd.WriteMessage("\nObject selected: " + acEnt.GetType().FullName);

                }
            }
            finally
            {
                acTrans.Dispose();
            }
        }
    }

    // Removes the event handler for keyword input
    acKeywordOpts.KeywordInput -= new SelectionTextInputEventHandler(SelectionKeywordInputHandler);
}
```