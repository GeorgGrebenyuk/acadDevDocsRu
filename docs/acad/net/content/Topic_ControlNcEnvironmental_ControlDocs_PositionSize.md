Используйте свойство Window у экземпляра класса Document для редактирования его положения и размера. Окно документа, как и окно приложения, можно раскрыть или скрыть, изменяя свойство WindowState 

## Разворачивание на полный экран и свертывание окна документа

```cs
[CommandMethod("MinMaxDocumentWindow")]
public static void MinMaxDocumentWindow()
{
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    //Minimize the Document window
    acDoc.Window.WindowState = Window.State.Minimized;
    System.Windows.Forms.MessageBox.Show("Minimized" , "MinMax");
    //Maximize the Document window
    acDoc.Window.WindowState = Window.State.Maximized;
    System.Windows.Forms.MessageBox.Show("Maximized" , "MinMax");
}
```

## Получение текущего состояния окна документа

```cs
[CommandMethod("CurrentDocWindowState")]
public static void CurrentDocWindowState()
{
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    System.Windows.Forms.MessageBox.Show("The document window is " +
    acDoc.Window.WindowState.ToString(), "Window State");
}
```