# Rails I18n

Helpers to work with I18n in Rails projects.

This package works better with the "everything" package.

![Finding key with Everything](https://raw.githubusercontent.com/mauricioszabo/atom-rails-i18n/master/docs/preview.gif)


This package tries to find every .yml file that resembles an I18n yaml (like pt-BR.yml, or en.yml) and maps their key-values, so we can try to find they with Everything or running one of the codes: rails-i18n:find-keys or rails-i18n:find-translation

## Future

* Try to autocomplete translations, finding each scope of current file or class
* Automatically create new translations, putting then on the correct file (or creating a new one if it still doesn't exists yet)
