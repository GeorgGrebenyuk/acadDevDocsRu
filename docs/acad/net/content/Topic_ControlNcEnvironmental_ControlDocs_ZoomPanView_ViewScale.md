# Масштабирование вида

Если вам нужно увеличить или уменьшить масштаб изображения в окне чертежа, вы изменяете свойства Ширина и Высота текущего вида. При изменении размера вида убедитесь, что свойства Ширина и Высота изменяются на один и тот же коэффициент. Масштабный коэффициент как правило, рассчитывается для одной из следующих ситуаций: 

* Относительно пределов чертежа (limits); 
* Относительно текущего вида; 
* Относительно единиц длины на листе; 
  Пример ниже показывает, как уменьшить текущий вид на 50%. Процедуре Zoom передаются 4 значения: первые 2 : это экземпляры определения Point3d по умолчанию (не используются), третье значение :: текущие координаты центра вида и четвертое значения :: масштабный коэффициент, используемый при определения размера вида. 

```cs
[CommandMethod("ZoomScale")]
static public void ZoomScale()
{
    // Get the current document
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    // Get the current view
    using (ViewTableRecord acView = acDoc.Editor.GetCurrentView())
    {
        // Get the center of the current view
        Point3d pCenter = new Point3d(acView.CenterPoint.X,
                                      acView.CenterPoint.Y, 0);
        // Set the scale factor to use
        double dScale = 0.5;
        // Scale the view using the center of the current view
        Zoom(new Point3d(), new Point3d(), pCenter, 1 / dScale);
    }
}
```
