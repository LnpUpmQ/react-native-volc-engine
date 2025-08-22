package com.volcengine.utils

import android.content.Context

class DataHelper internal constructor(context: Context) {
  companion object {
    class ComposeNodeItem(val path: String, val key: String, var intensity: Float) {}
  }

  private val mComposeNodes: MutableList<String> = listOf<String>().toMutableList()

  private val mComposeNodeItems: MutableList<ComposeNodeItem> =
    listOf<ComposeNodeItem>().toMutableList()
  private var mFilter: String = ""
  private var mFilterIntensity: Float = 0f
  private var mSticker: String = ""

  private fun findNodeItem(path: String, key: String): ComposeNodeItem? {
    return mComposeNodeItems.find(fun(it: ComposeNodeItem): Boolean {
      return it.path == path && it.key == key
    })
  }

  fun getComposeNodes(): Array<String> {
    return mComposeNodes.toTypedArray()
  }

  fun saveComposeNodes(nodes: List<String>): Array<String> {
    mComposeNodes.clear()
    nodes.forEach(fun(node) {
      mComposeNodes.add(node)
    })
    val items = mComposeNodeItems.toTypedArray()
    for (composeNodeItem in items) {
      if (!mComposeNodes.contains(composeNodeItem.path)) {
        mComposeNodeItems.remove(composeNodeItem)
      }
    }
    return mComposeNodes.toTypedArray()
  }

  fun getComposeNodeItem(): Array<ComposeNodeItem> {
    return mComposeNodeItems.toTypedArray()
  }

  fun saveComposeNodeItem(path: String, key: String, intensity: Float): Array<ComposeNodeItem> {
    if (!mComposeNodes.contains(path)) {
      mComposeNodes.add(path)
    }
    val item = findNodeItem(path, key)
    if (item != null) {
      item.intensity = intensity
    } else {
      mComposeNodeItems.add(ComposeNodeItem(path, key, intensity))
    }
    return mComposeNodeItems.toTypedArray()
  }

  fun getFilter(): String {
    return mFilter
  }

  fun saveFilter(path: String): String {
    mFilter = path;
    return mFilter
  }

  fun getFilterIntensity(): Float {
    return mFilterIntensity
  }

  fun saveFilterIntensity(intensity: Float): Float {
    mFilterIntensity = intensity;
    return mFilterIntensity
  }

  fun getSticker(): String {
    return mSticker
  }

  fun saveSticker(path: String): String {
    mSticker = path;
    return mSticker
  }
}
