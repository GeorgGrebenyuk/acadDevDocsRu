# Работа с XData

Возможно использовать т.н. "xdata" для сохранения различной информации в чертеже. Для того, чтобы сохранить некоторую информацию, в чертеже должно быть зерегистрировано приложение (иметься запись RegAppTableRecord). 

В примере ниже получается набор объектов из пользовательского выбора, и в свойство XData каждого из объектов добавляется ResultBuffer из пары значений -- имени приложения и некоторой текстовой строки (или иного типа данных для ResultBuffer, см. [соответствующую статью](\Topic_CreateAndEditNcObjects_ResultBuffer.md).

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.EditorInput;

[CommandMethod("AttachXDataToSelectionSetObjects")]
public void AttachXDataToSelectionSetObjects()
{
    // Get the current database and start a transaction
    Database acCurDb;
    acCurDb = Application.DocumentManager.MdiActiveDocument.Database;

    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    string appName = "MY_APP";
    string xdataStr = "This is some xdata";

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Request objects to be selected in the drawing area
        PromptSelectionResult acSSPrompt = acDoc.Editor.GetSelection();

        // If the prompt status is OK, objects were selected
        if (acSSPrompt.Status == PromptStatus.OK)
        {
            // Open the Registered Applications table for read
            RegAppTable acRegAppTbl;
            acRegAppTbl = acTrans.GetObject(acCurDb.RegAppTableId, OpenMode.ForRead) as RegAppTable;

            // Check to see if the Registered Applications table record for the custom app exists
            if (acRegAppTbl.Has(appName) == false)
            {
                using (RegAppTableRecord acRegAppTblRec = new RegAppTableRecord())
                {
                    acRegAppTblRec.Name = appName;

                    acTrans.GetObject(acCurDb.RegAppTableId, OpenMode.ForWrite);
                    acRegAppTbl.Add(acRegAppTblRec);
                    acTrans.AddNewlyCreatedDBObject(acRegAppTblRec, true);
                }
            }

            // Define the Xdata to add to each selected object
            using (ResultBuffer rb = new ResultBuffer())
            {
                rb.Add(new TypedValue((int)DxfCode.ExtendedDataRegAppName, appName));
                rb.Add(new TypedValue((int)DxfCode.ExtendedDataAsciiString, xdataStr));

                SelectionSet acSSet = acSSPrompt.Value;

                // Step through the objects in the selection set
                foreach (SelectedObject acSSObj in acSSet)
                {
                    // Open the selected object for write
                    Entity acEnt = acTrans.GetObject(acSSObj.ObjectId,
                                                        OpenMode.ForWrite) as Entity;

                    // Append the extended data to each object
                    acEnt.XData = rb;
                }
            }
        }

        // Save the new object to the database
        acTrans.Commit();

        // Dispose of the transaction
    }
}
```

В примере ниже сохраненная в примере выше информация выводится в командную строку для каждого из объектов из пользовательского выбора 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.EditorInput;

[CommandMethod("ViewXData")]
public void ViewXData()
{
    // Get the current database and start a transaction
    Database acCurDb;
    acCurDb = Application.DocumentManager.MdiActiveDocument.Database;

    Document acDoc = Application.DocumentManager.MdiActiveDocument;

    string appName = "MY_APP";
    string msgstr = "";

    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Request objects to be selected in the drawing area
        PromptSelectionResult acSSPrompt = acDoc.Editor.GetSelection();

        // If the prompt status is OK, objects were selected
        if (acSSPrompt.Status == PromptStatus.OK)
        {
            SelectionSet acSSet = acSSPrompt.Value;

            // Step through the objects in the selection set
            foreach (SelectedObject acSSObj in acSSet)
            {
                // Open the selected object for read
                Entity acEnt = acTrans.GetObject(acSSObj.ObjectId,
                                                 OpenMode.ForRead) as Entity;

                // Get the extended data attached to each object for MY_APP
                ResultBuffer rb = acEnt.GetXDataForApplication(appName);

                // Make sure the Xdata is not empty
                if (rb != null)
                {
                    // Get the values in the xdata
                    foreach (TypedValue typeVal in rb)
                    {
                        msgstr = msgstr + "\n" + typeVal.TypeCode.ToString() + ":" + typeVal.Value;
                    }
                }
                else
                {
                    msgstr = "NONE";
                }

                // Display the values returned
                Application.ShowAlertDialog(appName + " xdata on " + acEnt.GetType().ToString() + ":\n" + msgstr);

                msgstr = "";
            }
        }

        // Ends the transaction and ensures any changes made are ignored
        acTrans.Abort();

        // Dispose of the transaction
    }
}
```
