mdbook build

REM Копирование в C:\Users\Georg\Documents\GitHub\acadDevDocsRu_Web\acadNetDeveloperGuideRu
:: перед использованием у себя скопируйте себе локально репозторий acadDevDocsRu_Web или удалить вообще эти действия
:: Удаление папки и создание заново, чтобы перезаписать начисто. Одноименные файлы и стили те же. Просто на всякий случай 
rmdir /s /q "..\..\..\..\acadDevDocsRu_Web\acadNetDeveloperGuideRu"
mkdir "..\..\..\..\acadDevDocsRu_Web\acadNetDeveloperGuideRu"

xcopy book "..\..\..\..\acadDevDocsRu_Web\acadNetDeveloperGuideRu" /Y /I /E

:: Открыть справку в браузере
explorer "book\index.html"