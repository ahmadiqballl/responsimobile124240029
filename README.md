# SpaceNews Explorer

A Flutter application for browsing recent space news from the
[Spaceflight News API](https://api.spaceflightnewsapi.net/v4/articles/).

## Features

- Local account registration, login, and logout.
- A news feed with article images, titles, news sites, and publication dates.
- Filtering by news site and pull-to-refresh.
- Article details with authors, summary, bookmark controls, and a link to open
  the original article in the browser.
- A persistent bookmark list with swipe-to-remove support.

The news feed requests up to 30 articles so that it can offer a range of
publishers in the source filter. An internet connection is required to load
news and open original articles. User accounts are stored locally in SQLite;
bookmarks and the login session are stored with SharedPreferences.

## Run

```sh
flutter pub get
flutter run
```

Run the analyzer and tests with:

```sh
flutter analyze
flutter test
```
