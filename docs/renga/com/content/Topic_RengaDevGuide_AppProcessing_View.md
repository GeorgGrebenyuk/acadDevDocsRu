# Работа с видом
Свойство `ActiveView` COM-оболочки приложения возвращает активный вид текущего приложения, описываемый COM-оболочкой `Renga.IView`. Свойство последнего `Type` характеризует вид этого вида. 

Варианты`ViewType_ProjectExplorer` или `ViewType_Undefined` описывают вид вне открытого проекта, остальные варианты перечислений ViewType характеризуют какую-то составляющую проекта.

У вида, свойство `Type` которого = `ViewType_View3D`, можно получить другую COM-оболочку, называемую `Renga.IView3DParams`, которая предоставляет доступ к камере (считывание параметров ее положения, установка положения), подробнее см. [вложенную статью](./Topic_RengaDevGuide_AppProcessing_View_Camera.md). Для заданного положения камеры можно [создать снимок](./Topic_RengaDevGuide_AppProcessing_View_Screens.md).

Также для вида, свойство `Type` которого = `ViewType_View3D`, `ViewType_Level`, `ViewType_Assembly` или `ViewType_Drawing`, можно получить COM-оболочку `Renga.IModelView`, предоставляющую доступ к чтению и редактированию параметров видимости объектов, заданию визуального стиля. Подробнее см. статью [Управление видимостью объектов](./Topic_RengaDevGuide_AppProcessing_View_Visibility.md).
