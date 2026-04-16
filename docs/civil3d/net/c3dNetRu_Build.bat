mdbook build

REM Копирование в C:\Users\Georg\Documents\GitHub\acadDevDocsRu_Web\c3dNetDeveloperGuideRu
:: перед использованием у себя скопируйте себе локально репозторий acadDevDocsRu_Web или удалить вообще эти действия
:: Удаление папки и создание заново, чтобы перезаписать начисто. Одноименные файлы и стили те же. Просто на всякий случай 
rmdir /s /q "..\..\..\..\acadDevDocsRu_Web\c3dNetDeveloperGuideRu"
mkdir "..\..\..\..\acadDevDocsRu_Web\c3dNetDeveloperGuideRu"

xcopy book "..\..\..\..\acadDevDocsRu_Web\c3dNetDeveloperGuideRu" /Y /I /E

:: Открыть справку в браузере
explorer "book\index.html"