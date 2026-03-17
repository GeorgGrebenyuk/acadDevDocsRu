# Создание скриншотов сцены
Текущий вид можно сохранить в виде снимка. Виды, которые можно сохранять:
- 3D-вид модели (с версии 5.5);
- сборка (с какой версии неизвестно);
- чертеж (c версии 8.10);

Доступ к созданию снимка осуществляется через COM-оболочку `Renga.IScreenshotService`, которая получается вызовом метода GetInterfaceByName("IScreenshotService") для COM-оболочки вида IModelView, подробнее см. [статью о нём](./Topic_RengaDevGuide_AppProcessing_View_Visibility.md).

>[!CAUTION]
> Сохранять снимки можно только из-под загруженных плагинов. При попытке сделать получение COM-оболочки IScreenshotService извне, вернется `null`.

Снимок (скриншот) формируется с помощью метода `MakeScreenshot` для заданных настроек IScreenshotSettings (экземпляр настроек создается через метод той же COM-оболочки `CreateSettings`). 
Созданный снимок будет описываться COM-оболочкой `Renga.IImage`, который можно сохранить в файл с помощью метода `SaveToFile` в виде картинки BMP или PNG.

Настройки снимка `IScreenshotSettings` определяют только разрешение снимка по горизонтали и вертикали в пикселях (свойства `Width` и `Height` соответственно).

```cs
Renga.IApplication rengaApp;
// Получаем активный вид
Renga.IView rengaView = rengaApp.ActiveView;
// Приводим вид к интерфейсу Renga
Renga.IModelView? rengaViewModel = rengaView as Renga.IModelView;
if (rengaViewModel == null) return;
// Получаем вспомогательный сервис для создания снимков
Renga.IScreenshotService? screenServics;
screenServics = rengaViewModel.GetInterfaceByName("IScreenshotService")
as Renga.IScreenshotService;
//screenServics = rengaView as Renga.IScreenshotService;
if (screenServics == null) return;
// Создаем настройки для снимка
Renga.IScreenshotSettings settings = screenServics.CreateSettings();
settings.Width = 512;
settings.Height = 512;
//Создаем снимок
Renga.IImage createdScreen = screenServics.MakeScreenshot(settings);
// Сохраняем снимок в файл
createdScreen.SaveToFile("rengaScreen1.png",
Renga.ImageFormat.ImageFormat_PNG);
```



