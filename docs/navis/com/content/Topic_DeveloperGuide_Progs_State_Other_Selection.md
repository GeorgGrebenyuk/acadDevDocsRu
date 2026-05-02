# Выборка объектов

Выбор каких либо объектов в API описывается с помощью COM-оболочки `InwOpSelection`.

Для перехода от неё к непосредственно выбранным объектом можно воспользоваться следующим методом:

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

InwOpSelection nwCurrentSelection = nwState.CurrentSelection;
InwSelectionPathsColl selectionResultPaths = nwCurrentSelection.Paths();

List<InwOaNode> needNodes = new List<InwOaNode>();
foreach (InwOaPath nwPath in selectionResultPaths)
{
    // Возвращается полное "дерево" выбора от корня (файла) до геометрии.
    // Т.к. свойства объекта привязаны к "родителю" геометрии, то нужно
    // получить последний в цепочке структурный элемент (не геометрию)
    InwPathNodesColl nwNodes = nwPath.Nodes();

    // Поэтому начинаем отсчет с конца
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

MessageBox.Show("Selected next objects: " +
    string.Join("\n", needNodes.Select(n => n.UserName)));
```