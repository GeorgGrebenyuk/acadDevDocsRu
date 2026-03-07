# Перехват runtime-ошибок

На языке программирования C# вы можете использовать специальные операторы try\\catch\\finally. В примере ниже показана пример использования подобных конструкций, хотя в данном контексте более корректной была бы проверка, существует ли файл по указанному пути с помощью системного метода System.IO.File.Exists(). 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;

[CommandMethod("NoErrorHandler")]
public void NoErrorHandler()
{
    // Create a new database with no document window
    using (Database acDb = new Database(false, true))
    {
        // Read the drawing file named "Drawing123.dwg" on the C: drive.
        // If the "Drawing123.dwg" file does not exist, an eFileNotFound
        // exception is tossed and the program halts.
        acDb.ReadDwgFile("c:\\Drawing123.dwg",
                         System.IO.FileShare.None, false, "");
    }
    // Message will not be displayed since the exception caused by
    // ReadDwgFile is not handled.
    Application.ShowAlertDialog("End of command reached");
}
[CommandMethod("ErrorTryCatchFinally")]
public void ErrorTryCatchFinally()
{
    // Create a new database with no document window
    using (Database acDb = new Database(false, true))
    {
        try
        {
            // Read the drawing file named "Drawing123.dwg" on the C: drive.
            // If the "Drawing123.dwg" file does not exist, an eFileNotFound
            // exception is tossed and the catch statement handles the error.
            acDb.ReadDwgFile("c:\\Drawing123.dwg",
                             System.IO.FileShare.None, false, "");
        }
        catch (Autodesk.AutoCAD.Runtime.Exception Ex)
        {
            Application.ShowAlertDialog("The following exception was caught:\\n" +
                                        Ex.Message);
        }
        finally
        {
            // Message is displayed since the exception caused
            // by ReadDwgFile is handled.
            Application.ShowAlertDialog("End of command reached");
        }
    }
}
```

## Использование объекта Exception

Перехватываемое в теле блока catch исключение описывается классом `Autodesk.AutoCAD.Runtime.Exception`, который является дочерним классом от System.Exception. Свойство `ErrorStatus` данного исключения вернет один из кодов ошибки, специфичной для AutoCAD, описываемых одноименным перечислением из того же пространства имен `Autodesk.AutoCAD.Runtime`.