# 每个插件的功能介绍

#### wipefill_In/wipefill_Out/wipefill_linear/wipefill_3times_bezier:

为旧版maV准备的wipe填充插件，分别用于生成In,Out,Linear,三次贝塞尔曲线型的缓动wipe

关于三次贝塞尔的使用：小tap代表控制点1；大tap表示控制点2；两个wipe代表起终点且控制点不可超过起终点的时间范围

_适用版本:5.0.1+_

#### note_beat_strecher/noteX_strecher

将一个片段以指定倍数进行垂直缩放/水平缩放

_适用版本:6.0.0+_

#### Slide_Connector(beta)

连接两个条子

注：这个版本目前不支持撤回操作

_适用版本:5.0.1+_

#### Slide_Clipper

将一个条子拆分成两个条子

_适用版本:5.0.1+_

#### Add_Slide_Seg/Delete_Slide_Seg

添加/删除一个条子中间的节点

_适用版本:5.0.1+_

#### Bezier Slide

以一个条子的节点为控制点将一个折线条转成贝塞尔曲线条

_适用版本:5.2.6+_

---

# The function of each plugin

#### wipefill_In/wipefill_Out/wipefill_linear/wipefill_3times_bezier
The wipe-filling plugin for old version MalodyV(maV), each used for filling wipes in the type of In, Out, Linear and 3-times Bezier curve

About the usage of 3-times Bezier curve:
Use 2 wipe notes to appoint start position and end position, use wider tap note to appoint control-point 1, another tap note to appoint control-point 2.

_Apply for version 5.0.1+_

#### note_beat_strecher/noteX_strecher
Apply vertical scaling/horizontal scaling to appointed value for selected notes.

_Apply for version 6.0.0+_
#### Slide_Connector(beta)
Connect 2 slide notes.

<strong>CAUTION</strong>: This version of connector doesn't support withdraw operation.

_Apply for version 5.0.1+_
#### Slide_Clipper
Separate a slide note into 2 slide notes.

_Apply for version 5.0.1+_
#### Add_Slide_Seg/Delete_Slide_Seg
Add/Delete a segment to a slide note.

_Apply for version 5.0.1+_
#### Bezier Slide
Apply bezier curve to a slide using the segments of the slide note as control-points.
_Apply for version 5.2.6+_