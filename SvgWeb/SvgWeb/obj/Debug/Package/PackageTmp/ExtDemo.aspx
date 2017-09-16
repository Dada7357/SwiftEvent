<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ExtDemo.aspx.cs" Inherits="SvgWeb.ExtDemo" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" type="text/css" href="css/workfow.css" /> 

</head>
<body>
    <form id="form1" runat="server">
    <ext:ResourceManager runat="server" />

    <script type="text/javascript" src="mxgraph/src/js/mxClient.js"></script>
    <script src="js/layout.js" type="text/javascript"></script>

    <ext:XScript ID="XScript1" runat="server">
        <script type="text/javascript">
            
            mxBasePath = 'mxgraph/src';

            function onInit(editor, isFirstTime) {
                mxConnectionHandler.prototype.connectImage = new mxImage('images/connector.gif', 16, 16);
                editor.graph.setConnectable(true);
                editor.graph.connectionHandler.setCreateTarget(true);
                editor.addListener(mxEvent.SESSION, function (editor, evt) {
                    var session = evt.getArgAt(0);
                    if (session.connected) {
                        var tstamp = new Date().toLocaleString();
                        editor.setStatus(tstamp + ':' + ' ' + session.sent + ' bytes sent, ' + ' ' + session.received + ' bytes received');
                    }
                    else {
                        editor.setStatus('Not connected');
                    }
                });
                // Changes the zoom on mouseWheel events
                mxEvent.addMouseWheelListener(function (evt, up) {
                    if (!mxEvent.isConsumed(evt)) {
                        if (up) {
                            editor.execute('zoomIn');
                        }
                        else {
                            editor.execute('zoomOut');
                        }

                        mxEvent.consume(evt);
                    }
                });
            }

            Ext.onReady(function () {

                InitMain(document.getElementById('graphContainer'), #{MainPanel},#{MainPanelToolbar},#{LibraryPanel},#{OutlinePanel},#{PropertyPanel},#{pgrid});

                ExtMxGraphReSize();
            });

            var customerZoom = function(el,e)
            {
                var msg = "Enter Source Spacing (像素)";

                var value = Ext.Msg.prompt("自定义",msg,function(btn, text, cfg) {
                    if(btn == 'ok' && !Ext.isEmpty(text)) {
                        if (Ext.isNumber(text)) {
                            var newMsg = Ext.String.format('<span style="color:red">{0}</span>',msg);
                            Ext.Msg.show(Ext.apply({}, { msg: newMsg }, cfg));
                        }
                        else{
                            ExtMxGraph.getView().setScale(parseInt(text)/ 100)
                        }
                    }
              },this, false, parseInt(ExtMxGraph.getView().getScale() * 100));
            }

            var customerGridSize = function(el,e)
            {
                 var msg = "Enter Grid Size (像素)";

                var value = Ext.Msg.prompt("自定义",msg,function(btn, text, cfg) {
                    if(btn == 'ok' && !Ext.isEmpty(text)) {
                        if (Ext.isNumber(text)) {
                            var newMsg = Ext.String.format('<span style="color:red">{0}</span>',msg);
                            Ext.Msg.show(Ext.apply({}, { msg: newMsg }, cfg));
                        }
                        else{
                            ExtMxGraph.gridSize = text;
                            ExtMxGraph.sizeDidChange();
                        }
                    }
              },this, false, ExtMxGraph.gridSize);
            }

            var checkGridEnabled = function(item, checked)
            {
                ExtMxGraph.setGridEnabled(checked)
			    ExtMxGraph.container.style.backgroundImage = (ExtMxGraph.isGridEnabled()) ? 'url(mxgraph/examples/editors/images/grid.gif)': 'none';
            }

            var ExtMxGraphReSize = function(){
                if(ExtMxGraph){
                    ExtMxGraph.container.style.height = #{MainPanel}.getHeight() + 'px';
                    ExtMxGraph.container.style.width = #{MainPanel}.getWidth() + 'px'; 
                    ExtMxGraph.sizeDidChange();
                }
            }

            var MainPanelContextMenuShow = function(item)
            {
                item.showAt([item.x - 5, item.y - 30]);

                var selected = !ExtMxGraph.isSelectionEmpty();
                #{btnContextMenuUndo}.setDisabled(!ExtMxHistory.canUndo());
                #{btnContextMenuCut}.setDisabled(!selected);
                #{btnContextMenuCopy}.setDisabled(!selected);
                #{btnContextMenuPaste}.setDisabled(mxClipboard.isEmpty());
                #{btnContextMenuDelete}.setDisabled(!selected);
                #{btnContextMenuStyle}.setDisabled(!selected);
                #{btnContextMenuBackgroud}.setDisabled(!selected);
                #{btnContextMenuLocal}.setDisabled(!selected);
                #{btnContextMenuHome}.setDisabled(!ExtMxGraph.view.currentRoot);
                #{btnContextMenuExitGroup}.setDisabled(!ExtMxGraph.view.currentRoot);
                #{btnContextMenuEnterGroup}.setDisabled(!selected);
                #{btnContextMenuGroup}.setDisabled(ExtMxGraph.getSelectionCount() <= 1);
                #{btnContextMenuCollapse}.setDisabled(!selected);
                #{btnContextMenuExpand}.setDisabled(!selected);
            }
        </script>
    </ext:XScript>

    <ext:Viewport runat="server" Layout="BorderLayout">
		<Items>
            <ext:Panel runat="server" Region="Center" Layout="BorderLayout" Margins="5 5 5 5" Border="false" Title="mxgraph">
                <Items>
                    <ext:Panel runat="server" Title="图形库" Region="West" Layout="BorderLayout" Split="true" Width="180" Collapsible="true" Border="false">
                        <Items>
                            <ext:TreePanel ID="LibraryPanel" runat="server" Header="false" AutoScroll="true" Region="Center" Layout="FitLayout"
                             Lines="false" Border="false" UseArrows="true" CollapseFirst="false" RootVisible="false" Split="true">
                                <Root>
                                    <ext:Node Text="Graph Editor" Expanded="true" AllowDrag="false" >
                                        <Children>
                                             <ext:Node Text="形状" NodeID="0" Qtip="形状" AllowDrag="false" Cls="feeds-node" />
                                        </Children>
                                    </ext:Node>
                                </Root>
                                <Listeners>
                                    <ItemClick Fn="nodeDragGraph" />
                                </Listeners>
                             </ext:TreePanel>
                            <ext:Panel ID="OutlinePanel" runat="server" Title="预览" Region="South" Layout="FitLayout" Split="true" Border="false" MinHeight="250" />

                        </Items>
                    </ext:Panel>

                    <ext:Menu runat="server" ID="MainPanelContextMenu">
                        <Listeners>
                            <Show Fn="MainPanelContextMenuShow" />
                            <Hide Handler="if (this.ctxNode) {this.ctxNode.ui.removeClass('x-node-ctx');this.ctxNode = null;}" />
                        </Listeners>
                        <Items>
                            <ext:MenuItem runat="server" Text="撤销" IconCls="undo-icon" ID="btnContextMenuUndo" >
                                <Listeners>
                                    <Click Handler="ExtMxHistory.undo();" />
                                </Listeners>
                            </ext:MenuItem>

                            <ext:MenuSeparator runat="server" />

                            <ext:MenuItem runat="server" Text="剪切" IconCls="cut-icon" ID="btnContextMenuCut" >
                                <Listeners>
                                    <Click Handler="mxClipboard.cut(ExtMxGraph);" />
                                </Listeners>
                            </ext:MenuItem>

                            <ext:MenuItem runat="server" Text="复制" IconCls="copy-icon" ID="btnContextMenuCopy" >
                                 <Listeners>
                                    <Click Handler="mxClipboard.copy(ExtMxGraph);" />
                                </Listeners>
                            </ext:MenuItem>

                            <ext:MenuItem runat="server" Text="粘贴" IconCls="paste-icon" ID="btnContextMenuPaste" >
                                 <Listeners>
                                    <Click Handler="mxClipboard.paste(ExtMxGraph);" />
                                </Listeners>
                            </ext:MenuItem>

                            <ext:MenuSeparator runat="server" />

                            <ext:MenuItem runat="server" Text="删除" IconCls="delete-icon" ID="btnContextMenuDelete" >
                                 <Listeners>
                                    <Click Handler="ExtMxGraph.removeCells();" />
                                </Listeners>
                            </ext:MenuItem>

                            <ext:MenuSeparator runat="server" />

                            <ext:MenuItem runat="server" Text="样式" ID="btnContextMenuStyle" >
                                <Menu>
                                    <ext:Menu runat="server">
                                        <Items>
                                            <ext:MenuItem runat="server" Text="背景" ID="btnContextMenuBackgroud" >
                                               <Menu>
                                                    <ext:Menu runat="server">
                                                        <Items>
                                                            <ext:MenuItem runat="server" Text="颜色填充" IconCls="fillcolor-icon" ID="btnContextMenuFillColor" >
                                                                <Menu>
                                                                    <ext:ColorMenu runat="server">
                                                                        <BottomBar>
                                                                            <ext:Toolbar runat="server">
                                                                                <Items>
                                                                                    <ext:Button Width="145" runat="server" Text="无">
                                                                                        <Listeners>
                                                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_FILLCOLOR,mxConstants.NONE)" />
                                                                                        </Listeners>
                                                                                    </ext:Button>
                                                                                </Items>
                                                                            </ext:Toolbar>
                                                                        </BottomBar>
                                                                        <Listeners>
                                                                            <Select Handler="if (typeof(color) == 'string') { ExtMxGraph.setCellStyles(mxConstants.STYLE_FILLCOLOR, '#' + color)}" />
                                                                        </Listeners>
                                                                    </ext:ColorMenu>
                                                                </Menu>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="过渡" ID="btnContextMenuGradientColor" >
                                                                <Menu>
                                                                    <ext:ColorMenu runat="server">
                                                                        <BottomBar>
                                                                            <ext:Toolbar runat="server">
                                                                                <Items>
                                                                                    <ext:Button Width="27" runat="server" Text="上">
                                                                                        <Listeners>
                                                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_GRADIENT_DIRECTION,mxConstants.DIRECTION_NORTH)" />
                                                                                        </Listeners>
                                                                                    </ext:Button>
                                                                                    <ext:Button Width="27" runat="server" Text="下">
                                                                                        <Listeners>
                                                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_GRADIENT_DIRECTION,mxConstants.DIRECTION_SOUTH)" />
                                                                                        </Listeners>
                                                                                    </ext:Button>
                                                                                    <ext:Button Width="27" runat="server" Text="左">
                                                                                        <Listeners>
                                                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_GRADIENT_DIRECTION,mxConstants.DIRECTION_WEST)" />
                                                                                        </Listeners>
                                                                                    </ext:Button>
                                                                                    <ext:Button Width="27" runat="server" Text="右">
                                                                                        <Listeners>
                                                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_GRADIENT_DIRECTION,mxConstants.DIRECTION_EAST)" />
                                                                                        </Listeners>
                                                                                    </ext:Button>
                                                                                    <ext:Button Width="27" runat="server" Text="无">
                                                                                        <Listeners>
                                                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_GRADIENTCOLOR,mxConstants.NONE)" />
                                                                                        </Listeners>
                                                                                    </ext:Button>
                                                                                </Items>
                                                                            </ext:Toolbar>
                                                                        </BottomBar>
                                                                        <Listeners>
                                                                            <Select Handler="if (typeof(color) == 'string') { ExtMxGraph.setCellStyles(mxConstants.STYLE_GRADIENTCOLOR, '#' + color)}" />
                                                                        </Listeners>
                                                                    </ext:ColorMenu>
                                                                </Menu>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="图片" >
                                                                <Listeners>
                                                                    <Click Handler="var value = null;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_IMAGE] || value
                                                                    }
                                                                    Ext.Msg.prompt('图片','请输入图片地址',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_IMAGE,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="阴影" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.toggleCellStyles(mxConstants.STYLE_SHADOW)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="透明" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 100;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_OPACITY] || value
                                                                    }
                                                                    Ext.Msg.prompt('透明','Enter Opacity (0-100%)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_OPACITY,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>
                                                        </Items>
                                                    </ext:Menu>
                                               </Menu>
                                            </ext:MenuItem>

                                            <ext:MenuItem runat="server" Text="标签" >
                                               <Menu>
                                                    <ext:Menu runat="server">
                                                        <Items>
                                                            <ext:MenuItem runat="server" Text="字体颜色" IconCls="fontcolor-icon" ID="btnContextMenuFontColor" >
                                                                <Menu>
                                                                    <ext:ColorMenu runat="server">
                                                                        <BottomBar>
                                                                            <ext:Toolbar runat="server">
                                                                                <Items>
                                                                                    <ext:Button Width="145" runat="server" Text="无">
                                                                                        <Listeners>
                                                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_FONTCOLOR,mxConstants.NONE)" />
                                                                                        </Listeners>
                                                                                    </ext:Button>
                                                                                </Items>
                                                                            </ext:Toolbar>
                                                                        </BottomBar>
                                                                        <Listeners>
                                                                            <Select Handler="if (typeof(color) == 'string') { ExtMxGraph.setCellStyles(mxConstants.STYLE_FONTCOLOR, '#' + color)}" />
                                                                        </Listeners>
                                                                    </ext:ColorMenu>
                                                                </Menu>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="填充颜色" ID="btnContextMenuLabelBackground" >
                                                                <Menu>
                                                                    <ext:ColorMenu runat="server">
                                                                        <BottomBar>
                                                                            <ext:Toolbar runat="server">
                                                                                <Items>
                                                                                    <ext:Button Width="145" runat="server" Text="无">
                                                                                        <Listeners>
                                                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_LABEL_BACKGROUNDCOLOR,mxConstants.NONE)" />
                                                                                        </Listeners>
                                                                                    </ext:Button>
                                                                                </Items>
                                                                            </ext:Toolbar>
                                                                        </BottomBar>
                                                                        <Listeners>
                                                                            <Select Handler="if (typeof(color) == 'string') { ExtMxGraph.setCellStyles(mxConstants.STYLE_LABEL_BACKGROUNDCOLOR, '#' + color)}" />
                                                                        </Listeners>
                                                                    </ext:ColorMenu>
                                                                </Menu>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="边颜色" ID="btnContextMenuLabelBorder" >
                                                                <Menu>
                                                                    <ext:ColorMenu runat="server">
                                                                        <BottomBar>
                                                                            <ext:Toolbar runat="server">
                                                                                <Items>
                                                                                    <ext:Button Width="145" runat="server" Text="无">
                                                                                        <Listeners>
                                                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_LABEL_BORDERCOLOR,mxConstants.NONE)" />
                                                                                        </Listeners>
                                                                                    </ext:Button>
                                                                                </Items>
                                                                            </ext:Toolbar>
                                                                        </BottomBar>
                                                                        <Listeners>
                                                                            <Select Handler="if (typeof(color) == 'string') { ExtMxGraph.setCellStyles(mxConstants.STYLE_LABEL_BORDERCOLOR, '#' + color)}" />
                                                                        </Listeners>
                                                                    </ext:ColorMenu>
                                                                </Menu>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="旋转标签" ID="btnContextMenuHorizontal" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.toggleCellStyles(mxConstants.STYLE_HORIZONTAL,true)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="字体透明度" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 100;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_TEXT_OPACITY] || value
                                                                    }
                                                                    Ext.Msg.prompt('字体透明度','Enter Opacity (0-100%)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_TEXT_OPACITY,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="位置" ID="btnContextMenuLocal" >
                                                                <Menu>
                                                                    <ext:Menu runat="server">
                                                                        <Items>
                                                                            <ext:MenuItem runat="server" Text="顶部">
                                                                                <Listeners>
                                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_VERTICAL_LABEL_POSITION,mxConstants.ALIGN_TOP);ExtMxGraph.setCellStyles(mxConstants.STYLE_VERTICAL_ALIGN,mxConstants.ALIGN_BOTTOM)" />
                                                                                </Listeners>
                                                                            </ext:MenuItem>

                                                                            <ext:MenuItem runat="server" Text="中部">
                                                                                <Listeners>
                                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_VERTICAL_LABEL_POSITION,mxConstants.ALIGN_MIDDLE);ExtMxGraph.setCellStyles(mxConstants.STYLE_VERTICAL_ALIGN,mxConstants.ALIGN_MIDDLE)" />
                                                                                </Listeners>
                                                                            </ext:MenuItem>

                                                                            <ext:MenuItem runat="server" Text="底部">
                                                                                <Listeners>
                                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_VERTICAL_LABEL_POSITION,mxConstants.ALIGN_BOTTOM);ExtMxGraph.setCellStyles(mxConstants.STYLE_VERTICAL_ALIGN,mxConstants.ALIGN_TOP)" />
                                                                                </Listeners>
                                                                            </ext:MenuItem>

                                                                            <ext:MenuSeparator runat="server" />

                                                                            <ext:MenuItem runat="server" Text="居右">
                                                                                <Listeners>
                                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_LABEL_POSITION,mxConstants.ALIGN_LEFT);ExtMxGraph.setCellStyles(mxConstants.STYLE_ALIGN,mxConstants.ALIGN_RIGHT)" />
                                                                                </Listeners>
                                                                            </ext:MenuItem>

                                                                            <ext:MenuItem runat="server" Text="居中">
                                                                                <Listeners>
                                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_LABEL_POSITION,mxConstants.ALIGN_CENTER);ExtMxGraph.setCellStyles(mxConstants.STYLE_ALIGN,mxConstants.ALIGN_CENTER)" />
                                                                                </Listeners>
                                                                            </ext:MenuItem>

                                                                            <ext:MenuItem runat="server" Text="居右">
                                                                                <Listeners>
                                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_LABEL_POSITION,mxConstants.ALIGN_RIGHT);ExtMxGraph.setCellStyles(mxConstants.STYLE_ALIGN,mxConstants.ALIGN_LEFT)" />
                                                                                </Listeners>
                                                                            </ext:MenuItem>
                                                                        </Items>
                                                                    </ext:Menu>
                                                                </Menu>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="隐藏" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.toggleCellStyles(mxConstants.STYLE_NOLABEL,false)" />
                                                                </Listeners>
                                                            </ext:MenuItem>
                                                        </Items>
                                                    </ext:Menu>
                                               </Menu>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="连线" >
                                               <Menu>
                                                    <ext:Menu runat="server">
                                                        <Items>
                                                            <ext:MenuItem runat="server" Text="颜色" IconCls="linecolor-icon" ID="btnContextMenuLineColor" >
                                                                <Menu>
                                                                    <ext:ColorMenu runat="server">
                                                                        <BottomBar>
                                                                            <ext:Toolbar runat="server">
                                                                                <Items>
                                                                                    <ext:Button Width="145" runat="server" Text="无">
                                                                                        <Listeners>
                                                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_STROKECOLOR,mxConstants.NONE)" />
                                                                                        </Listeners>
                                                                                    </ext:Button>
                                                                                </Items>
                                                                            </ext:Toolbar>
                                                                        </BottomBar>
                                                                        <Listeners>
                                                                            <Select Handler="if (typeof(color) == 'string') { ExtMxGraph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#' + color)}" />
                                                                        </Listeners>
                                                                    </ext:ColorMenu>
                                                                </Menu>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="虚线" ID="btnContextMenuDashed" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.toggleCellStyles(mxConstants.STYLE_DASHED)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="宽度" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 0;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_STROKEWIDTH] || value
                                                                    }
                                                                    Ext.Msg.prompt('宽度','请输入宽度 (像素)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_STROKEWIDTH,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>
                                                        </Items>
                                                    </ext:Menu>
                                                </Menu>
                                            </ext:MenuItem>

                                            <ext:MenuItem runat="server" Text="连接器" >
                                                <Menu>
                                                    <ext:Menu runat="server" >
                                                        <Items>
                                                            <ext:MenuItem runat="server" Text="直线" IconUrl="mxgraph/examples/editors/images/straight.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyle('straight')" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="水平线" IconUrl="mxgraph/examples/editors/images/connect.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyle(null)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="垂直线" IconUrl="mxgraph/examples/editors/images/vertical.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyle('vertical')" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="实体关系" IconUrl="mxgraph/examples/editors/images/entity.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyle('edgeStyle=mxEdgeStyle.EntityRelation')" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="箭头" IconUrl="mxgraph/examples/editors/images/arrow.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyle('arrow')" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="面板" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.toggleCellStyles(mxConstants.STYLE_NOEDGESTYLE,false)" />
                                                                </Listeners>
                                                            </ext:MenuItem>
                                                        </Items>
                                                    </ext:Menu>                                                
                                                </Menu>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="开始点" >
                                                <Menu>
                                                    <ext:Menu runat="server">
                                                        <Items>
                                                            <ext:MenuItem runat="server" Text="普通" IconUrl="mxgraph/examples/editors/images/open_start.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_STARTARROW,mxConstants.ARROW_OPEN)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="经典" IconUrl="mxgraph/examples/editors/images/classic_start.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_STARTARROW,mxConstants.ARROW_CLASSIC)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="加粗" IconUrl="mxgraph/examples/editors/images/block_start.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_STARTARROW,mxConstants.ARROW_BLOCK)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="菱形" IconUrl="mxgraph/examples/editors/images/diamond_start.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_STARTARROW,mxConstants.ARROW_DIAMOND)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="圆形" IconUrl="mxgraph/examples/editors/images/oval_start.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_STARTARROW,mxConstants.ARROW_OVAL)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="无" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_STARTARROW,mxConstants.NONE)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="大小" >
                                                                <Listeners>
                                                                    <Click Handler="var value = mxConstants.DEFAULT_MARKERSIZE;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_STARTSIZE] || value
                                                                    }
                                                                    Ext.Msg.prompt('大小','输入大小',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_STARTSIZE,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>
                                                        </Items>
                                                    </ext:Menu>
                                                </Menu>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="结束点" >
                                                <Menu>
                                                    <ext:Menu runat="server">
                                                        <Items>
                                                            <ext:MenuItem runat="server" Text="普通" IconUrl="mxgraph/examples/editors/images/open_end.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_ENDARROW,mxConstants.ARROW_OPEN)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="经典" IconUrl="mxgraph/examples/editors/images/classic_end.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_ENDARROW,mxConstants.ARROW_CLASSIC)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="加粗" IconUrl="mxgraph/examples/editors/images/block_end.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_ENDARROW,mxConstants.ARROW_BLOCK)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="菱形" IconUrl="mxgraph/examples/editors/images/diamond_end.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_ENDARROW,mxConstants.ARROW_DIAMOND)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="圆形" IconUrl="mxgraph/examples/editors/images/oval_end.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_ENDARROW,mxConstants.ARROW_OVAL)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="无" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_ENDARROW,mxConstants.NONE)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="大小" >
                                                                <Listeners>
                                                                    <Click Handler="var value = mxConstants.DEFAULT_MARKERSIZE;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_ENDSIZE] || value
                                                                    }
                                                                    Ext.Msg.prompt('大小','输入大小',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_ENDSIZE,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>
                                                        </Items>
                                                    </ext:Menu>
                                                </Menu>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="间隔" >
                                                <Menu>
                                                    <ext:Menu runat="server">
                                                        <Items>
                                                            <ext:MenuItem runat="server" Text="顶部" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 0;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_SPACING_TOP] || value
                                                                    }
                                                                    Ext.Msg.prompt('顶部','输入顶部间隔 (像素)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_SPACING_TOP,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="右侧" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 0;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_SPACING_RIGHT] || value
                                                                    }
                                                                    Ext.Msg.prompt('右侧','输入右侧间隔 (像素)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_SPACING_RIGHT,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="底部" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 0;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_SPACING_BOTTOM] || value
                                                                    }
                                                                    Ext.Msg.prompt('底部','输入底部间隔 (像素)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_SPACING_BOTTOM,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="左侧" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 0;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_SPACING_LEFT] || value
                                                                    }
                                                                    Ext.Msg.prompt('左侧','输入左侧间隔 (像素)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_SPACING_LEFT,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="整体" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 0;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_SPACING] || value
                                                                    }
                                                                    Ext.Msg.prompt('整体','输入间隔 (像素)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_SPACING,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="源间隔" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 0;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_SOURCE_PERIMETER_SPACING] || value
                                                                    }
                                                                    Ext.Msg.prompt('源间隔','输入源间隔 (像素)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_SOURCE_PERIMETER_SPACING,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="目标间隔" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 0;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_TARGET_PERIMETER_SPACING] || value
                                                                    }
                                                                    Ext.Msg.prompt('目标间隔','输入目标间隔 (像素)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_TARGET_PERIMETER_SPACING,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="边缘间隔" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 0;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_PERIMETER_SPACING] || value
                                                                    }
                                                                    Ext.Msg.prompt('边缘间隔','输入边缘间隔 (像素)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_PERIMETER_SPACING,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>
                                                        </Items>
                                                    </ext:Menu>
                                                </Menu>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="方向" >
                                                <Menu>
                                                    <ext:Menu runat="server">
                                                        <Items>
                                                            <ext:MenuItem runat="server" Text="上" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_DIRECTION,mxConstants.DIRECTION_NORTH)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="下" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_DIRECTION,mxConstants.DIRECTION_SOUTH)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="左" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_DIRECTION,mxConstants.DIRECTION_WEST)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="右" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_DIRECTION,mxConstants.DIRECTION_EAST)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="转动角度" >
                                                                <Listeners>
                                                                    <Click Handler="var value = 0;
                                                                    var state = ExtMxGraph.getView().getState(ExtMxGraph.getSelectionCell());
                                                                    if (state != null) {
                                                                        value = state.style[mxConstants.STYLE_ROTATION] || value
                                                                    }
                                                                    Ext.Msg.prompt('转动角度','输入角度 (0-360)',function(btn, text, cfg) {
                                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                                            ExtMxGraph.setCellStyles(mxConstants.STYLE_ROTATION,text)
                                                                        }},this, false, value);" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                        </Items>
                                                    </ext:Menu>
                                                </Menu>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="平滑" >
                                                <Listeners>
                                                    <Click Handler="ExtMxGraph.toggleCellStyles(mxConstants.STYLE_ROUNDED)" />
                                                </Listeners>
                                            </ext:MenuItem>

                                            <ext:MenuItem runat="server" Text="样式" >
                                                <Listeners>
                                                    <Click Handler="var cells = ExtMxGraph.getSelectionCells();
                                                    if (cells != null && cells.length != 0) {
                                                    var model = ExtMxGraph.getModel();
                                                    Ext.Msg.prompt('样式','输入样式',function(btn, text, cfg) {
                                                        if(btn == 'ok' && !Ext.isEmpty(text)) {
                                                            ExtMxGraph.setCellStyle(text,cells)
                                                        }},this, false, model.getStyle(cells[0]));}" />
                                                </Listeners>
                                            </ext:MenuItem>
                                        </Items>
                                    </ext:Menu>
                                </Menu>
                            </ext:MenuItem>

                            <ext:MenuItem runat="server" Text="形状" Split="true" >
                                <Menu>
                                    <ext:Menu runat="server" >
                                        <Items>
                                            <ext:MenuItem runat="server" Text="根节点" IconCls="home-icon" ID="btnContextMenuHome" >
                                                <Listeners>
                                                    <Click Handler="ExtMxGraph.home()" />
                                                </Listeners>
                                            </ext:MenuItem>

                                            <ext:MenuItem runat="server" Text="根节点" IconCls="up-icon" ID="btnContextMenuExitGroup" >
                                                <Listeners>
                                                    <Click Handler="ExtMxGraph.exitGroup()" />
                                                </Listeners>
                                            </ext:MenuItem>

                                            <ext:MenuItem runat="server" Text="下一组层次" IconCls="down-icon" ID="btnContextMenuEnterGroup" >
                                                <Listeners>
                                                    <Click Handler="ExtMxGraph.enterGroup()" />
                                                </Listeners>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="组合" IconUrl="mxgraph/examples/editors/images/group.gif" ID="btnContextMenuGroup" >
                                                <Listeners>
                                                    <Click Handler="ExtMxGraph.setSelectionCell(ExtMxGraph.groupCells(null, 20))" />
                                                </Listeners>
                                            </ext:MenuItem>

                                            <ext:MenuItem runat="server" Text="拆分" IconUrl="mxgraph/examples/editors/images/ungroup.gif" ID="btnContextMenuUnGroup" >
                                                <Listeners>
                                                    <Click Handler="ExtMxGraph.setSelectionCells(ExtMxGraph.ungroupCells())" />
                                                </Listeners>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="从组中移除" >
                                                <Listeners>
                                                    <Click Handler="ExtMxGraph.removeCellsFromParent()" />
                                                </Listeners>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="收起" IconCls="collapse-icon" ID="btnContextMenuCollapse" >
                                                <Listeners>
                                                    <Click Handler="ExtMxGraph.foldCells(true)" />
                                                </Listeners>
                                            </ext:MenuItem>

                                            <ext:MenuItem runat="server" Text="展开" IconCls="expand-icon" ID="btnContextMenuExpand" >
                                                <Listeners>
                                                    <Click Handler="ExtMxGraph.foldCells(false)" />
                                                </Listeners>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="后退" IconCls="toback-icon" >
                                                <Listeners>
                                                    <Click Handler="ExtMxGraph.orderCells(true)" />
                                                </Listeners>
                                            </ext:MenuItem>

                                            <ext:MenuItem runat="server" Text="前进" IconCls="tofront-icon" >
                                                <Listeners>
                                                    <Click Handler="ExtMxGraph.orderCells(false)" />
                                                </Listeners>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="排版" >
                                                <Menu>
                                                    <ext:Menu runat="server" >
                                                        <Items>
                                                            <ext:MenuItem runat="server" Text="居左" IconUrl="mxgraph/examples/editors/images/alignleft.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.alignCells(mxConstants.ALIGN_LEFT)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="居中" IconUrl="mxgraph/examples/editors/images/aligncenter.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.alignCells(mxConstants.ALIGN_CENTER)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="居右" IconUrl="mxgraph/examples/editors/images/alignright.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.alignCells(mxConstants.ALIGN_RIGHT)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuSeparator runat="server" />

                                                            <ext:MenuItem runat="server" Text="置顶" IconUrl="mxgraph/examples/editors/images/aligntop.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.alignCells(mxConstants.ALIGN_TOP)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="垂直居中" IconUrl="mxgraph/examples/editors/images/alignmiddle.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.alignCells(mxConstants.ALIGN_MIDDLE)" />
                                                                </Listeners>
                                                            </ext:MenuItem>

                                                            <ext:MenuItem runat="server" Text="置底" IconUrl="mxgraph/examples/editors/images/alignbottom.gif" >
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.alignCells(mxConstants.ALIGN_BOTTOM)" />
                                                                </Listeners>
                                                            </ext:MenuItem>
                                                        </Items>                                                    
                                                    </ext:Menu>
                                                </Menu>
                                            </ext:MenuItem>

                                            <ext:MenuSeparator runat="server" />

                                            <ext:MenuItem runat="server" Text="自适应大小" >
                                                <Listeners>
                                                    <Click Handler="if (!ExtMxGraph.isSelectionEmpty()) {ExtMxGraph.updateCellSize(ExtMxGraph.getSelectionCell())}" />
                                                </Listeners>
                                            </ext:MenuItem>
                                        </Items>
                                    </ext:Menu>
                                </Menu>
                            </ext:MenuItem>

                            <ext:MenuSeparator runat="server" />

                             <ext:MenuItem runat="server" Text="编辑" >
                                <Listeners>
                                    <Click Handler="ExtMxGraph.startEditing()" />
                                </Listeners>
                             </ext:MenuItem>

                             <ext:MenuSeparator runat="server" />

                             <ext:MenuItem runat="server" Text="选择所有形状" >
                                <Listeners>
                                    <Click Handler="ExtMxGraph.selectVertices()" />
                                </Listeners>
                             </ext:MenuItem>

                             <ext:MenuItem runat="server" Text="选择所有连线" >
                                <Listeners>
                                    <Click Handler="ExtMxGraph.selectEdges()" />
                                </Listeners>
                             </ext:MenuItem>

                             <ext:MenuItem runat="server" Text="全选" >
                                <Listeners>
                                    <Click Handler="ExtMxGraph.selectAll()" />
                                </Listeners>
                             </ext:MenuItem>

                             <ext:MenuSeparator runat="server" />

                             <ext:MenuItem runat="server" Text="属性" >
                                <Listeners>
                                    <Click Handler="showProps(ExtMxGraph, true,#{PropertyPanel},#{pgrid})" />
                                </Listeners>
                             </ext:MenuItem>
                        </Items>
                    </ext:Menu>

                    <ext:Panel ID="MainPanel" runat="server" Region="Center"  Border="false" ContextMenuID="MainPanelContextMenu">
                        <Listeners>
                            <Resize Handler="ExtMxGraphReSize()" />
                        </Listeners>
                        <TopBar>
                            <ext:Toolbar runat="server" ID="MainPanelToolbar">
                                <Items>
                                    <ext:Button runat="server" IconCls="preview-icon" ID="btnView" ToolTip="预览" >
                                        <Listeners>
                                            <Click Handler="mxUtils.show(ExtMxGraph);" />
                                        </Listeners>
                                    </ext:Button>

                                    <ext:ToolbarSeparator runat="server" />

                                     <ext:Button runat="server" IconCls="cut-icon" ID="btnCut" ToolTip="剪切" >
                                        <Listeners>
                                            <Click Handler="mxClipboard.cut(ExtMxGraph);" />
                                        </Listeners>
                                     </ext:Button>

                                     <ext:Button runat="server" IconCls="copy-icon" ID="btnCopy" ToolTip="复制" >
                                        <Listeners>
                                            <Click Handler="mxClipboard.copy(ExtMxGraph);" />
                                        </Listeners>
                                     </ext:Button>

                                     <ext:Button runat="server" IconCls="paste-icon" ID="btnPaste" ToolTip="粘贴" >
                                        <Listeners>
                                            <Click Handler="mxClipboard.paste(ExtMxGraph);" />
                                        </Listeners>
                                     </ext:Button>

                                     <ext:ToolbarSeparator runat="server" />

                                     <ext:Button runat="server" IconCls="delete-icon" ID="btnDelete" ToolTip="删除" >
                                        <Listeners>
                                            <Click Handler="ExtMxGraph.removeCells();" />
                                        </Listeners>
                                     </ext:Button>

                                     <ext:ToolbarSeparator runat="server" />

                                     <ext:Button runat="server" IconCls="undo-icon" ID="btnUndo" ToolTip="撤销" >
                                        <Listeners>
                                            <Click Handler="ExtMxHistory.undo();" />
                                        </Listeners>
                                     </ext:Button>

                                     <ext:Button runat="server" IconCls="redo-icon" ID="btnRedo" ToolTip="恢复" >
                                        <Listeners>
                                            <Click Handler="ExtMxHistory.redo();" />
                                        </Listeners>
                                     </ext:Button>

                                     <ext:ToolbarSeparator runat="server" />

                                     <ext:Button runat="server" IconCls="bold-icon" ID="btnBold" ToolTip="粗体" >
                                        <Listeners>
                                            <Click Handler="ExtMxGraph.toggleCellStyleFlags(mxConstants.STYLE_FONTSTYLE,mxConstants.FONT_BOLD);" />
                                        </Listeners>
                                     </ext:Button>

                                     <ext:Button runat="server" IconCls="italic-icon" ID="btnItalic" ToolTip="斜体" >
                                        <Listeners>
                                            <Click Handler="ExtMxGraph.toggleCellStyleFlags(mxConstants.STYLE_FONTSTYLE,mxConstants.FONT_ITALIC);" />
                                        </Listeners>
                                     </ext:Button>

                                     <ext:Button runat="server" IconCls="underline-icon" ID="btnUnderline" ToolTip="斜体" >
                                        <Listeners>
                                            <Click Handler="ExtMxGraph.toggleCellStyleFlags(mxConstants.STYLE_FONTSTYLE,mxConstants.FONT_UNDERLINE);" />
                                        </Listeners>
                                     </ext:Button>

                                    <ext:ToolbarSeparator runat="server" />

                                    <ext:Button ID="btnAlign" runat="server" Text="文字排版" IconCls="left-icon">
                                        <Menu>
                                            <ext:Menu runat="server" Cls="reading-menu" >
                                                <Items>
                                                    <ext:CheckMenuItem runat="server" Text="居左" Checked="false" Group="rp-group" IconCls="left-icon">
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_ALIGN,mxConstants.ALIGN_LEFT)" />
                                                        </Listeners>
                                                    </ext:CheckMenuItem>

                                                    <ext:CheckMenuItem runat="server" Text="居中" Checked="true" Group="rp-group" IconCls="center-icon">
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_ALIGN,mxConstants.ALIGN_CENTER)" />
                                                        </Listeners>
                                                    </ext:CheckMenuItem>

                                                    <ext:CheckMenuItem runat="server" Text="居右" Checked="false" Group="rp-group" IconCls="right-icon">
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_ALIGN,mxConstants.ALIGN_RIGHT)" />
                                                        </Listeners>
                                                    </ext:CheckMenuItem>

                                                    <ext:MenuSeparator runat="server" />

                                                    <ext:CheckMenuItem runat="server" Text="置顶" Checked="false" Group="vrp-group" IconCls="top-icon" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_VERTICAL_ALIGN,mxConstants.ALIGN_TOP)" />
                                                        </Listeners>
                                                    </ext:CheckMenuItem>

                                                    <ext:CheckMenuItem runat="server" Text="垂直居中" Checked="true" Group="vrp-group" IconCls="middle-icon" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_VERTICAL_ALIGN,mxConstants.ALIGN_MIDDLE)" />
                                                        </Listeners>
                                                    </ext:CheckMenuItem>

                                                    <ext:CheckMenuItem runat="server" Text="置底" Checked="false" Group="vrp-group" IconCls="bottom-icon" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_VERTICAL_ALIGN,mxConstants.ALIGN_BOTTOM)" />
                                                        </Listeners>
                                                    </ext:CheckMenuItem>
                                                </Items>
                                            </ext:Menu>
                                        </Menu>
                                    </ext:Button>

                                    <ext:ToolbarSeparator runat="server" />

                                    <ext:Button runat="server" IconCls="fontcolor-icon" ID="btnFontcolor" ToolTip="字体颜色" >
                                        <Menu>
                                            <ext:ColorMenu runat="server">
                                                <BottomBar>
                                                    <ext:Toolbar runat="server">
                                                        <Items>
                                                            <ext:Button Width="145" runat="server" Text="无">
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_FONTCOLOR,mxConstants.NONE)" />
                                                                </Listeners>
                                                            </ext:Button>
                                                        </Items>
                                                    </ext:Toolbar>
                                                </BottomBar>
                                                <Listeners>
                                                    <Select Handler="if (typeof(color) == 'string') { ExtMxGraph.setCellStyles(mxConstants.STYLE_FONTCOLOR, '#' + color)}" />
                                                </Listeners>
                                            </ext:ColorMenu>
                                        </Menu>
                                    </ext:Button>

                                    <ext:Button runat="server" IconCls="linecolor-icon" ID="btnLinecolor" ToolTip="线颜色" >
                                        <Menu>
                                            <ext:ColorMenu runat="server">
                                                <BottomBar>
                                                    <ext:Toolbar runat="server">
                                                        <Items>
                                                            <ext:Button Width="145" runat="server" Text="无">
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_STROKECOLOR,mxConstants.NONE)" />
                                                                </Listeners>
                                                            </ext:Button>
                                                        </Items>
                                                    </ext:Toolbar>
                                                </BottomBar>
                                                <Listeners>
                                                    <Select Handler="if (typeof(color) == 'string') { ExtMxGraph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#' + color)}" />
                                                </Listeners>
                                            </ext:ColorMenu>
                                        </Menu>
                                    </ext:Button>

                                    <ext:Button runat="server" IconCls="fillcolor-icon" ID="btnFillcolor" ToolTip="填充颜色" >
                                        <Menu>
                                            <ext:ColorMenu runat="server">
                                                <BottomBar>
                                                    <ext:Toolbar runat="server">
                                                        <Items>
                                                            <ext:Button Width="145" runat="server" Text="无">
                                                                <Listeners>
                                                                    <Click Handler="ExtMxGraph.setCellStyles(mxConstants.STYLE_FILLCOLOR,mxConstants.NONE)" />
                                                                </Listeners>
                                                            </ext:Button>
                                                        </Items>
                                                    </ext:Toolbar>
                                                </BottomBar>
                                                <Listeners>
                                                    <Select Handler="if (typeof(color) == 'string') { ExtMxGraph.setCellStyles(mxConstants.STYLE_FILLCOLOR, '#' + color)}" />
                                                </Listeners>
                                            </ext:ColorMenu>
                                        </Menu>
                                    </ext:Button>

                                    <ext:ToolbarSeparator runat="server" />

                                    <ext:Button runat="server" IconCls="zoom-icon" ID="btnZoom" ToolTip="大小" >
                                        <Menu>
                                            <ext:Menu runat="server">
                                                <Items>
                                                     <ext:MenuItem runat="server" Text="自定义" >
                                                        <Listeners>
                                                            <Click Fn="customerZoom" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="400%" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.getView().setScale(4)" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="200%" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.getView().setScale(2)" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="150%" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.getView().setScale(1.5)" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="100%" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.getView().setScale(1)" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="75%" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.getView().setScale(0.75)" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="50%" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.getView().setScale(0.5)" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="25%" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.getView().setScale(0.25)" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuSeparator runat="server" />

                                                     <ext:MenuItem runat="server" Text="放大" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.zoomIn();" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="缩小" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.zoomOut();" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuSeparator runat="server" />

                                                     <ext:MenuItem runat="server" Text="实际大小" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.zoomActual();" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="自适应窗口" >
                                                        <Listeners>
                                                            <Click Handler="ExtMxGraph.fit();" />
                                                        </Listeners>
                                                     </ext:MenuItem>
                                                </Items>
                                            </ext:Menu>
                                        </Menu>
                                    </ext:Button>

                                    <ext:ToolbarSeparator runat="server" />

                                    <ext:Button runat="server" IconCls="diagram-icon" ToolTip="布局" >
                                        <Menu>
                                            <ext:Menu runat="server">
                                                <Items>
                                                    <ext:MenuItem runat="server" Text="垂直层次布局" >
                                                        <Listeners>
                                                            <Click Handler="executeLayout(new mxHierarchicalLayout(ExtMxGraph),true);" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="水平层次布局" >
                                                        <Listeners>
                                                            <Click Handler="executeLayout(new mxHierarchicalLayout(ExtMxGraph,mxConstants.DIRECTION_WEST),true);" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="平行排列连线" >
                                                        <Listeners>
                                                            <Click Handler="executeLayout(new mxCircleLayout(ExtMxGraph), true)" />
                                                        </Listeners>
                                                     </ext:MenuItem>

                                                     <ext:MenuItem runat="server" Text="有机布局" >
                                                        <Listeners>
                                                            <Click Handler="var layout = new mxFastOrganicLayout(ExtMxGraph);layout.forceConstant = 80;executeLayout(layout, true)" />
                                                        </Listeners>
                                                     </ext:MenuItem>
                                                </Items>
                                            </ext:Menu>
                                        </Menu>
                                    </ext:Button>

                                    <ext:ToolbarSeparator runat="server" />

                                    <ext:Button runat="server" IconCls="preferences-icon" ToolTip="选项" >
                                        <Menu>
                                            <ext:Menu runat="server">
                                                <Items>
                                                    <ext:MenuItem runat="server" Text="网格">
                                                        <Menu>
                                                            <ext:Menu runat="server">
                                                                <Items>
                                                                    <ext:MenuItem runat="server" Text="网格大小" >
                                                                        <Listeners>
                                                                            <Click Fn="customerGridSize" />
                                                                        </Listeners>
                                                                     </ext:MenuItem>

                                                                     <ext:CheckMenuItem runat="server" Checked="true" Text="启动网格">
                                                                        <Listeners>
                                                                            <CheckChange Fn="checkGridEnabled" />
                                                                        </Listeners>
                                                                     </ext:CheckMenuItem>
                                                                </Items>
                                                            </ext:Menu>
                                                        </Menu>
                                                    </ext:MenuItem>

                                                    <ext:MenuItem runat="server" Text="标签" >
                                                        <Menu>
                                                            <ext:Menu runat="server">
                                                                <Items>
                                                                    <ext:CheckMenuItem runat="server" Checked="true" Text="显示标签" >
                                                                        <Listeners>
                                                                            <CheckChange Handler="ExtMxGraph.labelsVisible = checked;ExtMxGraph.refresh();" />
                                                                        </Listeners>
                                                                    </ext:CheckMenuItem>

                                                                    <ext:CheckMenuItem runat="server" Checked="true" Text="允许移动连线标签" >
                                                                        <Listeners>
                                                                            <CheckChange Handler="ExtMxGraph.edgeLabelsMovable = checked;" />
                                                                        </Listeners>
                                                                    </ext:CheckMenuItem>

                                                                    <ext:CheckMenuItem runat="server" Checked="true" Text="允许移动图形标签" >
                                                                        <Listeners>
                                                                            <CheckChange Handler="ExtMxGraph.vertexLabelsMovable = checked;" />
                                                                        </Listeners>
                                                                    </ext:CheckMenuItem>
                                                                </Items>
                                                            </ext:Menu>
                                                        </Menu>
                                                    </ext:MenuItem>

                                                    <ext:MenuSeparator runat="server" />

                                                    <ext:MenuItem runat="server" Text="连接线" >
                                                        <Menu>
                                                            <ext:Menu runat="server">
                                                                <Items>
                                                                    <ext:CheckMenuItem runat="server" Checked="true" Text="自动连接线" >
                                                                        <Listeners>
                                                                            <CheckChange Handler="ExtMxGraph.setConnectable(checked);" />
                                                                        </Listeners>
                                                                    </ext:CheckMenuItem>

                                                                    <ext:CheckMenuItem runat="server" Checked="true" Text="自动创建目标图形" >
                                                                        <Listeners>
                                                                            <CheckChange Handler="ExtMxGraph.connectionHandler.setCreateTarget(checked);" />
                                                                        </Listeners>
                                                                    </ext:CheckMenuItem>
                                                                </Items>
                                                            </ext:Menu>
                                                        </Menu>
                                                    </ext:MenuItem>

                                                    <ext:MenuItem runat="server" Text="图形规则" >
                                                        <Menu>
                                                            <ext:Menu runat="server">
                                                                <Items>
                                                                    <ext:CheckMenuItem runat="server" Checked="true" Text="允许悬空连接" >
                                                                        <Listeners>
                                                                            <CheckChange Handler="ExtMxGraph.setAllowDanglingEdges(checked);" />
                                                                        </Listeners>
                                                                    </ext:CheckMenuItem>

                                                                    <ext:CheckMenuItem runat="server" Checked="true" Text="允许自连" >
                                                                        <Listeners>
                                                                            <CheckChange Handler="ExtMxGraph.setAllowLoops(checked);" />
                                                                        </Listeners>
                                                                    </ext:CheckMenuItem>
                                                                </Items>
                                                            </ext:Menu>
                                                        </Menu>
                                                    </ext:MenuItem>

                                                    <ext:MenuSeparator runat="server" />

                                                    <ext:MenuItem runat="server" Text="显示 XML" >
                                                        <Listeners>
                                                            <Click Handler="var enc = new mxCodec(mxUtils.createXmlDocument());var node = enc.encode(ExtMxGraph.getModel());mxUtils.popup(mxUtils.getPrettyXml(node))" />
                                                        </Listeners>
                                                    </ext:MenuItem>


                                                </Items>
                                            </ext:Menu>
                                        </Menu>
                                    </ext:Button>
                                </Items>      
                            </ext:Toolbar>
                        </TopBar>

                        <Content>
                            <div id="graphContainer" class="x-tab"  />

                            <textarea style="display:none" id="data">
                                <mxGraphModel>  <root>    <Diagram label="My Diagram" href="http://www.mxgraph.com/" id="0">      <mxCell/>    </Diagram>    <Layer label="Default Layer" id="1">      <mxCell parent="0"/>    </Layer>    <Shape label="开始" href="5" id="5">      <mxCell style="ellipse;fillColor=#00FF00;shadow=1" parent="1" vertex="1">        <mxGeometry x="80" y="140" width="40" height="40" as="geometry"/>      </mxCell>    </Shape>    <Shape label="结束" href="" id="6">      <mxCell style="ellipse;fillColor=#FF0000;shadow=1" parent="1" vertex="1">        <mxGeometry x="710" y="140" width="40" height="40" as="geometry"/>      </mxCell>    </Shape>    <Rect label="流程1" href="9" id="9">      <mxCell style="fillColor=#CCFFFF;gradientDirection=south;dashed=1;shadow=1" parent="1" vertex="1">        <mxGeometry x="190" y="140" width="80" height="40" as="geometry"/>      </mxCell>    </Rect>    <Rect label="流程2" href="" id="10">      <mxCell style="fillColor=#CCFFFF;gradientDirection=south;dashed=1;shadow=1" parent="1" vertex="1">        <mxGeometry x="320" y="140" width="80" height="40" as="geometry"/>      </mxCell>    </Rect>    <mxCell id="11" value="" style="noEdgeStyle=1;shadow=1" parent="1" source="9" target="10" edge="1">      <mxGeometry relative="1" as="geometry"/>    </mxCell>    <Rect label="流程3" href="" id="12">      <mxCell style="fillColor=#CCFFFF;gradientDirection=south;dashed=1;shadow=1" parent="1" vertex="1">        <mxGeometry x="450" y="140" width="80" height="40" as="geometry"/>      </mxCell>    </Rect>    <mxCell id="13" value="" style="noEdgeStyle=1;shadow=1" parent="1" source="10" target="12" edge="1">      <mxGeometry relative="1" as="geometry"/>    </mxCell>    <Rect label="流程4" href="" id="14">      <mxCell style="fillColor=#CCFFFF;gradientDirection=south;dashed=1;shadow=1" parent="1" vertex="1">        <mxGeometry x="580" y="140" width="80" height="40" as="geometry"/>      </mxCell>    </Rect>    <mxCell id="15" value="" style="noEdgeStyle=1;shadow=1" parent="1" source="12" target="14" edge="1">      <mxGeometry relative="1" as="geometry"/>    </mxCell>    <mxCell id="16" value="" style="noEdgeStyle=1;shadow=1;dashed=1" parent="1" source="14" target="6" edge="1">      <mxGeometry relative="1" as="geometry"/>    </mxCell>    <mxCell id="17" value="" style="noEdgeStyle=1;shadow=1;dashed=1" parent="1" source="5" target="9" edge="1">      <mxGeometry relative="1" as="geometry"/>    </mxCell>    <Container label="说明" href="" id="19">      <mxCell style="swimlane" vertex="1" connectable="0" parent="1">        <mxGeometry x="190" y="240" width="470" height="80" as="geometry"/>      </mxCell>    </Container>    <Text label="这是一个流程图例子" href="" id="20">      <mxCell style="text;rounded=1;verticalAlign=middle;align=center" vertex="1" parent="19">        <mxGeometry y="20" width="470" height="60" as="geometry"/>      </mxCell>    </Text>  </root></mxGraphModel>
                            </textarea>
                        </Content>
                    </ext:Panel>

                    <ext:Panel ID="PropertyPanel" Title="属性栏" runat="server" Region="East" Width="200" Border="false" Layout="FitLayout" Split="true" Collapsible="true" >
                        <Items>
                            <ext:PropertyGrid runat="server" ID="pgrid" ForceFit="true" >
                                <Source>
                                    <ext:PropertyGridParameter Name="(name)" Value="Properties Grid" />
                                </Source>
                            </ext:PropertyGrid>
                        </Items>
                    </ext:Panel>
                </Items>
            </ext:Panel>
        </Items>
    </ext:Viewport>

    </form>
</body>
</html>
