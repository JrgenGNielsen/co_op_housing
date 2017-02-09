<?php

/**
 * @file
 * Provides functionality to be used at install time.
 */

/**
 * Generate install tasks.
 */
function co_op_housing_install_tasks($install_state) {
  $tasks = array();

  // Add Subprofiles tasks.
  // require_once(drupal_get_path('module', 'subprofiles') . '/subprofiles.install.inc');
  // $tasks = $tasks + _subprofiles_install_tasks($install_state);

  // // Set up the site registration task.
  // $tasks['co_op_housing_register_form'] = array(
  //   'display_name' => st('Register your site'),
  //   'type' => 'form',
  // );

  // // Set up the theme selection task.
  // $tasks['co_op_housing_theme_form'] = array(
  //   'display_name' => st('Choose a theme'),
  //   'type' => 'form',
  // );

  // Set up the wrapup task: Set permissions.
  $tasks['co_op_housing_wrapup'] = array(
    'display_name' => st('Final details'),
  );

  return $tasks;
}

/**
 * Implements hook_install_configure_form_alter().
 */
function co_op_housing_form_install_configure_form_alter(&$form, &$form_state) {
  global $install_state;

  $form['site_elements'] = array(
    '#type' => 'fieldset',
    '#title' => t('Site elements'),
    '#weight' => -20,
  );
  $form['site_elements']['migrate'] = array(
    '#type' => 'checkbox',
    '#title' => t('Install sample content'),
    '#default_value' => TRUE,
    '#description' => t('Select this box to get some initial content created on your site. Without sample content, the site may look empty before you start adding to it. Sample content also provides cues as to how to use and structure your site. You can later modify or delete the sample content.'),
  );
  $form['site_elements']['contact'] = array(
    '#type' => 'checkbox',
    '#title' => t('Enable a contact form and accompanying menu item'),
    '#default_value' => TRUE,
  );

  // Set some reasonable defaults for site configuration form.
  if (isset($install_state['profile_info']['distribution_name'])) {
    $form['site_information']['site_name']['#default_value'] = $install_state['profile_info']['distribution_name'];
  }
  $form['admin_account']['account']['name']['#default_value'] = 'admin';
  // Don't set the email address to "admin@localhost" as that will fail D7's
  // email address validation.
  if ($_SERVER['HTTP_HOST'] != 'localhost') {
    $form['site_information']['site_mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];
    $form['admin_account']['account']['mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];
  }
  // Hide update notifications.
  $form['update_notifications']['#access'] = FALSE;
  $form['#submit'][] = 'co_op_housing_install_configure_form_submit';
}

/**
 * Submit handler for install_configure_form. Conditionally enable sample
 * content module.
 */
function co_op_housing_install_configure_form_submit($form, &$form_state) {

  // Set a flag that we'll later test to enable the migration module.
  if (!empty($form_state['values']['migrate'])) {
    variable_set('co_op_housing_migrate', TRUE);
  }
  if (!empty($form_state['values']['contact'])) {
    // We don't want contact without captcha.
    module_enable(array('contact', 'captcha'));
  }
}

/**
 * Pseudo implementation of hook_user_default_permissions().
 *
 * @see co_op_housing_install_permissions().
 */
function co_op_housing_install_user_default_permissions() {
  $permissions = array();

  // Exported permission: access contextual links
  $permissions['access contextual links'] = array(
    'name' => 'access contextual links',
    'roles' => array(
      0 => 'administrator',
      1 => 'editor',
    ),
    'module' => 'contextual',
  );

  // Exported permission: search content
  $permissions['search content'] = array(
    'name' => 'search content',
    'roles' => array(
      0 => 'administrator',
      1 => 'anonymous user',
      2 => 'authenticated user',
    ),
    'module' => 'search',
  );

  // Exported permission: use advanced search
  $permissions['use advanced search'] = array(
    'name' => 'use advanced search',
    'roles' => array(
      0 => 'administrator',
      1 => 'anonymous user',
      2 => 'authenticated user',
    ),
    'module' => 'search',
  );

  // Exported permission: view advanced help index
  $permissions['view advanced help index'] = array(
    'name' => 'view advanced help index',
    'roles' => array(
      0 => 'administrator',
    ),
    'module' => 'advanced_help',
  );

  // Exported permission: view advanced help popup
  $permissions['view advanced help popup'] = array(
    'name' => 'view advanced help popup',
    'roles' => array(
      0 => 'administrator',
    ),
    'module' => 'advanced_help',
  );

  // Exported permission: view advanced help topic
  $permissions['view advanced help topic'] = array(
    'name' => 'view advanced help topic',
    'roles' => array(
      0 => 'administrator',
    ),
    'module' => 'advanced_help',
  );

  return $permissions;
}

/**
 * Install permissions for optional modules.
 *
 * Optional modules - identified by the "recommends" array in
 * co_op_housing.info - cannot have their permissions in features; recommended
 * modules are enabled after features permissions are implemented, and in any
 * case such features would break if the optional module was disabled.
 *
 * Take advantage of existing support in the Features module for processing
 * default user permissions. Use a pseudo module name, 'co_op_housing_install'.
 */
function co_op_housing_install_permissions() {
  features_include();
  module_load_include('inc', 'features', 'features.export');
  user_permission_features_rebuild('co_op_housing_install');

  if (module_exists('contact') && module_exists('captcha')) {
    // Assign permisions to access contact form.
    foreach (array(DRUPAL_ANONYMOUS_RID, DRUPAL_AUTHENTICATED_RID) as $role_id) {
      user_role_grant_permissions($role_id, array('access site-wide contact form'));
    }

    // Set Captcha on the contact form.
    module_load_include('inc', 'captcha');
    captcha_set_form_id_setting('contact_site_form', 'default');

    // Conditionally create a Contact link in the main menu.
    // Do so here rather than immediately after enabling the contact module to
    // ensure the menu item is valid.
    // Create a Contact link in the main menu.
    $item = array(
      'link_title' => st('Contact'),
      'link_path' => 'contact',
      'menu_name' => 'main-menu',
      'options' => array(
        'attributes' => array(
          'title' => st('Send us an email.'),
        ),
      ),
      'weight' => '20',
    );
    menu_link_save($item);

    // Update the menu router information.
    menu_rebuild();
  }
}




/**
 * Complete the install.
 */
function co_op_housing_wrapup(&$install_state) {
  // if (variable_get('co_op_housing_migrate', FALSE)) {
  //   module_enable(array('co_op_housing_migrate'));
  //   variable_del('co_op_housing_migrate');
  // }

  // Set error messages to an appropriate setting for production sites.
  // Don't do this in Features as sites may wish to turn on error reporting.
  // Set here as features rebuilding may trigger distracting error messages.
  variable_set('error_level', 0);

  co_op_housing_install_permissions();

}

/**
 * Implements hook_mail().
 */
/*
 function co_op_housing_mail($key, &$message, $params) {
  switch($key) {
    case 'register':
      $variables = array();
      // We do not sanitize the token replacement, since the output of this
      // replacement is intended for an e-mail message, not a web browser.
      $message['subject'] = 'Open Outreach registration from ' . variable_get('site_name');
      $body = '';
      if (!empty($params['newsletter'])) {
        $body .= "Newsletter signup: yes\n\nEmail: {$params['newsletter_mail']}\n\n";
      }
      if (!empty($params['newsletter'])) {
        $body .= "Register signup: yes\n\nEmail: {$params['register_mail']}\n\nURL: {$params['register_url']}\n\nOrganization/site name: {$params['register_site_name']}\n\n";
      }
      $message['body'][] = $body;
      break;
  }
}
*/
