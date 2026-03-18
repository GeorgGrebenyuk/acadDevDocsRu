# Свойства проекта
У каждого проекта имеется так называемая "Информация о проекте". Это модальное диалоговое окно, открывающееся из интерфейса Renga и состоящее из 3 вкладок: Проект, Участок и Здание. Каждая из вкладок, а также каждый из элементов вкладки описывается соответствующей COM-оболочкой и её свойством.

## Информация о проекте
Описывается COM-оболочкой `Renga.IProjectInfo`. Получается через свойство `ProjectInfo` у COM-оболочки проекта `Renga.IProject`.

| Как в Renga          | API         | Примечание |
| -------------------- | ----------- | ---------- |
| Обозначение проекта  | Code        |            |
| Наименование проекта | Name        |            |
| Стадия               | Stage       |            |
| Описание проекта     | Description |            |
## Информация о здании
Описывается COM-оболочкой `Renga.IBuildingInfo`. Получается через свойство BuildingInfo у COM-оболочки проекта `Renga.IProject`.

| Как в Renga         | API         | Примечание |
| ------------------- | ----------- | ---------- |
| Номер здания        | Number      |            |
| Наименование здания | Name        |            |
| Адрес здания        | Stage       | Прим. 1    |
| Описание здания     | Description |            |
Примечание 1: поле адреса составное, описывается COM-оболочкой `Renga.IPostalAddress`. Редактируется напрямую после получения данного адреса через свойство 	`GetAddress`.
Среди свойств здания располагаются параметры трансформации координат при экспорте в IFC. Ими можно пользоваться для выполнения операций импорта-экспорта данных в модель.

