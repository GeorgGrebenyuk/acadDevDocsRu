# Настройки модели Civil

Программный доступ к настройкам модели Civil 3D осуществляется через свойство `Settings` у оболочки документа Civil 3D -- `CivilDocument`. Настройки описывается классом `SettingsRoot` из пространства имён `Autodesk.Civil.Settings`.

- `TagSettings` (класс `SettingsTag`) задает значения для счётчиков объектов при их создании - отдельные окна при каждом окне создания объекта в UI;
- `DrawingSettings` (класс `SettingsDrawing`) - параметры чертежа, см. [отдельную статью](Topic_DeveloperGuide_RootObjects_CivilDoc_Settings_DrawingProperties.md);
- `AssociateShortcutProjectId` (строка) - идентификатор данного проекта в механизме Быстрых ссылок на данные;
- `LandXMLSettings` (класс `SettingsLandXML`) - настройки импорта-экспорта LandXML, альтернатива окна, запускаемого командой `EDITLANDXMLSETTINGS`;

Также возможно запросить настройки среды для заданной группы в альтернативу их получения через `DrawingSettings.AmbientSettings` с помощью метода `GetSettings` с передачей ему типа класса, описывающего данную группу параметров среды.

Рассмотрим далее перечень доступных настроек в сравнении с UI.






