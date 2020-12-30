// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import 'jquery'
import '@fancyapps/fancybox'

require('@rails/ujs').start()
require('turbolinks').start()
require('@rails/activestorage').start()

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
const images = require.context('../images', true)
let themeImages = null;

try {
  themeImages = require.context('../../../theme/assets/images', true)
} catch (err) { }
const imagePath = (name) => (themeImages ? (themeImages(name, true) || images(name, true)) : images(name, true))

const svgs = require.context('../svgs', true)
let themeSvgs = null;
// let variable = null;

try {
  themeSvgs = require.context('../../../theme/assets/svgs', true)
} catch (err) { }
const svgPath = (name) => (themeSvgs ? (themeSvgs(name, true) || svgs(name, true)) : svgs(name, true))

// Append the theme version.


// Tailwind.
import './../styles/application.css'

$.fancybox.defaults.infobar = false
$.fancybox.defaults.toolbar = false
$.fancybox.defaults.hash = false

document.addEventListener("turbolinks:before-cache", function () {
  $('.js-remove-before-navigation').remove()
})

import I18n from 'i18n-js'
global.I18n = I18n


// Main App.
import Covid from '../covid'
window.Covid = Covid
Covid.initialize();