Ниже предлагается метод расширения на C#, возвращающий параметры трансформации координат в виде класса `ProjectTransformPararameters`. Также там имеется перегрузку для участка, поскольку согласно справке к Renga он тоже может использоваться для задания сдвига координат.
```cs
using System;
using System.Linq;

public class ProjectTransformPararameters
{
    public double X;
    public double Y;
    public double Z;
    public double AngleRad;

    public ProjectTransformPararameters()
    {
        X = 0;
        Y = 0;
        Z = 0;
        AngleRad = 0;
    }
}

internal static class BuildingSiteInfoExtension
{
    private static ProjectTransformPararameters getTransformPararameters(Renga.IPropertyContainer props)
    {
        ProjectTransformPararameters trparams = new ProjectTransformPararameters();
        if (PluginData.Project == null) return trparams;

        // Резервируем имена целевых свойств
        string propName_IfcLocationX = "IfcLocationX";
        string propName_IfcLocationY = "IfcLocationY";
        string propName_IfcLocationZ = "IfcLocationZ";
        string propName_IfcDirectionPrecession = "IfcDirectionPrecession";

        var propDefs = PluginData.Project.PropertyManager.GetPropertiesDef();
        if (propDefs == null) return trparams;

        // Находим определения свойств в проекте Renga

        var propRes_IfcLocationX = propDefs.Where(p => p.Name == propName_IfcLocationX);
        var propRes_IfcLocationY = propDefs.Where(p => p.Name == propName_IfcLocationY);
        var propRes_IfcLocationZ = propDefs.Where(p => p.Name == propName_IfcLocationZ);
        var propRes_IfcDirectionPrecession = propDefs.Where(p => p.Name == propName_IfcDirectionPrecession);

        // Если хотя бы одного определения нет, завершаем
        if (!propRes_IfcLocationX.Any() || !propRes_IfcLocationY.Any() || !propRes_IfcLocationZ.Any() || !propRes_IfcDirectionPrecession.Any()) return trparams;

        // Идентификаторы свойств
        RengaPropertyDefinition propDef_IfcLocationX = propRes_IfcLocationX.First();
        RengaPropertyDefinition propDef_IfcLocationY = propRes_IfcLocationY.First();
        RengaPropertyDefinition propDef_IfcLocationZ = propRes_IfcLocationZ.First();
        RengaPropertyDefinition propDef_IfcDirectionPrecession = propRes_IfcDirectionPrecession.First();

        Renga.IProperty? propInstance_IfcLocationX = null;
        Renga.IProperty? propInstance_IfcLocationY = null;
        Renga.IProperty? propInstance_IfcLocationZ = null;
        Renga.IProperty? propInstance_IfcDirectionPrecession = null;

        if (props.Contains(propDef_IfcLocationX.Id)) propInstance_IfcLocationX = props.Get(propDef_IfcLocationX.Id);
        if (props.Contains(propDef_IfcLocationY.Id)) propInstance_IfcLocationY = props.Get(propDef_IfcLocationY.Id);
        if (props.Contains(propDef_IfcLocationZ.Id)) propInstance_IfcLocationZ = props.Get(propDef_IfcLocationZ.Id);
        if (props.Contains(propDef_IfcDirectionPrecession.Id)) propInstance_IfcDirectionPrecession = props.Get(propDef_IfcDirectionPrecession.Id);

        if (propInstance_IfcLocationX == null || propInstance_IfcLocationY == null || propInstance_IfcLocationZ == null || propInstance_IfcDirectionPrecession == null) return trparams;

        // поверяем типы свойств
        if (propDef_IfcLocationX.PType != Renga.PropertyType.PropertyType_Length |
            propDef_IfcLocationY.PType != Renga.PropertyType.PropertyType_Length |
            propDef_IfcLocationZ.PType != Renga.PropertyType.PropertyType_Length |
            propDef_IfcDirectionPrecession.PType != Renga.PropertyType.PropertyType_Angle) return trparams;

        trparams.X = propInstance_IfcLocationX.GetLengthValue(Renga.LengthUnit.LengthUnit_Meters);
        trparams.Y = propInstance_IfcLocationY.GetLengthValue(Renga.LengthUnit.LengthUnit_Meters);
        trparams.Z = propInstance_IfcLocationZ.GetLengthValue(Renga.LengthUnit.LengthUnit_Meters);

        var angle = propInstance_IfcDirectionPrecession.GetAngleValue(Renga.AngleUnit.AngleUnit_Degrees);
        if (angle < 0) angle = 360.0 + angle;
        trparams.AngleRad = Math.PI * propInstance_IfcDirectionPrecession.GetAngleValue(Renga.AngleUnit.AngleUnit_Degrees) / 180.0;

        return trparams;

    }
    /// <summary>
    /// Возвращает параметры трансформации координат из свойств здания. Сдвиг XYZ в метрах, угол поворота вокруг оси Z в градусах, наименование СК
    /// </summary>
    /// <param name="buildingInfo"></param>
    /// <returns></returns>
    public static ProjectTransformPararameters GetTransformPararameters(this Renga.IBuildingInfo buildingInfo)
    {
        return getTransformPararameters(buildingInfo.GetProperties());
    }

    /// <summary>
    /// Возвращает параметры трансформации координат из свойств участка. Сдвиг XYZ в метрах, угол поворота вокруг оси Z в градусах, WKT-код СК
    /// </summary>
    /// <param name="buildingInfo"></param>
    /// <returns></returns>
    public static ProjectTransformPararameters GetTransformPararameters(this Renga.ISiteInfo siteInfo)
    {
        return getTransformPararameters(siteInfo.GetProperties());
    }
}
```
## Информация об участке
Описывается COM-оболочкой `Renga.ISiteInfo`. Получается через свойство `SiteInfo` у COM-оболочки проекта `Renga.IProject`.

| Как в Renga          | API         | Примечание            |
| -------------------- | ----------- | --------------------- |
| Номер участка        | Number      |                       |
| Наименование участка | Name        |                       |
| Адрес участка        | Stage       | см. Прим.1 для здания |
| Описание участка     | Description |                       |
