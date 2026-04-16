# acadDevDocsRu

Справочные руководства по разработке приложений под различные САПР на русском языке

## Принцип описаний

Все справочники расположены в папке `docs`. Справочники для `AutoCAD` -- в подпапке `acad` и далее по видам API.

Справочник представляют собой набор markdown-статей в папке `content` с относительными путями к картинкам в папке `assets`. Файл заглавия (TOC aka Table of content) называется `SUMMARY.md`.

Справочник собирается через приложение с открытым исходным кодом `mdbook` на Rust, для сборки необходимо скачать исполняемый файл `mdbook.exe` и добавить путь к его папке в переменную окружения `Path` в Windows (как в Linux не знаю, но он кроссплатформенный). 

Автору наиболее удобно писать справочник в Obsidian для локальной папки `content`. Файлы проекта Obsidian в репозиторий не отправляютсям- пишите, где кому как удобно.

Конфигурация для сборки справочника хранится в папке справочника с именем `book.toml`.

HTML-результат сборки в `mdBook` складываю сюда https://github.com/GeorgGrebenyuk/acadDevDocsRu_Web

## Перечень справочников

| Имя справочника                                    | Относительный путь  | Содержание                                     | Описание                                                    | PDF | WEB                                                                                  |
| -------------------------------------------------- | ------------------- | ---------------------------------------------- | ----------------------------------------------------------- | --- | ------------------------------------------------------------------------------------ |
| Autodesk                                           |                     |                                                |                                                             |     |                                                                                      |
| Руководство AutoCAD .NET API разработчика          | `\docs\acad\net`    | [Click](./docs/acad/net/content/SUMMARY.md)    | [Click](./docs/acad/net/content/Topic_DeveloperGuide.md)    |     | [Click](https://georggrebenyuk.github.io/acadDevDocsRu_Web/acadNetDeveloperGuideRu/) |
| Руководство разработчика AutoCAD Civil 3D .NET API | `\docs\civil3d\net` | [Click](./docs/civil3d/net/content/SUMMARY.md) | [Click](./docs/civil3d/net/content/Topic_DeveloperGuide.md) |     |                                                                                      |
| **Российское**                                     |                     |                                                |                                                             |     |                                                                                      |
| Руководство разработчика Renga COM API             | `\docs\renga\com`   | [Click](./docs/renga/com/content/SUMMARY.md)   | [Click](./docs/renga/com/content/Topic_RengaDevGuide.md)    |     |                                                                                      |

### 
