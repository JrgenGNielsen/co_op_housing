<?php

/**
 * @file
 * Installation profile for the Co-op Housing distribution.
 */

// Include only when in install mode. MAINTENANCE_MODE is defined in
// install.php and in drush_core_site_install().
if (drupal_installation_attempted()) {
  include_once('co_op_housing.install.inc');
}

/**
 * Implements hook_modules_installed().
 *
 * Unset distracting messages at install time.
 */
/*
function co_op_housing_modules_enabled($modules) {
  if (drupal_installation_attempted() && array_intersect($modules, array('captcha', 'date_api', 'metatag', 'superfish'))) {
    drupal_get_messages('status');
    drupal_get_messages('warning');
  }
}
*/

/**
 * Implements hook_modules_installed().
 *
 * Add custom taxonomy terms to the event_type vocabulary if it is created.
 */
/*
function co_op_housing_entity_insert($entity, $type) {
  if ($type == 'taxonomy_vocabulary') {
    switch ($entity->machine_name) {
      // Add custom contact and organization types for the vocabularies created
      // by debut_redhen.
      case 'contact_type':
        $names = array('Staff', 'Volunteer', 'Media', 'Funder');
        break;
      case 'org_type':
        $names = array('Nonprofit', 'Foundation', 'Government', 'Business');
        break;
      // Add custom event types for the vocabulary created by debut_event.
      case 'event_type':
        $names = array('Conference', 'Meeting', 'Workshop');
        break;
      default:
        $names = array();
    }
    foreach ($names as $name) {
      $term = new StdClass();
      $term->name = $name;
      $term->vid = $entity->vid;
      $term->vocabulary_machine_name = $entity->machine_name;
      taxonomy_term_save($term);
    }
  }
}
*/

/**
 * Implements hook_admin_menu_output_build().
 *
 * Add links to the admin_menu shortcuts menu.
 */
function co_op_housing_admin_menu_output_build(&$content) {
  $content['shortcuts']['shortcuts']['admin-structure-taxonomy'] = array(
    '#title' => t('Add terms'),
    '#href' => 'admin/structure/taxonomy',
    '#access' => user_access('administer taxonomy'),
  );
  $content['shortcuts']['shortcuts']['user'] = array(
    '#title' => t('My account'),
    '#href' => 'user',
  );
}

/**
 * Implements hook_form_FORM_ID_alter().
 */
/*
function co_op_housing_form_update_settings_alter(&$form, &$form_state) {
  $form['co_op_housing_update_show_distro_projects'] = array(
    '#type' => 'checkbox',
    '#title' => t('Show non-security updates for modules and themes included in the distribution'),
    '#default_value' => variable_get('co_op_housing_update_show_distro_projects', FALSE),
  );
}
*/

/**
 * Implements hook_update_projects_alter().
 *
 * Cribbed from commerce_kickstart.
 */
/*
function co_op_housing_update_projects_alter(&$projects) {
  if (!variable_get('co_op_housing_update_show_distro_projects', FALSE)) {
    // Enable update status for the Open Outreach profile.
    $modules = system_rebuild_module_data();
    if (isset($modules['co_op_housing'])) {
      // The module object is shared in the request, so we need to clone it here.
      $co_op_housing = clone $modules['co_op_housing'];
      $co_op_housing->info['hidden'] = FALSE;
      _update_process_info_list($projects, array('co_op_housing' => $co_op_housing), 'module', TRUE);
    }
  }
}
*/

/**
 * Implements hook_update_status_alter().
 *
 * Disable reporting of projects that are in the distribution, but only
 * if they have not been updated manually.
 *
 * Projects with insecure / revoked / unsupported releases are only shown
 * after two days, which gives enough time to prepare a new Open Outreach
 * release which users can install and solve the problem.
 *
 * Cribbed from commerce_kickstart.
 */
/*
function co_op_housing_update_status_alter(&$projects) {
  if (!variable_get('co_op_housing_update_show_distro_projects', FALSE)) {
    $bad_statuses = array(
      UPDATE_NOT_SECURE,
      UPDATE_REVOKED,
      UPDATE_NOT_SUPPORTED,
    );

    $make_filepath = drupal_get_path('module', 'co_op_housing') . '/drupal-org.make';
    if (!file_exists($make_filepath)) {
      return;
    }

    $make_info = drupal_parse_info_file($make_filepath);
    foreach ($projects as $project_name => $project_info) {
      // Never unset the drupal project to avoid hitting an error with
      // _update_requirement_check(). See http://drupal.org/node/1875386.
      if ($project_name == 'drupal') {
        continue;
      }
      // Hide Open Outreach features. They have no update status of their own.
      if (strpos($project_name, 'co_op_housing_') !== FALSE) {
        unset($projects[$project_name]);
      }
      // Hide bad releases (insecure, revoked, unsupported) if they are younger
      // than two days (giving Open Outreach time to prepare an update).
      elseif (isset($project_info['status']) && in_array($project_info['status'], $bad_statuses)) {
        $two_days_ago = strtotime('2 days ago');
        if ($project_info['releases'][$project_info['recommended']]['date'] < $two_days_ago) {
          unset($projects[$project_name]);
        }
      }
      // Hide projects shipped with Open Outreach if they haven't been manually
      // updated.
      elseif (isset($make_info['projects'][$project_name]['version'])) {
        $version = $make_info['projects'][$project_name]['version'];
        if (strpos($version, 'dev') !== FALSE || (DRUPAL_CORE_COMPATIBILITY . '-' . $version == $project_info['info']['version'])) {
          unset($projects[$project_name]);
        }
      }
    }
  }
}
*/
