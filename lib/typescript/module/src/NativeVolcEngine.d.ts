import type { TurboModule } from 'react-native';
export interface Spec extends TurboModule {
    init(license: string, version: string): Promise<number>;
    enableCustomVideoCapture(enable: boolean, channel: number): Promise<number>;
    enableCustomVideoProcessing(enable: boolean, channel: number): Promise<number>;
    pauseProcessing(paused: boolean): Promise<void>;
    setComposeNodes(nodes: string[]): Promise<number>;
    updateComposerNodeIntensity(node: string, key: string, intensity: number): Promise<number>;
    setFilter(path: string): Promise<number>;
    updateFilterIntensity(intensity: number): Promise<number>;
}
declare const _default: Spec;
export default _default;
//# sourceMappingURL=NativeVolcEngine.d.ts.map