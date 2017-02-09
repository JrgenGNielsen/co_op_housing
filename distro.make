;
; Use this file to build a full distribution including Drupal core (with patches) and
; the BuildKit install profile using the following command:
;
;     $ drush make dist.make [directory]
;
; In a development context this command could be used to check out develop
; branches as git repositories:
;
;     $ drush make --working-copy --dbc-modules=develop --no-gitinfofile --contrib-destination=profiles/bibdk dist.make [directory]

api = 2
core = 7.x

projects[drupal][type] = core

; Uncomment to specify drupal version. Otherwise newest version is downloaded
; projects[drupal][version] = 7.43
projects[drupal][patch][] = http://drupal.org/files/1852888-sort-translations-by-context-2.diff
projects[drupal][patch][] = https://raw.github.com/DBCDK/patches/master/file_create_url-no_change_of_relative_url_to_absolute-all_tests.patch
projects[drupal][patch][] = https://raw.github.com/DBCDK/patches/master/drupal_http_build_query_html5_encode_brackets.patch
; projects[drupal][patch][] = https://www.drupal.org/files/issues/1232416-225.patch
projects[drupal][patch][] = https://raw.githubusercontent.com/DBCDK/patches/master/autocomplete_return_when_undefined.patch
; projects[drupal][patch][] = https://raw.githubusercontent.com/DBCDK/patches/master/print_missing_module_on_install.diff

; TODO all patches on drupal core should go here

projects[co_op_housing][type] = profile
projects[co_op_housing][download][type] = git
projects[co_op_housing][download][url] = https://github.com/JrgenGNielsen/co_op_housing.git
projects[co_op_housing][download][branch] = develop
