# Создание стилей
Создание новых стилей, как и создание объектов в модели, осуществляется с помощью сходного подхода через `CreateNewEntityArgs` и `Create`. Доступны с версии Renga 8.4.
Стили создаются для одного из фиксированных набора стилей, каждый набор стилей описывается COM-оболочкой `Renga.IEntityCollection`.

У COM-оболочки целевой коллекции стилей, например, стилей вентиляционного оборудования (доступных через свойство `MechanicalEquipmentStyles` у COM-оболочки проекта) вызывается метод `CreateNewEntityArgs`, возвращающий экземпляр настроек для создания стиля (описывается COM-оболочкой `Renga.INewEntityArgs`).
У него обязательно заполняются 2 параметра:
- TypeId (равен идентификатору стиля для заданной группы из перечисления `Renga.StyleTypeIds`, в данном случае для вентиляционного оборудования - `MechanicalEquipmentStyle`);
- CategoryId (равен свойству Id у COM-оболочки категории оборудования из набора категорий для заданной группы стилей, если таковая есть, в данном случае для вентиляционного оборудования это `MechanicalEquipmentCategories`);
Для созданного экземпляра настроек у той же COM-оболочки целевой коллекции стилей вызывается метод `Create`, возвращающий объект стиля, доступный через COM-оболочку `Renga.IEntity`.

Ниже обобщенный пример, показывающий подобный сценарий импорта. Сперва создается определение категории из RST-файла, затем создается стиль на базе созданной категории.
```cs
Renga.IProject project;
Guid categoryType = Renga.EntityTypes.MechanicalEquipmentCategory;
Guid typeId = Renga.EntityTypes.MechanicalEquipmentStyle;
string categoryRstPath;

var operation = project.CreateOperation();

operation.Start();
var category = project.ImportCategory(categoryType, categoryRstPath);
operation.Apply();

operation.Start();
var argsUnits = project.MechanicalEquipmentStyles.CreateNewEntityArgs();
argsUnits.TypeId = typeId;
argsUnits.CategoryId = category.Id;
var style = project.MechanicalEquipmentStyles.Create(argsUnits);
```

Для коллекций стилей, не имеющих категорий, свойство CategoryId соответственно не указывается.

**Примечание:** Автору настоящей справки не понятно, зачем разработчики добавили возможность создания стиля, если ему нельзя назначить геометрию и задать имя 😐. Это относится ко всем стилям, не только к тем, что создаются на основе категорий. Фактически, это мёртворожденная затея без всякого смысла....
