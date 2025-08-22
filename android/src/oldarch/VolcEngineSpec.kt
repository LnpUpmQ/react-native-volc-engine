package com.volcengine

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReadableArray

abstract class VolcEngineSpec internal constructor(context: ReactApplicationContext) :
    ReactContextBaseJavaModule(context) {

    abstract fun init(license: String, version: String, promise: Promise)

    abstract fun enableCustomVideoProcessing(enable: Boolean, channel: Double, promise: Promise)

    abstract fun pauseProcessing(paused:Boolean, promise: Promise)

    abstract fun setComposeNodes(nodes: ReadableArray, promise: Promise)

    abstract fun updateComposerNodeIntensity(
        node: String,
        key: String,
        intensity: Double,
        promise: Promise
    )

    abstract fun setFilter(path: String, promise: Promise)

    abstract fun updateFilterIntensity(intensity: Double, promise: Promise)

    abstract fun setSticker(path: String, promise: Promise)
}
