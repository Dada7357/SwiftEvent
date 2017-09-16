GraphEditor = {};
var editor = null;
var ExtMxGraph = null;
var ExtMxHistory = null;

var executeLayout = function (layout, animate, ignoreChildCount) {
    var cell = ExtMxGraph.getSelectionCell();
    if (cell == null || (!ignoreChildCount && ExtMxGraph.getModel().getChildCount(cell) == 0)) {
        cell = ExtMxGraph.getDefaultParent()
    }
    if (animate && navigator.userAgent.indexOf('Camino') < 0) {
        var listener = function (sender, evt) {
            mxUtils.animateChanges(ExtMxGraph, evt.properties.edit);
            ExtMxGraph.getModel().removeListener(listener)
        };
        ExtMxGraph.getModel().addListener(mxEvent.CHANGE, listener)
    }
    layout.execute(cell)
};

var mxApplication = function (config) {
    try {
        if (!mxClient.isBrowserSupported()) {
            mxUtils.error('Browser is not supported!', 200, false);
        }
        else {
            var node = mxUtils.load(config).getDocumentElement();
            var editor = new mxEditor(node);
            // Displays version in statusbar
            editor.setStatus('mxGraph ' + mxClient.VERSION);
        }
    }
    catch (e) {
        // Shows an error message if the editor cannot start
        //mxUtils.alert('Cannot start application: ' + e.message);
        Ext.Msg.alert("Error", 'Cannot start application: ' + e.message);

        throw e; // for debugging
    }
    return editor;
}

