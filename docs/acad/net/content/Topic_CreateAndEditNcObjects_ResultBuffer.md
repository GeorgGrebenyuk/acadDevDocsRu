Тип ResultBuffer — это класс, который отражает структуру `resbuf`, определенную в ObjectARX. Структура `resbuf` предоставляет собой контейнер для данных, специфичных для AutoCAD. 

Объект класса Autodesk.AutoCAD.DatabaseServices.ResultBuffer используется практически так же, как и нативный `resbuf`. Вы определяете ResultBuffer и заполняете его последовательностью пар данных. Каждая пара содержит описание типа данных и значение. В управляемом .NET API эти пары данных являются экземплярами класса `Autodesk.AutoCAD.DatabaseServices.TypedValue`. Этот служебный класс выполняет ту же функцию, что и члены `restype` и `resval` структуры `resbuf`. 

Свойство `TypedValue.TypeCode` представляет собой 16-разрядное целое значение, которое указывает на тип данных свойства `TypedValue.Value`. Допустимые значения TypeCode зависят от конкретного использования экземпляра ResultBuffer. Например, значения TypeCode, подходящие для определения XRecord, не обязательно подходят для xdata. Перечисление `Autodesk.AutoCAD.DatabaseServices.DxfCode` определяет коды, которые описывают весь диапазон возможных типов данных ResultBuffer. 

Свойство `TypedValue.Value` сопоставляется экземпляру System.Object и теоретически может содержать данные любого типа. Однако данные Value должны соответствовать типу, указанному в TypeCode, чтобы гарантировать получение корректного результата. 

Вы можете предварительно заполнить ResultBuffer, передавая массив объектов TypedValue в его конструктор, или создать пустой ResultBuffer и позже вызвать метод `ResultBuffer.Add()`, чтобы добавить новые объекты TypedValue. В следующем примере показано использование конструктора ResultBuffer: 

```cs
using (Xrecord rec = new Xrecord())
{
    rec.Data = new ResultBuffer(
        new TypedValue(Convert.ToInt32(DxfCode.Text), "This is a test"),
        new TypedValue(Convert.ToInt32(DxfCode.Int8), 0),
        new TypedValue(Convert.ToInt32(DxfCode.Int16), 1),
        new TypedValue(Convert.ToInt32(DxfCode.Int32), 2),
        new TypedValue(Convert.ToInt32(DxfCode.HardPointerId), db.BlockTableId),
        new TypedValue(Convert.ToInt32(DxfCode.BinaryChunk), new byte[] {0, 1, 2, 3, 4}),
        new TypedValue(Convert.ToInt32(DxfCode.ArbitraryHandle), db.BlockTableId.Handle),
        new TypedValue(Convert.ToInt32(DxfCode.UcsOrg),
        new Point3d(0, 0, 0)));
}
```