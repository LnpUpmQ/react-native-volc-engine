package com.volcengine

import com.facebook.react.bridge.ReactApplicationContext

abstract class VolcEngineSpec internal constructor(context: ReactApplicationContext) :
  NativeVolcEngineSpec(context) {
}
