const { GetSession } = require('./session.js');
const fs = require('fs-extra');
const path = require('path');

/// <reference types="cypress" />
// ***********************************************************
// This example plugins/index.js can be used to load plugins
//
// You can change the location of this file or turn off loading
// the plugins file with the 'pluginsFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/plugins-guide
// ***********************************************************

// This function is called when a project is opened or re-opened (e.g. due to
// the project's config changing)
/**
 * @type {Cypress.PluginConfig}
 */

function getConfigurationByFile(file) {
  const pathToConfigFile = path.resolve(
    'cypress/config',
    `${file}.json`);

  return fs.readJson(pathToConfigFile)
}


module.exports = (on, config) => {

  const file = config.env.configFile || 'staging';

  // `on` is used to hook into various events Cypress emits
  // `config` is the resolved Cypress config
  on("before:browser:launch", (browser = {}, launchOptions) => {
    if (browser.name === "chrome") {
      launchOptions.args.push("--disable-dev-shm-usage");
      return launchOptions;
    }
  })
  on('task', {
    getSession({ username, password, url }) {
      return new Promise(async resolve => {
        resolve(await GetSession(username, password, url));
      });
    },
  });

  return getConfigurationByFile(file)
};
