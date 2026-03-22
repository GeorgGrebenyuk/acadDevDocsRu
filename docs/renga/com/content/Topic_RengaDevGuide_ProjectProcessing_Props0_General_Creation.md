Процесс создания нового определения свойств через API аналогичен процессу через пользовательский интерфейс Renga с той разницей, что через API имеется возможно задать идентификатор свойства, а через UI - нет.

## Шаг 1 - Создать определение свойства
Здесь мы вынуждены прибегнуть к тавтологии. 
Необходимо создать вспомогательный объект, описываемый COM-оболочкой `Renga.IPropertyDescription`, который будет содержать информацию о новом определении свойства -- его имени и типе. Тип описывается стандартным перечислением `Renga.PropertyType` из состава библиотеки типов. Альтернативный сценарий - создать экземпляр структуры `Renga.PropertyDescription` и задать ей поля `Name` и `Type` аналогично аргументам метода `CreatePropertyDescription`.

```csharp
Renga.IPropertyManager manager;
// Вариант 1
Renga.IPropertyDescription propDef = manager.CreatePropertyDescription("DeveloperName", 
	Renga.PropertyType.PropertyType_String);
// Вариант 2
Renga.PropertyDescription propDef2 = new Renga.PropertyDescription(){Name = "DeveloperName", 
	Type = Renga.PropertyType.PropertyType_String};
```

## Шаг 2 - Зарегистрировать свойство
Далее, в зависимости от того, чем представлено определение свойства -- COM-оболочкой `Renga.IPropertyDescription` или структурой `Renga.PropertyDescription` необходимо зарегистрировать определение свойства с указанным идентификатором в проекте Renga. В первом случае -- через метод `RegisterProperty2`, во второй -- через метод `RegisterProperty`. 
Проверить, занят ли данный идентификатор для нового определения свойства перед его добавлением можно через метод `IsPropertyRegistered`. 

```csharp
Renga.IPropertyManager manager;
Guid newPropDefId = Guid.Parse("06f8a29e-c932-4432-961c-8a61e5a9c8b8");
if (manager.IsPropertyRegistered(newPropDefId)) return;
// Вариант 1
manager.RegisterProperty2(newPropDefId, propDef);
// Вариант 2
manager.RegisterProperty(newPropDefId, propDef2);
```
Пока свойство не будет зарегистрировано, оно не появится в проекте. Можно считать данный процесс аналогичным созданию.
Обратная процедура -- `UnregisterProperty` фактически означает удаление свойства из проекта.

## Шаг 3 - Связывание свойства с типами объектов
Далее необходимо добавить определение свойства к одному или нескольким типам объектов. Типы объектов - это `Guid` из класса `Renga.EntityTypes`.
Проверить, назначено ли свойство объекту можно с помощью метода `IsPropertyAssignedToType`.
Связать свойство с объектом можно через метод `AssignPropertyToType`.


## Прочие действия

Можно задать формулу `SetExpression` для расчета значения свойства (формула назначается для заданного типа объекта), перед добавлением свойство должно быть добавлено к типу объекта (шаг 3).
Для определения свойства можно задать флаг, что оно будет выгружаться в CSV через метод `SetCSVExportFlag`.