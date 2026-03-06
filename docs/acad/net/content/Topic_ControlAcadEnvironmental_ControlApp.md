# Взаимодействие с окном приложения AutoCAD

Иногда исполняемому приложению бывает необходимо свернуть окно AutoCAD или запросить его состояние. Для этого используются методы статического класса Application. С их помощью можно изменять положение, размер и видимость окна приложения, также можно использовать свойство WindowState для получения и задания текущего состояния окна приложения. 
**Примечание**: Следующие примеры требуют наличия в проекте ссылки на библиотеку PresentationCore (PresentationCore.dll). Воспользуйтесь диалоговым окном Add Reference и выберите PresentationCore на вкладке .NET (при использовании .NET Framework). При использовании .NET6 в свойствах проекта csproj внесите строку UseWPF = True. Некоторые примеры также требуют ссылки на библиотеки WindowsForms, добавьте в проект на .NET6+ UseWindowsForms = True. 

```xml
  <PropertyGroup>
    <TargetFramework>net6.0-windows</TargetFramework>
    <UseWP>true</UseWPF>
    <UseWindowsForms>true</UseWindowsForms>
  </PropertyGroup>
```

## Установка положения и размера окна приложения

Свойства Application.MainWindow.DeviceIndependentLocation, Application.MainWindow.DeviceIndependentSize в текущей версии .NET API не доступны для редактирования (в отличие от AutoCAD .NET API). ##  Разворачивание на полный экран и свертывание приложения  

```cs
using HostMgd.Windows;
using HostMgd.ApplicationServices;
using Teigha.Runtime;
[CommandMethod("MinMaxApplicationWindow")]
public static void MinMaxApplicationWindow()
{
    //Minimize the Application window
    Application.MainWindow.WindowState = Window.State.Minimized;
    System.Windows.Forms.MessageBox.Show("Minimized", "MinMax",
                System.Windows.Forms.MessageBoxButtons.OK,
                System.Windows.Forms.MessageBoxIcon.None,
                System.Windows.Forms.MessageBoxDefaultButton.Button1,
                System.Windows.Forms.MessageBoxOptions.ServiceNotification);
    //Maximize the Application window
    Application.MainWindow.WindowState = Window.State.Maximized;
    System.Windows.Forms.MessageBox.Show("Maximized", "MinMax");
}
```

## Получение текущего состояния приложения

Пример ниже получает текущее состояние окна приложения и выводит в консоль nanoCAD информацию: 

```cs
[CommandMethod("CurrentWindowState")]
public static void CurrentWindowState()
{
    System.Windows.Forms.MessageBox.Show("The application window is " +
                                            Application.MainWindow.WindowState.ToString(),
                                            "Window State");
}
```

## Управление видимостью окна приложения

Пример ниже использует свойство Visible для установки приложения сперва невидимым (скрытым), а затем снова видимым. 

```cs
[CommandMethod("HideWindowState")]
public static void HideWindowState()
{
    //Hide the Application window
    Application.MainWindow.Visible = false;
    System.Windows.Forms.MessageBox.Show("Invisible", "Show/Hide");
    //Show the Application window
    Application.MainWindow.Visible = true;
    System.Windows.Forms.MessageBox.Show("Visible", "Show/Hide");
}
```
