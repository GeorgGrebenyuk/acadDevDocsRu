Редактировать модель из пространства листа невозможно. Чтобы получить доступ к модели для данного ВЭ Viewport , переключитесь из пространства листа в пространство модели, используя методы SwitchToModelSpace и SwitchToPaperSpace класса Editor. В результате вы сможете работать с моделью, сохраняя при этом видимым лист. В видовых экранах Viewport возможности редактирования и изменения настроек вида практически такие же, как и в объектах ViewportTableRecord. 

Тем не менее, редактируя настройки ВЭ, у вас больше возможностей: например, вы можете замораживать или размораживать слои в некоторых видовых экранах, не затрагивая остальные экраны, включать или выключать отображение геометрии в видовом окне (альтернатива команды ON_OFF_Viewport). 

При работе в объекте видового экрана вы можете находиться либо в пространстве модели, либо в пространстве листа. Определить, работаете ли вы в пространстве модели, можно, проверив текущие значения системных переменных `TILEMODE` и `CVPORT`. Если `TILEMODE` равно 0, а `CVPORT` имеет значение, отличное от 2, вы работаете в пространстве листа; если `TILEMODE` равно 0, а `CVPORT` равно 2, вы работаете в пространстве модели. Если `TILEMODE` равно 1, вы работаете в пространстве модели с видовым экраном по умолчанию в единственном числе. 

**Примечание**: Перед переключением в пространство модели из листа необходимо установить свойство "On = true" хотя бы для одного объекта `Viewport` на листе. Пример ниже содержит код, инвертирующий активное пространство чертежа (пространство модели меняется на область листа и наоборот). 

```cs
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
 
[CommandMethod("ToggleSpace")]
public static void ToggleSpace()
{
  // Get the current document
  Document acDoc = Application.DocumentManager.MdiActiveDocument;
 
  // Get the current values of CVPORT and TILEMODE
  object oCvports = Application.GetSystemVariable("CVPORT");
  object oTilemode = Application.GetSystemVariable("TILEMODE");
 
  // Check to see if the Model layout is active, TILEMODE is 1 when
  // the Model layout is active
  if (System.Convert.ToInt16(oTilemode) == 0)
  {
      // Check to see if Model space is active in a viewport,
      // CVPORT is 2 if Model space is active 
      if (System.Convert.ToInt16(oCvports) == 2)
      {
          acDoc.Editor.SwitchToPaperSpace();
      }
      else
      {
          acDoc.Editor.SwitchToModelSpace();
      }
  }
  else
  {
      // Switch to the previous Paper space layout
      Application.SetSystemVariable("TILEMODE", 0);
  }
}
```