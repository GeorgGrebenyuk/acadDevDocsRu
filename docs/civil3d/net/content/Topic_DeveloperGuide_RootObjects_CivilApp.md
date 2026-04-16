# О CivilApplication

Объект `CivilApplication` (из пространства имён `Autodesk.Civil.ApplicationServices`) представляет собой  класс, предоставляющий доступ к статическим свойствам:
- `ActiveDocument` - текущему (активному) документу, описывается классом `CivilDocument`;
- `ActiveProduct` - возвращает перечисление, какая сейчас запущена конфигурация;
- `SurveyProjects` - возвращает объект класса `SurveyProjectCollection`, предоставляющий доступ к подсистеме "Съемка" (топогеодезические инструменты);