# Работа с загруженными файлами и объектами

Рассмотрим, как получить перечень данных в модели (объектов с иерархией, обладающих свойствами и геометрией). То есть методам API, которые соответствуют "Дереву выбора" в UI Navisworks.

Первоначально необходимо получить перечень загруженных файлов\проектов через методы со стороны COM-оболочки **InwOpState7**. Напомним, что проект описывается с помощью COM-оболочки `InwOaPartition`.
```cs
using System.Runtime.InteropServices;
using NavisworksAutomationAPI18;
using NavisworksIntegratedAPI18;

Inavisdoc3? nwDoc = Marshal.GetActiveObject("Navisworks.Document.18") as Inavisdoc3;
InwOpState11? nwState = nwDoc.State() as InwOpState11;

for (int fileIndex = 0; fileIndex < nwState.LoadedFileCount; fileIndex++)
{
    InwOaPartition nwPartition = nwState.LoadedFileFromNdx(fileIndex + 1);
}
```
**Примечание**: обращаем внимание, что все коллекции внутри Navisworks начинаются не с 0, а с 1 (для этого в теле метода LoadedFileFromNdx делаем `+1`);

Всего в Navisworks COM API существует 4 разных оболочки, описывающих содержимое загруженных в него данных:
* `InwOaPartition` (также `InwOaPartition2`, `InwOaPartition3`) - представляет собой отдельный проект\файл;
* `InwOaGroup` - представляет любой элемент, у которого есть потомки (вложенные элементы по иерархии);
* `InwOaNode` - базовая оболочка для любых объектов, фактически предоставляет полноценный доступ к объекту;
* `InwOaGeometry` - обёртка над геометрией. Никаких специальных методов не содержит, кроме того, что для неё свойство Fragments у `InwOaNode` вернет набор составляющих геометрию объектов и далее с ней продолжится работа, об этом чуть позднее).

Далее для каждого загруженного файла необходимо получить рекурсивно доступ к элементам. В примере ниже полученная информация выводится в окно.

```cs
using System;
using System.Runtime.InteropServices;
using System.Text;
using NavisworksAutomationAPI18;
using NavisworksIntegratedAPI18;

using System.Windows; //WPF, MessageBox

Inavisdoc3? nwDoc = Marshal.GetActiveObject("Navisworks.Document.18") as Inavisdoc3;
InwOpState11? nwState = nwDoc.State() as InwOpState11;

StringBuilder tmpStructure = new StringBuilder();
tmpStructure.AppendLine("Hierarchy info");

for (int fileIndex = 0; fileIndex < nwState.LoadedFileCount; fileIndex++)
{
    InwOaPartition nwPartition = nwState.LoadedFileFromNdx(fileIndex + 1);
    childProcessing(nwPartition, "");
}

void childProcessing(InwOaNode node, string prefix)
{
    tmpStructure.AppendLine(prefix + node.UserName);
    if (node.IsGroup)
    {
        InwOaGroup inwOaGroup = node as InwOaGroup;
        foreach (InwOaNode childElem in inwOaGroup.Children())
        {
            childProcessing(childElem, "-" + prefix);
        }
    }
}

MessageBox.Show(tmpStructure.ToString());
```

## Работа с геометрий

**Дисклеймер**: автор заранее извиняется на изложение материала далее, так как сам не до конца понимает механику в Navisworks.

Геометрию нельзя получить через какие-либо методы, вместо этого разработчику предлагается создать специальный класс, унаследованный от интерфейса `InwSimplePrimitivesCB`, где реализовать методы, получающие соответственно вырожденную геометрию: точку, линию, 3d-грань.

Ниже приведен минималистичный вид данных интерфейсов из библиотеки типов Integrated. Для того, чтобы создать класс-обработчик геометрии, вам придется подключать её к проекту как зависимость, реализовать обработку через `dynamic`-типизацию со "своим" интерфейсом, одинаковым по сигнатуре с Navisworks, не выйдет (у автора, во всяком случае, не получилось).
```cs
public interface InwSimpleVertex
{
    object coord { get; }
    object tex_coords { get; }
    object normal { get; }
    object color { get; }
}

public interface InwSimplePrimitivesCB
{
    void Triangle(InwSimpleVertex v1, InwSimpleVertex v2, InwSimpleVertex v3);
    void Line(InwSimpleVertex v1, InwSimpleVertex v2);
    void Point(InwSimpleVertex v1);
    void SnapPoint(InwSimpleVertex v1);
}
```

