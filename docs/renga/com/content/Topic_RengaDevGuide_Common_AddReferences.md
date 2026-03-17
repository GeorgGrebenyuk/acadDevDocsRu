# Подключение библиотек

Для разработки загружаемого приложения или для приложения, взаимодействующего с процессом Renga, создаваемого на языках программирования C# или C++ необходимо импортировать в проект библиотеку типов Renga. Это можно сделать несколькими способами:
## C\#
### COMFileReference
В ваш `csproj` файл занесите инструкцию
```xml
<ItemGroup>
    <COMFileReference Include="$(SolutionDir)external\RengaCOMAPI.tlb"></COMFileReference>
</ItemGroup>
```
где `$(SomePath)` - ваш путь к файлу tlb из Renga SDK.
Такой способ подключения не требует, чтобы Renga была установлена на вашем ПК
### ComReference
В ваш `csproj` файл занесите инструкцию
```xml
<ItemGroup>
  <COMReference Include="Renga">
	<WrapperTool>tlbimp</WrapperTool>
	<VersionMinor>0</VersionMinor>
	<VersionMajor>1</VersionMajor>
	<Guid>0ec5d324-8b9f-4d30-84ed-ab711618d1c1</Guid>
	<Lcid>0</Lcid>
	<Isolated>false</Isolated>
	<EmbedInteropTypes>true</EmbedInteropTypes>
  </COMReference>
</ItemGroup>
```
Этот вариант требует, чтобы на ПК была установлена Renga и зарегистрирована в системе её библиотека типов. Кроме того, библиотека типов устанавливается в единственном экземпляре, затирая другую библиотеку (если у вас несколько версий Renga на ПК). 
### Interop.Renga.dll
Подключите к проекту `csproj` библиотеку типов `Interop.Renga.dll`, которая формируется автоматически при сборке приложения в `obj`-папке при подключении библиотеки типов одним из способов выше.
```xml
<ItemGroup>
	<Reference Include="Interop.Renga.dll">
		<HintPath>$(SomePath)Interop.Renga.dll</HintPath>
		<Private>True</Private>
		<EmbedInteropTypes>False</EmbedInteropTypes>
	</Reference>
</ItemGroup>
```
где `$(SomePath)` - путь к этой библиотеке
Такой путь фактически аналогичен первому, где идёт подключение к tlb. Некоторые авторы плагинов, например, Awada или ModPlus использует такой сценарий, в ModPlus и вовсе имеется возможность подключаться к конкретной версии Renga, если их установлено на ПК несколько.
## C++
### import tlb
1. В свойствах `vcxproj` проекта в `AdditionalIncludeDirectories` добавьте путь к папке, содержащей файл `RengaCOMAPI.tlb`.
2. В основном заголовочном файле приложения (если используются precompilated-headers в нем, если нет -- то в каком-то основном) напишите инструкцию 
```cpp
#import <RengaCOMAPI.tlb>
```
**Примечание**: данная конструкция сработает только для языка программирования Visual C++ (версия языка от Microsoft). Обычный C++ "не знает" такой команды, для него см. подключение ниже.
### RengaCOMAPI tlh и tli
При подключении библиотеки типов способом выше в промежуточной папке проекта создаются файлы `RengaCOMAPI.tli`, `RengaCOMAPI.tlh`. 
Подключите их в свой проект. 
Ниже пример подключения для случая Qt в файле `pro`
```pro
HEADERS += \
    rengacomapi.tlh
DISTFILES += \
    rengacomapi.tlh
```
`tlh` файл (объявление функций) в конце сдержит инструкцию импорта `tli`-файла (реализация функций) с абсолютным путем. При размещении его у себя в проекте обязательно отредактируйте этот путь!
## Python и прочие ЯП
Подключать что-либо нет необходимости, вы просто будете использовать динамическую типизацию объектов и методы согласно справке.
О принципе подключения к приложению Renga см. статью [Подключение к приложению Renga](./Topic_RengaDevGuide_Common_ConnectToRenga.md).