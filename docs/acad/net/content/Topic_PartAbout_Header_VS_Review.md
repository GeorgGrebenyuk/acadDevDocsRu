В данной статье приведена информация о совместимости отдельных версий Microsoft Visual Studio (MS VS далее) с соответствующими версиями AUtoCAD .NET API. MS VS может взаимодействовать одновременно с .NET API и COM (ActiveX) API. 

| Версия AutoCAD | Release-num | Поддерживаемые версии SDK                              | Версия .NET |
| -------------- | ----------- | ------------------------------------------------------ | ----------- |
| AutoCAD 2027   | ?           | AutoCAD 2027                                           | 10.0(?)     |
| AutoCAD 2026   | 25.1        | AutoCAD 2026, AutoCAD 2025                             | 8.0         |
| AutoCAD 2025   | 25.0        | AutoCAD 2025                                           | 8.0         |
| AutoCAD 2024   | 24.3        | AutoCAD 2024, AutoCAD 2023, AutoCAD 2022, AutoCAD 2021 | 4.8         |
| AutoCAD 2023   | 24.2        | AutoCAD 2023, AutoCAD 2022, AutoCAD 2021               | 4.8         |
| AutoCAD 2022   | 24.1        | AutoCAD 2022, AutoCAD 2021                             | 4.8         |
| AutoCAD 2021   | 24.0        | AutoCAD 2021                                           | 4.8         |
| AutoCAD 2020   | 23.1        | AutoCAD 2020, AutoCAD 2019                             | 4.7         |
| AutoCAD 2019   | 23.0        | AutoCAD 2019                                           | 4.7         |
| AutoCAD 2018   | 22.0        | AutoCAD 2018                                           | 4.6         |
| AutoCAD 2017   | 21.0        | AutoCAD 2017                                           | 4.6         |
| AutoCAD 2016   | 20.1        | AutoCAD 2015, AutoCAD 2016                             | 4.5         |
| AutoCAD 2015   | 20.0        | AutoCAD 2015                                           | 4.5         |
| AutoCAD 2014   | 19.1        | AutoCAD 2013, AutoCAD 2014                             | 4.0         |
| AutoCAD 2013   | 19.0        | AutoCAD 2013                                           | 4.0         |
| AutoCAD 2012   | 18.2        | AutoCAD 2010, AutoCAD 2011, AutoCAD 2012               | 3.51 SP1    |
| AutoCAD 2011   | 18.1        | AutoCAD 2010, AutoCAD 2011                             | 3.51 SP1    |
| AutoCAD 2010   | 18.0        | AutoCAD 2010                                           | 3.51 SP1    |
| AutoCAD 2009   | 17.2        | AutoCAD 2007, AutoCAD 2008, AutoCAD 2009               | 3.0         |
| AutoCAD 2008   | 17.1        | AutoCAD 2007, AutoCAD 2008                             | 2.0         |
| AutoCAD 2007   | 17.0        | AutoCAD 2007                                           | 2.0         |
| AutoCAD 2006   | 16.2        | AutoCAD 2005, AutoCAD 2006                             | 1.1 SP1     |
| AutoCAD 2005   | 16.1        | AutoCAD 2005                                           | 1.1         |

Рекомендуемая версия MS VS для разработки 2022, в связи с тем, что под ней возможно загрузить .NET 8.0, используемый в AutoCAD с 2025й версии. Вместе с тем, возможно при помощи установщика MS VS загрузить целевую версию .NET 8, а разработку вести из-под Visual Studio 2019.

С версии AutoCAD 2027 и средой .NET 10 вести разработку вероятнее всего придется на MS VS 2026.

Для взаимодействия с AutoCAD .NET API необходимо подключить к целевому проекту библиотеки (перечень см. в пункте раннее) из папки установки AutoCADили через NuGet-пакеты от Autodesk. Версии пакетов см. по колонке "Release number".

## Взаимодействие с C++ API

Из-под приложений на .NET API можно получать доступ к объектам, созданным на стороне неуправяемого кода (здесь, на ObjectARX); так как некоторые объекты AutoCAD не имеют управляемых оберток. Создать управляемый объект из неуправляемого объекта с помощью метода <b>DisposableWrapper.Create()</b>. Указатель на базовый неуправляемый объект из управляемого объекта можно получить с помощью свойства <b>UnmanagedObject</b>. 

## Взаимодействие с COM

Библиотеки COM (ActiveX) API в AutoCAD представлены Autodesk.AutoCAD.Interop.dll, Autodesk.AutoCAD.Interop.Common.dll

Существует 3 способа получения COM-интерфейса со стороны .NET API: 

* Сущность "Приложение AutoCAD"; 
* Сущность "Документ AutoCAD" и "База данных документа AutoCAD"; 
* Сущность "Объект AutoCAD"; 

На листинге ниже приведены основные приведения, доступные в .NET API для перехода к COM-интерфейсам

```cs
var acApp = Autodesk.AutoCAD.ApplicationServices.Application.AcadApplication as AutoCAD.AcadApplication;
Autodesk.AutoCAD.ApplicationServices.Document doc;
var acDoc = doc.GetAcadDocument() as AutoCAD.AcadDocument;
var acDb = doc.Database.AcadDatabase as AutoCAD.AcadDatabase;
Autodesk.AutoCAD.DatabaseServices.Entity ent;
var acEntity = ent.AcadObject as AutoCAD.AcadEntity;
```