Реализация чтения с данным классом будет выглядеть так (сделал полный листинг, для консольного приложения):
```cs
using System;
using System.Runtime.InteropServices;
using NavisworksAutomationAPI18;
using NavisworksIntegratedAPI18;

public class PrimitiveChecker : InwSimplePrimitivesCB
{
    public bool HasTriangles { get; private set; }
    public bool HasLines { get; private set; }
    public bool HasPoints { get; private set; }
    public bool HasSnapPoints { get; private set; }

    public void Line(InwSimpleVertex v1, InwSimpleVertex v2) => HasLines = true;

    public void Point(InwSimpleVertex v1) => HasPoints = true;

    public void SnapPoint(InwSimpleVertex v1) => HasSnapPoints = true;

    public void Triangle(InwSimpleVertex v1, InwSimpleVertex v2, InwSimpleVertex v3) =>
      HasTriangles = true;
}

internal class Program
{
    static void Main(string[] args)
    {
        Inavisdoc3? nwDoc = Marshal.GetActiveObject("Navisworks.Document.18") as Inavisdoc3;
        InwOpState11? nwState = nwDoc.State() as InwOpState11;

        for (int fileIndex = 0; fileIndex < nwState.LoadedFileCount; fileIndex++)
        {
            InwOaPartition nwPartition = nwState.LoadedFileFromNdx(fileIndex + 1);
            childProcessing(nwPartition);
        }

        void childProcessing(InwOaNode node)
        {
            if (node.IsGroup)
            {
                InwOaGroup inwOaGroup = node as InwOaGroup;
                foreach (InwOaNode childElem in inwOaGroup.Children())
                {
                    childProcessing(childElem);
                }
            }

            if (node.IsGeometry)
            {
                foreach (InwOaFragment3 geomFragm in node.Fragments())
                {
                    PrimitiveChecker geomChecker = new PrimitiveChecker();
                    geomFragm.GenerateSimplePrimitives(nwEVertexProperty.eNORMAL, geomChecker);

                    if (geomChecker.HasTriangles)
                    {
                        //... some work the geometry
                    }
                }
            }
        }
        Console.WriteLine("\nEnd!");
    }
}
```

Пример класса для обработки геометрии можете посмотреть у Speckle.Navisworks (конкретно, в [этом месте](https://github.com/specklesystems/speckle-sharp-connectors/blob/175145c452d17bbcdd99c8dfe22598e9a4755b7e/Converters/Navisworks/Speckle.Converters.NavisworksShared/ToSpeckle/Raw/GeometryToSpeckleConverter.cs#L85)).

### Примечание про пользовательскую реализацию

Путем экспериментов, если реализовать вот такую конструкцию:

```cs
[ComImport]
[Guid("1F4067D7-48FB-4759-BB8E-3E4A281FC841")]
public interface InwSimplePrimitivesCB
{
    [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
    void Triangle([In][MarshalAs(UnmanagedType.Interface)] InwSimpleVertex v1, [In][MarshalAs(UnmanagedType.Interface)] InwSimpleVertex v2, [In][MarshalAs(UnmanagedType.Interface)] InwSimpleVertex v3);

    [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
    void Line([In][MarshalAs(UnmanagedType.Interface)] InwSimpleVertex v1, [In][MarshalAs(UnmanagedType.Interface)] InwSimpleVertex v2);

    [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
    void Point([In][MarshalAs(UnmanagedType.Interface)] InwSimpleVertex v1);

    [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
    void SnapPoint([In][MarshalAs(UnmanagedType.Interface)] InwSimpleVertex v1);
}

public interface InwSimpleVertex
{
    object coord
    {
        [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
        [return: MarshalAs(UnmanagedType.Struct)]
        get;
    }

    object tex_coord
    {
        [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
        [return: MarshalAs(UnmanagedType.Struct)]
        get;
    }

    object normal
    {
        [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
        [return: MarshalAs(UnmanagedType.Struct)]
        get;
    }

    object color
    {
        [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
        [return: MarshalAs(UnmanagedType.Struct)]
        get;
    }
}
```

И для неё написать класс-обработки геометрии, то подключать к проекту COM-библиотеку типов вроде как нет необходимости, необходимо проверить, одинаков ли идентификатор у InwSimplePrimitivesCB в библиотеках типов для других версий Navisworks.

## Работа со свойствами

У COM-оболочки `InwOaNode`, напомним, это "базовое" представление объекта и данных в Navosiworks, имеется свойство `Attributes`, возвращающее коллекцию атрибутов. Все атрибуты имеют "базовый" интерфейс `InwOaAttribute`. Всего атрибутов в Navisworks 7+1 (7 тех, что могут быть в коллекции атрибутов объекта и 1 (`nwGUIAttribute`), характерный для свойств приложения).

| Имя свойства (ObjectName) | Чем описывается        |
| ------------------------- | ---------------------- |
| nwOaNameAttribute         | InwOaNameAttribute     |
| nwOaMaterial              | InwOaMaterial          |
| nwOaPublishAttribute      | InwOaPublishAttribute  |
| nwOaNat64Attribute        | InwOaNat64Attribute    |
| nwOaTransform             | InwOaTransform         |
| nwOaBinaryAttribute       | InwOaBinaryAttribute   |
| nwOaPropertyAttribute     | InwOaPropertyAttribute |
| nwOaAttribute             | InwOaAttribute         |
Принцип обработки показан ниже. 
```cs
InwNodeAttributesColl attrsColl = node.Attributes();
foreach (InwOaAttribute atrrBase in attrsColl)
{
    string attrType = atrrBase.ObjectName;
    switch (attrType)
    {
        case "nwOaNameAttribute":
            InwOaNameAttribute attrName = atrrBase as InwOaNameAttribute;
            //...
            break;
        case "nwOaMaterial":
            InwOaMaterial attrMaterial = atrrBase as InwOaMaterial;
            //...
            break;
    }
}
```
