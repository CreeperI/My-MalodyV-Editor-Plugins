# 介绍

此处的插件适用于**全部模式**，你只需要将插件头部声明的模式改掉即可。
这是一个插件头部：
```lua
PluginIcon = 'icon.png'  -- 3类插件⽤的图标⽂件，需要放在lua同⽬录下, 5.0.2起⽀持
PluginName = '插件名称' -- ⽤于显⽰的插件名称
PluginMode = 0 -- 适⽤的游玩模式，参⻅【各类枚举值-Mode】
PluginType = 0 -- 插件类型，参⻅【插件分类】
PluginRequire = '5.0.1' -- 插件需要的客⼾端最低版本
```

只要修改**PluginMode**即可。<br>
以下是各个模式对应的值：
- Key=0
- Catch=3
- Pad=4
- Taiko=5
- Ring=6
- Slide=7
- Live=8
- Cube=9

# Introduction
The plugins here are all available in **ALL MODES**, what needs to do is just change the mode writes in the head of plugin.

This is the head of a plugin:
```lua
PluginIcon = 'icon.png'  -- 3类插件⽤的图标⽂件，需要放在lua同⽬录下, 5.0.2起⽀持
PluginName = '插件名称' -- ⽤于显⽰的插件名称
PluginMode = 0 -- 适⽤的游玩模式，参⻅【各类枚举值-Mode】
PluginType = 0 -- 插件类型，参⻅【插件分类】
PluginRequire = '5.0.1' -- 插件需要的客⼾端最低版本
```
You need to change the value of **PluginMode**<br>
These are value of each modes:
- Key=0
- Catch=3
- Pad=4
- Taiko=5
- Ring=6
- Slide=7
- Live=8
- Cube=9