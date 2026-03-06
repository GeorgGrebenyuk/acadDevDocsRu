# Расширение интерфейса nanoCAD

В дополнение к стандартным окнам и диалогам AutoCAD, через API можно реализовать создание различных окон для ввода и отображения каких-либо данных. Классы из пространства имён Autodesk.Windows позволяют получать доступ к некоторым стандартным окнам для выбор слоя, типа линии и т.д. Эти классы предоставляют метод ShowDialog, который отображает форму. При использовании этих стандартных классов AutoCAD автоматически задает им размер и положение на экране. 

Пользовательские диалоговые окна могут быть созданы на основе System.Windows.Forms (Windows Forms) или System.Windows.Window (WPF). Несмотря на возможность открытия форм с помощью метода ShowDialog им не рекомендуется пользоваться, так как это может привести к неожиданному поведению. Вместо этого следует использовать специальные методы у статического класса Application: ShowModalDialog или ShowModelessDialog для Windows Forms и ShowModalWindow или ShowModelessWindow для WPF. Они открывают окна в специальном модальном режиме. При желании создать пользовательскую палитру, содержащую форму можно воспользоваться следующим минималистичным примером. Добавление форм на основе WPF осуществляется через метод AddVisual; форм на основе WinForms -- через метод Add. 

```cs
using System;
using System.Drawing;
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;

public class ObjectsAttributes_Palette
{
    private static Guid ps_Attrs_id = Guid.Parse("{750d30d1-c5fc-4ae4-99f1-6cc59417d33b}");
    static Autodesk.AutoCAD.Windows.PaletteSet? ps_Attrs;
    public static void CreatePalette()
    {
        if (ps_Attrs == null)
        {
            //use constructor with Guid so that we can save/load user data
            Autodesk.AutoCAD.Windows.PaletteSet
            ps_Attrs = new Autodesk.AutoCAD.Windows.PaletteSet("ObjectProps", ps_Attrs_id);
            ps_Attrs.MinimumSize = new Size(241, 300);
            ps_Attrs.Size = new Size(241, 300);
            ps_Attrs.AddVisual("WPF-форма", new PropertyPalette_WPF());
            ps_Attrs.Add("WinForms-форма", new PropertyPalette_WinForms())
            }
        ps_Attrs.Visible = true;
    }
    [CommandMethod("ShowPalette")]
    public static void ShowPalette()
    {
        CreatePalette();
    }
}
```

Возможности расширить интерфейс nanoCAD за счет добавления своих меню и ленты при помощи .NET API нет; эти настройки задаются только с помощью CFG и CUIX-файлов. 

При разработке под nanoCAD на WPF рекомендуется использовать промежуточное представление System.Windows.Forms.Integration.ElementHost, поскольку при попытке добавления контрола WPF стандартной командой AddVisual он не будет полностью отрисован. Дополняя пример выше, для вставки WPF-контрола код будет выглядеть как: 

```cs
var hostView = new ElementHost
{
    AutoSize = false,
    Dock = System.Windows.Forms.DockStyle.Fill,
    Child = new AnyWPFcontrol()
};
palset.Add("WPF-control", hostView);
```

Для AutoCAD это изменение не повлечет никаких последствий
