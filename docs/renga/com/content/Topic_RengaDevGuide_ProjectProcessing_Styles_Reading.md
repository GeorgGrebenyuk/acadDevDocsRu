# Чтение стилей
Получить информацию о любом стиле в Renga можно с помощью COM-оболочки `Renga.IEntity`. Каких-либо специальных COM-оболочек для какого-либо стиля в настоящем API (для Renga 8.12) не существует.
Процесс перебора COM-оболочки коллекции стилей, представленной `Renga.IEntityCollection` также не представляет каких-либо трудностей. Используйте цикл для количества стилей в коллекции `Count` и метод `GetByIndex`, возвращающий определение стиля, описываемое COM-оболочкой `Renga.IEntity`. Полученный стиль можно привести к COM-оболочке набора свойств или параметров, характерный для стиля данного типа.

В примере ниже у проекте получается коллекция стилей дверей, она перебирается, если приведением стиля к COM-оболочке набора параметров `Renga.IParameterContainer` было успешным, то для каждое приведенного к строке непустое значение запоминается и после перебора всех параметров выводится в диалоговое окно.

```cs
Renga.IApplication rengaApp;
StringBuilder tmpText = new StringBuilder();
// Получаем набор стилей дверей
Renga.IEntityCollection doorStyles = rengaApp.Project.DoorStyles;

for (int styleIndex = 0; styleIndex < doorStyles.Count; styleIndex++)
{
Renga.IEntity doorStyle = doorStyles.GetByIndex(styleIndex);
Renga.IParameterContainer? doorStyleParams = 
doorStyle.GetInterfaceByName("IParameterContainer") as Renga.IParameterContainer;
if (doorStyleParams == null) continue;
tmpText.AppendLine("Door parameters for style " + doorStyle.Name);
Renga.IGuidCollection doorStyleParams_Ids = doorStyleParams.GetIds();
for (int paramIndex = 0; paramIndex < doorStyleParams_Ids.Count; paramIndex++)
{
Renga.IParameter doorParam = doorStyleParams.Get(doorStyleParams_Ids.Get(paramIndex));
bool isNeed = (doorParam.HasValue && !string.IsNullOrEmpty(doorParam.GetStringValue())) ? true :false;
if (!isNeed) continue;
tmpText.AppendLine($"Name: {doorParam.Definition.Name}; Value: {doorParam.GetStringValue()}");
}
}
rengaApp.UI.ShowMessageBox(Renga.MessageIcon.MessageIcon_Info, "Result", tmpText.ToString());
```