var InitMain = function (container, mainPanel, mainPanelToolbar, library, outlinePanel, propertyPanel, pgrid) {

    editor = new mxApplication('config/diagrameditor.xml');

    Ext.QuickTips.init();
    mxEvent.disableContextMenu(document.body);
    mxConstants.DEFAULT_HOTSPOT = 0.3;
    ExtMxGraph = editor.graph;

    ExtMxHistory = new mxUndoManager();
    var node = mxUtils.load('resources/default-style.xml').getDocumentElement();
    var dec = new mxCodec(node.ownerDocument);
    dec.decode(node, ExtMxGraph.getStylesheet());
    ExtMxGraph.alternateEdgeStyle = 'vertical';

    ExtMxGraph.panningHandler.popup = function (x, y, cell, evt) {

        if (Ext.getCmp(mainPanel.contextMenuId)) {
            Ext.getCmp(mainPanel.contextMenuId).show
        }
        //mainPanel.onContextMenu(null, evt)
    };
    ExtMxGraph.panningHandler.hideMenu = function () {
        if (Ext.getCmp(mainPanel.contextMenuId)) {
            Ext.getCmp(mainPanel.contextMenuId).hide()
        }
    };

    //    container.style.overflow = 'auto';
    if (mxClient.IS_MAC && mxClient.IS_SF) {
        ExtMxGraph.addListener(mxEvent.SIZE, function (graph) {
            graph.container.style.overflow = 'auto'
        })
    }

    //    ExtMxGraph.init(mainPanel.graphPanel.body.dom);
    ExtMxGraph.init(container);
    ExtMxGraph.setConnectable(true);
    ExtMxGraph.setDropEnabled(true);
    ExtMxGraph.setPanning(true);
    ExtMxGraph.setTooltips(true);
    ExtMxGraph.connectionHandler.setCreateTarget(true);
    var rubberband = new mxRubberband(ExtMxGraph);
    var parent = ExtMxGraph.getDefaultParent();

    ExtMxGraph.getModel().beginUpdate();
    try {
        loadXML(ExtMxGraph)
    } finally {
        ExtMxGraph.getModel().endUpdate()
    }

    var listener = function (sender, evt) {
        //ExtMxHistory.undoableEditHappened(evt);
        ExtMxHistory.undoableEditHappened(evt.properties.edit);
    };

    ExtMxGraph.getModel().addListener(mxEvent.UNDO, listener);
    ExtMxGraph.getView().addListener(mxEvent.UNDO, listener);

    var toolbarItems = mainPanelToolbar.items;
    var selectionListener = function () {
        showProps(ExtMxGraph, false, propertyPanel, pgrid);
        var selected = !ExtMxGraph.isSelectionEmpty();
        toolbarItems.get('btnCut').setDisabled(!selected);
        toolbarItems.get('btnCopy').setDisabled(!selected);
        toolbarItems.get('btnDelete').setDisabled(!selected);
        toolbarItems.get('btnItalic').setDisabled(!selected);
        toolbarItems.get('btnBold').setDisabled(!selected);
        toolbarItems.get('btnUnderline').setDisabled(!selected);
        toolbarItems.get('btnFillcolor').setDisabled(!selected);
        toolbarItems.get('btnFontcolor').setDisabled(!selected);
        toolbarItems.get('btnLinecolor').setDisabled(!selected);
        toolbarItems.get('btnAlign').setDisabled(!selected)
    };

    ExtMxGraph.getSelectionModel().addListener(mxEvent.CHANGE, selectionListener);
    var historyListener = function () {
        toolbarItems.get('btnUndo').setDisabled(!ExtMxHistory.canUndo());
        toolbarItems.get('btnRedo').setDisabled(!ExtMxHistory.canRedo())
    };

    ExtMxHistory.addListener(mxEvent.ADD, historyListener);
    ExtMxHistory.addListener(mxEvent.UNDO, historyListener);
    ExtMxHistory.addListener(mxEvent.REDO, historyListener);

    selectionListener();
    historyListener();

    var outline = new mxOutline(ExtMxGraph, outlinePanel.body.dom);
    insertVertexTemplate(library, ExtMxGraph, '文本', '../mxgraph/examples/editors/images/text.gif',
    			'text;rounded=1', 80, 20, 'text');
    insertVertexTemplate(library, ExtMxGraph, '容器', '../mxgraph/examples/editors/images/swimlane.gif',
    			'swimlane', 200, 200, 'container');
    insertVertexTemplate(library, ExtMxGraph, '矩形', '../mxgraph/examples/editors/images/rectangle.gif', null,
    			100, 40, "rectangle");
    insertVertexTemplate(library, ExtMxGraph, '平滑矩形', '../mxgraph/examples/editors/images/rounded.gif',
    			'rounded=1', 100, 40, "rounded");
    insertVertexTemplate(library, ExtMxGraph, '椭圆', '../mxgraph/examples/editors/images/ellipse.gif', 'ellipse',
    			60, 60, "ellipse");
    insertVertexTemplate(library, ExtMxGraph, '双环椭圆', '../mxgraph/examples/editors/images/doubleellipse.gif',
    			'ellipse;shape=doubleEllipse', 60, 60, "doubleellipse");
    insertVertexTemplate(library, ExtMxGraph, '三角形', '../mxgraph/examples/editors/images/triangle.gif',
    			'triangle', 40, 60, "triangle");
    insertVertexTemplate(library, ExtMxGraph, '菱形', '../mxgraph/examples/editors/images/rhombus.gif', 'rhombus',
    			60, 60, "rhombus");
    insertVertexTemplate(library, ExtMxGraph, '水平线', '../mxgraph/examples/editors/images/hline.gif', 'line',
    			120, 10, "hline");
    insertVertexTemplate(library, ExtMxGraph, '六边形', '../mxgraph/examples/editors/images/hexagon.gif',
    			'shape=hexagon', 80, 60, "hexagon");
    insertVertexTemplate(library, ExtMxGraph, '圆柱体', '../mxgraph/examples/editors/images/cylinder.gif',
    			'shape=cylinder', 60, 80, "cylinder");
    insertVertexTemplate(library, ExtMxGraph, '角色', '../mxgraph/examples/editors/images/actor.gif',
    			'shape=actor', 40, 60, "actor");
    insertVertexTemplate(library, ExtMxGraph, '对话', '../mxgraph/examples/editors/images/cloud.gif',
    			'ellipse;shape=cloud', 80, 60, "cloud");
    insertEdgeTemplate(library, ExtMxGraph, '直线', '../mxgraph/examples/editors/images/straight.gif', 'straight',
    			100, 100, "connector");
    insertEdgeTemplate(library, ExtMxGraph, '水平连接线', '../mxgraph/examples/editors/images/connect.gif', null,
    			100, 100, "connector");
    insertEdgeTemplate(library, ExtMxGraph, '垂直连接线', '../mxgraph/examples/editors/images/vertical.gif',
    			'vertical', 100, 100, "connector");
    insertEdgeTemplate(library, ExtMxGraph, '实体关系', '../mxgraph/examples/editors/images/entity.gif', 'entity',
    			100, 100, "connector");
    insertEdgeTemplate(library, ExtMxGraph, '箭头', '../mxgraph/examples/editors/images/arrow.gif', 'arrow', 100,
    			100, "connector");
    var previousCreateGroupCell = ExtMxGraph.createGroupCell;
    ExtMxGraph.createGroupCell = function () {
        var group = previousCreateGroupCell.apply(this, arguments);
        group.setStyle('group');
        return group
    };
    ExtMxGraph.connectionHandler.factoryMethod = function () {
        if (GraphEditor.edgeTemplate != null) {
            return ExtMxGraph.cloneCells([GraphEditor.edgeTemplate])[0]
        }
        return null
    };
    library.getSelectionModel().on('selectionchange', function (sm, node) {
        if (node != null && node.length > 0 && node[0] && node[0].cells) {
            var cell = node[0].cells[0];
            if (ExtMxGraph.getModel().isEdge(cell)) {
                GraphEditor.edgeTemplate = cell;
            }
        }
    });

    //library.expandAll(false);
    library.getStore().getNodeById("0").expand(true);

    var tooltip = new Ext.ToolTip({
        target: ExtMxGraph.container,
        html: ''
    });
    tooltip.disabled = true;

    ExtMxGraph.tooltipHandler.show = function (tip, x, y) {
        if (tip != null && tip.length > 0) {
            if (tooltip.body != null) {
                tooltip.body.dom.firstChild.nodeValue = tip
            } else {
                tooltip.html = tip
            }
            tooltip.showAt([x, y + mxConstants.TOOLTIP_VERTICAL_OFFSET])
        }
    };
    ExtMxGraph.tooltipHandler.hide = function () {
        tooltip.hide()
    };
    var drillHandler = function (sender) {
        var model = ExtMxGraph.getModel();
        var cell = ExtMxGraph.getCurrentRoot();
        var title = '';
        while (cell != null && model.getParent(model.getParent(cell)) != null) {
            if (ExtMxGraph.isValidRoot(cell)) {
                title = ' > ' + ExtMxGraph.convertValueToString(cell) + title
            }
            cell = ExtMxGraph.getModel().getParent(cell)
        }
        document.title = 'KSOA图形编辑器' + title
    };

    ExtMxGraph.getView().addListener(mxEvent.DOWN, drillHandler);
    ExtMxGraph.getView().addListener(mxEvent.UP, drillHandler);

    var undoHandler = function (sender, evt) {
        //var changes = evt.getArgAt(0).changes;
        var changes = evt.properties.edit.changes;
        ExtMxGraph.setSelectionCells(ExtMxGraph.getSelectionCellsForChanges(changes))
    };

    ExtMxHistory.addListener(mxEvent.UNDO, undoHandler);
    ExtMxHistory.addListener(mxEvent.REDO, undoHandler);
    ExtMxGraph.container.focus();

    ExtMxGraph.container.style.backgroundImage = 'url(mxgraph/examples/editors/images/grid.gif)';

    mxConnectionHandler.prototype.connectImage = new mxImage('mxgraph/examples/editors/images/connector.gif', 16, 16);
    var img = new Image();
    img.src = mxConnectionHandler.prototype.connectImage.src;

    var keyHandler = new mxKeyHandler(ExtMxGraph);
    keyHandler.enter = function () {
    };
    keyHandler.bindKey(8, function () {
        ExtMxGraph.foldCells(true)
    });
    keyHandler.bindKey(13, function () {
        ExtMxGraph.foldCells(false)
    });
    keyHandler.bindKey(33, function () {
        ExtMxGraph.exitGroup()
    });
    keyHandler.bindKey(34, function () {
        ExtMxGraph.enterGroup()
    });
    keyHandler.bindKey(36, function () {
        ExtMxGraph.home()
    });
    keyHandler.bindKey(35, function () {
        ExtMxGraph.refresh()
    });
    keyHandler.bindKey(37, function () {
        ExtMxGraph.selectPreviousCell()
    });
    keyHandler.bindKey(38, function () {
        ExtMxGraph.selectParentCell()
    });
    keyHandler.bindKey(39, function () {
        ExtMxGraph.selectNextCell()
    });
    keyHandler.bindKey(40, function () {
        ExtMxGraph.selectChildCell()
    });
    keyHandler.bindKey(46, function () {
        ExtMxGraph.removeCells()
    });
    keyHandler.bindKey(107, function () {
        ExtMxGraph.zoomIn()
    });
    keyHandler.bindKey(109, function () {
        ExtMxGraph.zoomOut()
    });
    keyHandler.bindKey(113, function () {
        ExtMxGraph.startEditingAtCell()
    });
    keyHandler.bindControlKey(65, function () {
        ExtMxGraph.selectAll()
    });
    keyHandler.bindControlKey(89, function () {
        ExtMxHistory.redo()
    });
    keyHandler.bindControlKey(90, function () {
        ExtMxHistory.undo()
    });
    keyHandler.bindControlKey(88, function () {
        mxClipboard.cut(ExtMxGraph)
    });
    keyHandler.bindControlKey(67, function () {
        mxClipboard.copy(ExtMxGraph)
    });
    keyHandler.bindControlKey(86, function () {
        mxClipboard.paste(ExtMxGraph)
    });
    keyHandler.bindControlKey(71, function () {
        ExtMxGraph.setSelectionCell(ExtMxGraph.groupCells(null, 20))
    });
    keyHandler.bindControlKey(85, function () {
        ExtMxGraph.setSelectionCells(ExtMxGraph.ungroupCells())
    })
}

