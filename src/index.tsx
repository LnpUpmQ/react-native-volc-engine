import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-volc-engine' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;

const VolcEngineModule = isTurboModuleEnabled
  ? require('./NativeVolcEngine').default
  : NativeModules.VolcEngine;

const VolcEngine = VolcEngineModule
  ? VolcEngineModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export async function init(
  license: string,
  version: string = '0.1.0'
): Promise<void> {
  return await VolcEngine.init(license, version);
}

export async function enableCustomVideoCapture(
  enable: boolean,
  channel: number = 0
) {
  if (Platform.OS === 'ios') {
    return await VolcEngine.enableCustomVideoCapture(enable, channel);
  } else {
    return -1;
  }
}

export async function enableCustomVideoProcessing(
  enable: boolean,
  channel: number = 0
) {
  return await VolcEngine.enableCustomVideoProcessing(enable, channel);
}

export async function pauseProcessing(paused: boolean) {
  await VolcEngine.pauseProcessing(paused);
}

export async function setComposeNodes(nodes: string[]) {
  if (Array.isArray(nodes)) {
    return await VolcEngine.setComposeNodes(nodes);
  }
}

export async function updateComposerNodeIntensity(
  node: string,
  key: string,
  intensity: number
) {
  if (node && key) {
    await VolcEngine.updateComposerNodeIntensity(node, key, intensity || 0);
  }
}

export async function setFilter(path: string) {
  await VolcEngine.setFilter(path || '');
}

export async function updateFilterIntensity(intensity: number) {
  await VolcEngine.updateFilterIntensity(intensity || 0);
}

export async function setSticker(path: string) {
  await VolcEngine.setSticker(path || '');
}

export default {
  init,
  enableCustomVideoCapture,
  enableCustomVideoProcessing,
  pauseProcessing,
  setComposeNodes,
  updateComposerNodeIntensity,
  setFilter,
  updateFilterIntensity,
  setSticker,
};
