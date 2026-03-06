# Системные переменные для размеров

Существует ряд системных переменных, контролирующих вид размеров: DIMAUNIT, DIMUPT, DIMFIT, DIMTOFL, DIMTIH, DIMTOH, DIMJUST и DIMTAD. Эти переменные можно установить с помощью метода SetSystemVariable, доступного из статического класса Application. 
Например, следующая строка кода устанавливает системную переменную DIMAUNIT (формат единиц для угловых размеров) в радианы (3):

```cs
Autodesk.AutoCAD.ApplicationServices.Application.SetSystemVariable("DIMAUNIT", 3);
```

****Примечание****: переменная DIMFIT в nanoCAD не реализована. 