mxUtils.alert = function (message) {
    //Ext.example.msg(message, '', '')
     Ext.Msg.alert('Message', message);
 };

function loadXML(graph) {
    var textareas = document.getElementsByTagName('textarea');
    var xml = textareas[0].value;
    var xmlDocument = mxUtils.parseXml(xml);
    var decoder = new mxCodec(xmlDocument);
    var node = xmlDocument.documentElement;
    decoder.decode(node, graph.getModel())
};

showProps = function (graph, showPanel, propertyPanel, pgrid) {

    if (showPanel) {
        propertyPanel.expand();
    }
    var cell = graph.getSelectionCell();

    if (cell != null) {
//        pgrid.setSource({
//            "流程节点名称": cell.getAttribute('label'),
//            "终端操作码": '1',
//            "操作提示信息": 'cc',
//            "校验算法": 'cc',
//            "加密算法": 'cc',
//            "状态": '正常'
//        });
    }

    if (cell == null) {
        cell = graph.getCurrentRoot();
        if (cell == null) {
            cell = graph.getModel().getRoot();
        }
        pgrid.setSource({
            "画布名称": cell.getAttribute('label')
        });
    }
}

function insertVertexTemplate(panel, graph, name, icon, style, width, height, value, parentNode) {

    var cell = null;
    if (value != null) {
        cell = editor.templates[value];
        if (cell == null) {
            cell = new mxCell(value, width, height, style);
        }
        cell.setStyle(style);
    } else {
        cell = new mxCell(new mxGeometry(0, 0, width, height), style);
    }
    var cells = [cell];
    cells[0].vertex = true;
    cells.width = width;
    cells.height = height;

    var funct = function (graph, evt, target) {
        cells = graph.getImportableCells(cells);
        if (cells.length > 0) {
            var validDropTarget = (target != null) ? graph.isValidDropTarget(
					target, cells, evt) : false;
            var select = null;
            if (target != null && !validDropTarget
					&& graph.getModel().getChildCount(target) == 0
					&& graph.getModel().isVertex(target) == cells[0].vertex) {
                graph.getModel().setStyle(target, style);
                select = [target]
            } else {
                if (target != null && !validDropTarget) {
                    target = null
                }
                var pt = graph.getPointForEvent(evt);
                if (graph.isSplitEnabled()
						&& graph.isSplitTarget(target, cells, evt)) {
                    graph.splitEdge(target, cells, null, pt.x, pt.y);
                    select = cells
                } else {
                    cells = graph.getImportableCells(cells);
                    if (cells.length > 0) {
                        select = graph.importCells(cells, pt.x, pt.y, target)
                    }
                }
            }
            if (select != null && select.length > 0) {
                graph.scrollCellToVisible(select[0]);
                graph.setSelectionCells(select)
            }
        }
    };
    var node = addLibraryTemplate(panel ,name, icon, parentNode, cells);
    var installDrag = function (view, record, item, index, e) {
     
        if (item) {
            var dragPreview = document.createElement('div');
            dragPreview.style.border = 'dashed black 1px';
            dragPreview.style.width = width + 'px';
            dragPreview.style.height = height + 'px';
            mxUtils.makeDraggable(item, graph, funct, dragPreview, 0,
					0, graph.autoscroll, true)
        }
    };
    if (node.parentNode.isExpanded()) {
        installDrag(node.parentNode)
    }

    return node;
}

