# Работа с камерой
Функциональность камеры в Renga описывается COM-оболочкой `Renga.ICamera3D`. Получить её можно только для активного 3D-вида проекта приложения.

Ниже приводится метод расширения на C#, получающий камеру у объекта приложения:
```csharp
public static Renga.ICamera3D? GetCamera(this Renga.IApplication application)
{
	Renga.IView view = application.ActiveView as Renga.IView;
	if (view.Type != Renga.ViewType.ViewType_View3D) return null;
	Renga.IView3DParams? viewModelParams = viewModel as Renga.IView3DParams;
	if (viewModelParams == null) return null;

	return viewModelParams.Camera;
}
```
## Механика работы камеры
Камера отражает текущую точку обзора для активного 3D-вида модели проекта.
Свойство `Position` задает точку обзора, свойство `FocusPoint` - точку на векторе, куда направлен взгляд, свойство `UpVector` - направление вверх, чтобы таким образом однозначно ориентировать правую декартову систему координат в пространстве.
Упомянутые выше свойства редактируемы - они могут быть изменены c помощью метода **LookTo**, и ориентация камеры также будет изменена. 
Readonly-свойства `FovHorizontal`, `FovVertical` характеризуют соответственно горизонтальный и вертикальный сегмент обзора в радианах. Как кажется автору, это актуально для перспективного вида.

Для лучшего понимания механики работы параметров проведем сопоставлением с работой в Renga:
- при любых операциях вращения сцены будут меняться только параметры `Position` и `UpVector`;
- при масштабировании сцены колесиком будет меняться `Position` и `FocusPoint`;
Так как работа с информационной моделью в Renga ведется около нуля координат (более того, он обычно является точкой пересечения начала строительных осей), то можно говорить, что `FocusPoint` в основном будет указывать на точку "0,0,0".

Параметры камеры являются зависимыми друг от друга. Например, переопределяя точку `Position` и `FocusPoint`, параметр UpVector будет меняться, несмотря на заданное ему другое значение.
## Изменение положения камеры
Изменить положение камеры можно с помощью метода `LookAt` COM-оболочки камеры `Renga.ICamera3D`. Метод принимает на вход все 3 определяющих параметра камеры -- точку взгляда, вектор направления и вектор, задающий ось Z.
Покажем ниже несколько вариантов положения камеры для сторон видового куба, с расчетом, что точка обзора будет удалена на фиксированное расстояние от "нуля координат":
```csharp
// Сдвиг координат, мм
double coordsOffsetView = 100000; // 100 м.

private void SetView(double[] position)
{
	// Используется метод расширения из листинга выше
	Renga.ICamera3D? camera = PluginData.rengaApplication.GetCamera();
	if (camera == null) return;
	// Конструктор FloatPoint3D условный, на самом деле его нет
	// Сделано для наглядности. И да, он работает с float
	camera.LookAt(
		new FloatPoint3D(0,0,0), 
		new FloatPoint3D(position[0], position[1], position[2]),
		new FloatPoint3D(0,0,1));
}

private void Button_SetOrientFix_Top_Click()
{
	SetView(new double[] {0,0, coordsOffsetView });
}

private void Button_SetOrientFix_Down_Click()
{
	SetView(new double[] { 0, 0, -coordsOffsetView });
}

private void Button_SetOrientFix_Right_Click()
{
	SetView(new double[] { coordsOffsetView, 0, 0  });
}

private void Button_SetOrientFix_Left_Click()
{
	SetView(new double[] { -coordsOffsetView, 0, 0 });
}
private void Button_SetOrientFix_Front_Click()
{
	SetView(new double[] { 0, coordsOffsetView, 0 });
}

private void Button_SetOrientFix_Back_Click()
{
	SetView(new double[] { 0, -coordsOffsetView, 0 });
}
```
