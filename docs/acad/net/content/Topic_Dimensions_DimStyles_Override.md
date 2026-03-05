Каждый из размеров, созданный на базе данного размерного стиля, может переопределить некоторые настройки стиля: 

* Dimatfit : тип размещения стрелок размерных линий и текста размера, когда на размерной линии не хватает места; 
* Dimaltrnd : округление альтернативных единиц в размерах; 
* Dimasz : Размер стрелок в размерных линиях и выносках; 
* Dimaunit : формата единиц измерения в угловых размерах; 
* Dimblk1, Dimblk2 : Указывает блоки, используемые для концов стрелок размерной линии; 
* Dimcen : настройка меток и линий центра дуг и окружностей при нанесении на них размера; 
* Dimclrd : цвет размерных линий, стрелок и размерных линий:выносок (радиус, диаметр); 
* Dimclre : цвет выносных линий, маркеров центра и центровых/осевых линий; 
* Dimclrt : цвет текста, относящегося к размерам и допускам; 
* Dimdec : количество знаков после запятой в цифрах линейных размеров; 
* Dimdsep : настройку разделителя в десятичных дробях измерений; 
* Dimexe : величина удлинения выносных линий за размерные линии; 
* Dimexo : величину отступа выносных линий от объекта; 
* Dimfrac : формат дроби, когда для линейных размеров выбран формат "Дюймовые дробные" или "Дробные"; 
* Dimltex1, Dimltex2 : задает тип линии для выносных линий размера; 
* Dimlwd : вес размерных линий; 
* Dimlwe : вес выносных линий; 
* Dimjust : выравнивание по горизонтали размерного текста; 
* Dimrnd : настройка округления измерений в размерах; 
* Dimsd1 (Dimsd2) : контроль подавления первой (второй) размерной линии и окончания левой (правой) стрелки; 
* Dimse1 (Dimse2): контроля подавления первой (второй) выносной линии; 
* Dimtad : выравнивание по вертикали размерного текста; 
* Dimtdec : настройки количества десятичных знаков в значениях допуска основных единиц измерения; 
* Dimtfac : настройку высоты текста допуска и дробей; 
* Dimlunit : формат единиц измерения в неугловых размерах; 
* Dimtih : ориентация размерного текста для всех типов размеров, кроме ординатных, если текст вписывается внутри выносных линий; 
* Dimtm : минимальне (нижнее) значение предела допуска; 
* Dimtmove : настройка перемещения текста с позиции по умолчанию; 
* Dimtofl : настройка отрисовки размерных линий между выносными, когда размерный текст находится за пределами выносных линий; 
* Dimtoh : положение текста размеров за пределами выносных линий для всех типов размеров, кроме ординатных;
* Dimtol : признак отображения текста допуска в измерениях; 
* Dimtolj : выравнивание текста допуска по вертикали по отношению к тексту размера; 
* Dimtp : максимальное (верхнее) значение предела допуска; 
* Dimtxt : высота (величина) размерного текста; 
* Dimzin : настройки подавления нулей в значениях допуска линейных размеров; 
* Prefix : префикс (приставка) к значениям размеров; 
* Suffix : суффикс к значениям размеров; 

Свойства ниже характерны только для объектов размеров, не размерных стилей:

* TextPrecision : точность отображения текстового значения для угловых размеров;

* TextPosition : точка расположения текста размера; 

* TextRotation : поворот текста размера в радианах; 

**Примечание**: имевшиеся в nanoCAD .NET API свойства Dimtoh, TextPrecision не реализованы; 

## Добавление суффикса для линейного размера

В примере ниже редактируется формат отображения линейных размеров, добавляется суффикс, равный значению, которое пользователь введёт из строки (обработка с помощью Editor.GetString) 

```cs
using Teigha.Runtime;
using HostMgd.ApplicationServices;
using Teigha.DatabaseServices;
using Teigha.Geometry;
using HostMgd.EditorInput;
[CommandMethod("AddDimensionTextSuffix")]
public static void AddDimensionTextSuffix()
{
    // Get the current database
    Document acDoc = Application.DocumentManager.MdiActiveDocument;
    Database acCurDb = acDoc.Database;
    // Start a transaction
    using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
    {
        // Open the Block table for read
        BlockTable acBlkTbl;
        acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                        OpenMode.ForRead) as BlockTable;
        // Open the Block table record Model space for write
        BlockTableRecord acBlkTblRec;
        acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                        OpenMode.ForWrite) as BlockTableRecord;
        // Create the aligned dimension
        using (AlignedDimension acAliDim = new AlignedDimension())
        {
            acAliDim.XLine1Point = new Point3d(0, 5, 0);
            acAliDim.XLine2Point = new Point3d(5, 5, 0);
            acAliDim.DimLinePoint = new Point3d(5, 7, 0);
            acAliDim.DimensionStyle = acCurDb.Dimstyle;
            // Add the new object to Model space and the transaction
            acBlkTblRec.AppendEntity(acAliDim);
            acTrans.AddNewlyCreatedDBObject(acAliDim, true);
            // Append a suffix to the dimension text
            PromptStringOptions pStrOpts = new PromptStringOptions("");
            pStrOpts.Message = "\\nEnter a new text suffix for the dimension: ";
            pStrOpts.AllowSpaces = true;
            PromptResult pStrRes = acDoc.Editor.GetString(pStrOpts);
            if (pStrRes.Status == PromptStatus.OK)
            {
                acAliDim.Suffix = pStrRes.StringResult;
            }
        }
        // Commit the changes and dispose of the transaction
        acTrans.Commit();
    }
}
```