function insertEdgeTemplate(panel, graph, name, icon, style, width, height,
		value, parentNode) {
    /*
    * var cell=null; if(value!=null){ cell=editor.templates[value];
    * if(cell==null){ cell=new mxCell(value,width,height,style); }
    * cell.setStyle(style); }else{ cell=new mxCell(new mxGeometry(0, 0,width,
    * height), style); } var cells=[cell];
    */
    var cells = [new mxCell((value != null) ? value : '', new mxGeometry(0, 0,width, height), style)];
    cells[0].geometry.setTerminalPoint(new mxPoint(0, height), true);
    cells[0].geometry.setTerminalPoint(new mxPoint(width, 0), false);
    cells[0].edge = true;
    cells.width = width;
    cells.height = height;

    var funct = function (graph, evt, target) {
        cells = graph.getImportableCells(cells);
        if (cells.length > 0) {
            var validDropTarget = (target != null) ? graph.isValidDropTarget(target, cells, evt) : false;
            var select = null;
            if (target != null && !validDropTarget) {
                target = null
            }
            var pt = graph.getPointForEvent(evt);
            var scale = graph.view.scale;
            pt.x -= graph.snap(width / 2);
            pt.y -= graph.snap(height / 2);
            select = graph.importCells(cells, pt.x, pt.y, target);
            GraphEditor.edgeTemplate = select[0];
            graph.scrollCellToVisible(select[0]);
            graph.setSelectionCells(select)
        }
    };
    var node = addLibraryTemplate(panel, name, icon, parentNode, cells);
    var installDrag = function (expandedNode) {
        if (node.ui.elNode != null) {
            var dragPreview = document.createElement('div');
            dragPreview.style.border = 'dashed black 1px';
            dragPreview.style.width = width + 'px';
            dragPreview.style.height = height + 'px';
            mxUtils.makeDraggable(node.ui.elNode, graph, funct, dragPreview,
					-width / 2, -height / 2, graph.autoscroll, true)
        }
    };
    if (node.parentNode.isExpanded()) {
            installDrag(node.parentNode)
    }
    return node
};

