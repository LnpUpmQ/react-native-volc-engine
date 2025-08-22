export declare function init(license: string, version?: string): Promise<void>;
export declare function enableCustomVideoCapture(enable: boolean, channel?: number): Promise<any>;
export declare function enableCustomVideoProcessing(enable: boolean, channel?: number): Promise<any>;
export declare function pauseProcessing(paused: boolean): Promise<void>;
export declare function setComposeNodes(nodes: string[]): Promise<any>;
export declare function updateComposerNodeIntensity(node: string, key: string, intensity: number): Promise<void>;
export declare function setFilter(path: string): Promise<void>;
export declare function updateFilterIntensity(intensity: number): Promise<void>;
declare const _default: {
    init: typeof init;
    enableCustomVideoCapture: typeof enableCustomVideoCapture;
    enableCustomVideoProcessing: typeof enableCustomVideoProcessing;
    pauseProcessing: typeof pauseProcessing;
    setComposeNodes: typeof setComposeNodes;
    updateComposerNodeIntensity: typeof updateComposerNodeIntensity;
    setFilter: typeof setFilter;
    updateFilterIntensity: typeof updateFilterIntensity;
};
export default _default;
//# sourceMappingURL=index.d.ts.map