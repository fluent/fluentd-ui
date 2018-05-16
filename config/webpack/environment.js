const { environment } = require('@rails/webpacker')
const vue =  require('./loaders/vue')
const webpack = require('webpack');

// Get a pre-configured plugin
const manifestPlugin = environment.plugins.get('Manifest')
manifestPlugin.opts.writeToFileEmit = false

// Add an additional plugin of your choosing : ProvidePlugin
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
      $: 'jquery/dist/jquery',
      jQuery: 'jquery/dist/jquery',
      Popper: 'popper.js/dist/popper'
  })
);

environment.loaders.append('vue', vue)
module.exports = environment
