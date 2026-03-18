# Событие выбора
Можно подписаться на событие выбора объектов в модели через механизм `Renga.SelectionEventSource`. Подписка на событие осуществляется, как правило, из процедуры плагина Initialize.

```cs
private Renga.IApplication m_application;
private Renga.SelectionEventSource m_selectionEventSource;

public bool Initialize(string pluginFolder)
{
    m_application = new Renga.Application();
    var selection = m_application.Selection;
    m_selectionEventSource = new Renga.SelectionEventSource(selection);
    m_selectionEventSource.ModelSelectionChanged += OnModelSelectionChanged;
    return true;
}
private void OnModelSelectionChanged(object sender, EventArgs args)
{
    var selection = m_application.Selection;
    //Ваши действия ... с selection.GetSelectedObjects()
}
```

