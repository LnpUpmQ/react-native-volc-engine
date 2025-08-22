"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
exports.enableCustomVideoCapture = enableCustomVideoCapture;
exports.enableCustomVideoProcessing = enableCustomVideoProcessing;
exports.init = init;
exports.pauseProcessing = pauseProcessing;
exports.setComposeNodes = setComposeNodes;
exports.setFilter = setFilter;
exports.updateComposerNodeIntensity = updateComposerNodeIntensity;
exports.updateFilterIntensity = updateFilterIntensity;
var _reactNative = require("react-native");
const LINKING_ERROR = `The package 'react-native-volc-engine' doesn't seem to be linked. Make sure: \n\n` + _reactNative.Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo Go\n';

// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;
const VolcEngineModule = isTurboModuleEnabled ? require('./NativeVolcEngine').default : _reactNative.NativeModules.VolcEngine;
const VolcEngine = VolcEngineModule ? VolcEngineModule : new Proxy({}, {
  get() {
    throw new Error(LINKING_ERROR);
  }
});
async function init(license, version = '0.1.0') {
  return await VolcEngine.init(license, version);
}
async function enableCustomVideoCapture(enable, channel = 0) {
  if (_reactNative.Platform.OS === 'ios') {
    return await VolcEngine.enableCustomVideoCapture(enable, channel);
  } else {
    return -1;
  }
}
async function enableCustomVideoProcessing(enable, channel = 0) {
  return await VolcEngine.enableCustomVideoProcessing(enable, channel);
}
async function pauseProcessing(paused) {
  await VolcEngine.pauseProcessing(paused);
}
async function setComposeNodes(nodes) {
  if (Array.isArray(nodes)) {
    return await VolcEngine.setComposeNodes(nodes);
  }
}
async function updateComposerNodeIntensity(node, key, intensity) {
  if (node && key) {
    await VolcEngine.updateComposerNodeIntensity(node, key, intensity || 0);
  }
}
async function setFilter(path) {
  await VolcEngine.setFilter(path || '');
}
async function updateFilterIntensity(intensity) {
  await VolcEngine.updateFilterIntensity(intensity || 0);
}
var _default = exports.default = {
  init,
  enableCustomVideoCapture,
  enableCustomVideoProcessing,
  pauseProcessing,
  setComposeNodes,
  updateComposerNodeIntensity,
  setFilter,
  updateFilterIntensity
};
//# sourceMappingURL=index.js.map