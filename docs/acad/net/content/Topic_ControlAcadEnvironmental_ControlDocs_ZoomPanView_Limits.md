# Отображение всего чертежа

Границы пространтв или значение лимитов чертежа также могут использоваться для определения зоны на виде 

## Расчет границ текущего пространства

Границы текущего пространства могут быть получены используя свойства у объекта класса Database: 

* Extmin и Extmax возвращают границы пространства модели; 
* Pextmin и Pextmax возвращают границы текущего листа (если текущее пространство = лист); 
  Как только границы определены, можно рассчитать новые значения Ширины и Высоты вида. Новое значение ширины и высоты может быть определено используя код ниже: 

```cs
dWidth = MaxPoint.X : MinPoint.X
dHeight = MaxPoint.Y : MinPoint.Y
```

Координаты центральной точки могут быть определены как: 

```cs
dCenterX = (MaxPoint.X + MinPoint.X) * 0.5
dCenterY = (MaxPoint.Y + MinPoint.Y) * 0.5
```

## Расчет пределов (limits) текущего пространства

Чтобы изменить отображение чертежа на основе пределов (limits) текущего пространства, используются свойства Limmin и Limmax , а также Plimmin и Plimmax объекта Database. После возвращения точек, определяющих границы текущего пространства, вы можете использовать ранее упомянутые формулы для расчета ширины, высоты и координат центральной точки нового вида. Код ниже позволяет установить параметры отображения вида для заданных границ и лимитов. Для случая границ используется только пользовательское значение масштаба, немного большее 1. Для лимитов используются свойства Database для установки минимальной и максимальной точек вида. 

```cs
[CommandMethod("ZoomExtents")]
static public void ZoomExtents()
{
    // Zoom to the extents of the current space
    Zoom(new Point3d(), new Point3d(), new Point3d(), 1.01075);
}
[CommandMethod("ZoomLimits")]
static public void ZoomLimits()
{
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;
    // Zoom to the limits of Model space
    Zoom(new Point3d(acCurDb.Limmin.X, acCurDb.Limmin.Y, 0),
         new Point3d(acCurDb.Limmax.X, acCurDb.Limmax.Y, 0),
         new Point3d(), 1);
}
```
