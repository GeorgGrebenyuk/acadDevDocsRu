# Категории
Категории в Renga - это объекты инженерных систем, называемые также "категориями", сгруппированные по видам инженерных систем (перечень ограничен).
На базе категории может быть создан 1 или несколько стилей (см. о них [следующий раздел](./Topic_RengaDevGuide_ProjectProcessing_Styles.md)).

В таблице ниже приведен перечень всех возможных категорий в Renga, информация - каким перечислением `EntityTypes` описывается категория группы, через какое свойство COM-оболочки проекта `Renga.IProject` данная категория доступна:

| Название группы в Renga             | EntityType                        | Свойство в IProject                 |
| ----------------------------------- | --------------------------------- | ----------------------------------- |
| Санитарно-техническое оборудование  | PlumbingFixtureCategory           | PlumbingFixtureCategories           |
| Оборудование                        | EquipmentCategory                 | EquipmentCategories                 |
| Деталь трубопровода                 | PipeFittingCategory               | PipeFittingCategories               |
| Аксессуар трубопровода              | PipeAccessoryCategory             | PipeAccessoryCategories             |
| Вентиляционное оборудование         | MechanicalEquipmentCategory       | MechanicalEquipmentCategories       |
| Деталь воздуховода                  | DuctFittingCategory               | DuctFittingCategories               |
| Аксессуар воздуховода               | DuctAccessoryCategory             | DuctAccessoryCategories             |
| Электроустановочное изделие         | WiringAccessoryCategory           | WiringAccessoryCategories           |
| Осветительный прибор                | LightingFixtureCategory           | LightingFixtureCategories           |
| Электрический распределительный щит | ElectricDistributionBoardCategory | ElectricDistributionBoardCategories |
## Создание категорий

С помощью API начиная с версии Renga 8.3 возможен импорт в проект новой категории из RST-файла (создаваемого с помощью STDL). За это отвечает метод `ImportCategory` у COM-оболочки проекта `Renga.IProject`. Метод принимает на вход идентификатор импортируемой категории объектов (см. таблицу выше) и абсолютный путь к RST-файлу, возвращаемый объект описывается стандартной COM-оболочкой `Renga.IEntity`. Далее на основе идентификатора импортированной категории можно создать стиль. Ниже обобщенный пример подобной операции:

>[!ATTENTION]
>Для программного импорта стиля в модель необходимо иметь лицензию на редакцию Professional.

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