var addLibraryTemplate = function (library, name, icon, parentNode, cells) {

    var exists = library.getStore().getNodeById(name);
    if (exists) {
        if (!inactive) {
            exists.select();
            exists.ui.highlight()
        }
        return
    }
    var node = {
        text: name,
        icon: icon,
        leaf: true,
        cls: 'feed',
        cells: cells,
        id: name
    };
    if (parentNode == null) {
        parentNode = library.getStore().getNodeById("0")
    }
    parentNode.appendChild(node);

    var result = library.getStore().getNodeById(name);

    if (result) {
        result.cells = cells;
    }

    return result;
}

var nodeDragGraph = function (item, record, node, index, e) {

    if (record.cells) {
        var funct = function (graph, evt, target) {
            cells = graph.getImportableCells(record.cells);

            if (cells.length > 0) {
                if (cells[0].edge) {
                    var validDropTarget = (target != null) ? graph.isValidDropTarget(target, cells, evt) : false;
                    var select = null;
                    if (target != null && !validDropTarget) {
                        target = null
                    }
                    var pt = graph.getPointForEvent(evt);
                    var scale = graph.view.scale;
                    pt.x -= graph.snap(record.cells.width / 2);
                    pt.y -= graph.snap(record.cells.height / 2);
                    select = graph.importCells(cells, pt.x, pt.y, target);
                    GraphEditor.edgeTemplate = select[0];
                    graph.scrollCellToVisible(select[0]);
                    graph.setSelectionCells(select)

                }
                else if (cells[0].vertex) {
                    var validDropTarget = (target != null) ? graph.isValidDropTarget(target, cells, evt) : false;
                    var select = null;
                    if (target != null && !validDropTarget
					&& graph.getModel().getChildCount(target) == 0
					&& graph.getModel().isVertex(target) == cells[0].vertex) {
                        graph.getModel().setStyle(target, style);
                        select = [target]
                    } else {
                        if (target != null && !validDropTarget) {
                            target = null
                        }
                        var pt = graph.getPointForEvent(evt);
                        if (graph.isSplitEnabled()
						&& graph.isSplitTarget(target, cells, evt)) {
                            graph.splitEdge(target, cells, null, pt.x, pt.y);
                            select = cells
                        } else {
                            cells = graph.getImportableCells(cells);
                            if (cells.length > 0) {
                                select = graph.importCells(cells, pt.x, pt.y, target)
                            }
                        }
                    }
                    if (select != null && select.length > 0) {
                        graph.scrollCellToVisible(select[0]);
                        graph.setSelectionCells(select)
                    }
                }
            }
        };

        var dragPreview = document.createElement('div');
        dragPreview.style.border = 'dashed black 1px';
        dragPreview.style.width = record.cells.width + 'px';
        dragPreview.style.height = record.cells.height + 'px';
        mxUtils.makeDraggable(node, ExtMxGraph, funct, dragPreview, -record.cells.width / 2, -record.cells.height / 2, ExtMxGraph.autoscroll, true)
    }
}