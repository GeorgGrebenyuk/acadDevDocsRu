# Набор выборки объектов

Набор выборки описывается COM-оболочкой `InwOpSelectionSet`, имеется также `InwOpSelectionSet2`, но она содержит лишь какие-то технические методы.

Набор выборки отличается от самой выборки только тем, что он имеет связанные имя `name`, дату `Date`, информацию об авторе `Author` и поле с комментариями `Comments`, и конечно, ссылку на саму выборку `InwOpSelection`- через свойство `selection`.

**Примечание**: при внешнем обращении к API при попытке получения даты (`Date`) выбрасывает ошибку `System.Runtime.InteropServices.COMException: '<<Navisworks Error - Unspecific>>'`.

Ниже приведен код, получающий перечень сохраненных выборок в модели (в UI видны в окне "Наборы") и выводящий в окно информацию об имени набора и количестве объектов в выборке:

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Windows;

using NavisworksAutomationAPI18;
using NavisworksIntegratedAPI18;

Inavisdoc3? nwDoc = Marshal.GetActiveObject("Navisworks.Document.18") as Inavisdoc3;
InwOpState11? nwState = nwDoc.State() as InwOpState11;

List<string> ssInfo = new List<string>();
InwSelectionSetColl nwSelSets = nwState.SelectionSets();
foreach (InwOpSelectionSet nwSelectionSet in nwSelSets)
{
    InwSelectionPathsColl selectionResultPaths = nwSelectionSet.selection.Paths();

    List<InwOaNode> needNodes = new List<InwOaNode>();
    foreach (InwOaPath nwPath in selectionResultPaths)
    {
        InwPathNodesColl nwNodes = nwPath.Nodes();
        for (int nodeIndex = nwNodes.Count; nodeIndex > 0; nodeIndex--)
        {
            InwOaNode node = nwNodes[nodeIndex];
            if (!node.IsGeometry && node.UserName != "GeometryCollection")
            {
                needNodes.Add(node);
                break;
            }
        }
    }
    ssInfo.Add($"Набор {nwSelectionSet.name} - {needNodes.Count} шт.");
}
MessageBox.Show(string.Join("\n", ssInfo));
```