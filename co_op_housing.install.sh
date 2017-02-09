#!/bin/bash
# Usage: sh co_op_housing.install.sh &> log.txt 

PROFILE="co_op_housing"
INSTALL_DIR="/home/jgn/co_op_housing/co_op_housing"
DB_USER="jgn"
DB_PWD="jgn"
DB_DBNAME="co_op_housing"
EMAIL="jgn@dbc.dk"
DISTRO_MAKE="/home/jgn/co_op_housing/distro.make"

echo "\n# Installer Drupal core, Ding2 profil, og moduler:"
drush make --nocolor --working-copy --contrib-destination=profiles/$PROFILE/ $DISTRO_MAKE $INSTALL_DIR

cd $INSTALL_DIR

# $Password for user nnn: => <return>
drush -y si $PROFILE \
--account-name=admin \
--account-pass=content \
--account-mail=$EMAIL \
--db-url=pgsql://$DB_USER:$DB_PWD@localhost/$DB_DBNAME \
--site-mail=$EMAIL \
--site-name=$PROFILE \
--locale=eng \
--nocolor \
  install_configure_form.site_default_country=DK \
  install_configure_form.date_default_timezone=Europe/Copenhagen \
  install_configure_form.update_status_module_1=0

echo "\n# Create symbolic links to modules and libraries"
cd $INSTALL_DIR
chmod 755 sites/default
chmod 777 sites/default/files
chmod 666 sites/default/settings.php

cd $INSTALL_DIR"/sites/default"
ln -s ../../profiles/$PROFILE/modules
ln -s ../../profiles/$PROFILE/libraries

cd $INSTALL_DIR
echo "\n# Download stuff"
drush -y dl --nocolor coder-7.x-2.5
drush -y dl --nocolor devel
drush -y dl --nocolor diff admin_menu

echo "\n# Enable stuff"
drush -y en --nocolor devel simpletest coder coder_review
drush -y en --nocolor rules_admin views_ui diff field_ui simpletest admin_menu
# drush -y en --nocolor bibdk_webservice_settings_develop

echo "\n# Disable stuff"
# drush -y dis --nocolor securepages advagg overlay
# drush -y dis --nocolor varnish expire ding_varnish
# drush -y dis --nocolor ding_webtrends

echo "\n# Set variables"
drush vset --nocolor preprocess_css 0
drush vset --nocolor preprocess_js 0
drush vset --nocolor environment development
drush vset --nocolor devel_rebuild_theme_registry 1

# echo "\n# Setup translation"
# drush --nocolor bibdk-setup-translation

echo "\n# Revert, Clear, Rinse, Repeat"
drush --nocolor features-revert-all -y
drush --nocolor core-cron
drush --nocolor cc all
