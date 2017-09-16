MainPanel = function(graph, history) {
	var executeLayout = function(layout, animate, ignoreChildCount) {
		var cell = graph.getSelectionCell();
		if (cell == null
				|| (!ignoreChildCount && graph.getModel().getChildCount(cell) == 0)) {
			cell = graph.getDefaultParent()
		}
		if (animate && navigator.userAgent.indexOf('Camino') < 0) {
			var listener = function(sender, evt) {
				mxUtils.animateChanges(graph, evt.getArgAt(0));
				graph.getModel().removeListener(listener)
			};
			graph.getModel().addListener(mxEvent.CHANGE, listener)
		}
		layout.execute(cell)
	};
	var fillColorMenu = new Ext.menu.ColorMenu({
				items : [{
					text : '无',
					handler : function() {
						graph.setCellStyles(mxConstants.STYLE_FILLCOLOR,
								mxConstants.NONE)
					}
				}, '-'],
				handler : function(cm, color) {
					if (typeof(color) == "string") {
						graph.setCellStyles(mxConstants.STYLE_FILLCOLOR, '#'
										+ color)
					}
				}
			});
	var gradientColorMenu = new Ext.menu.ColorMenu({
				items : [{
					text : '上',
					handler : function() {
						graph.setCellStyles(
								mxConstants.STYLE_GRADIENT_DIRECTION,
								mxConstants.DIRECTION_NORTH)
					}
				}, {
					text : '下',
					handler : function() {
						graph.setCellStyles(
								mxConstants.STYLE_GRADIENT_DIRECTION,
								mxConstants.DIRECTION_SOUTH)
					}
				}, {
					text : '左',
					handler : function() {
						graph.setCellStyles(
								mxConstants.STYLE_GRADIENT_DIRECTION,
								mxConstants.DIRECTION_WEST)
					}
				}, {
					text : '右',
					handler : function() {
						graph.setCellStyles(
								mxConstants.STYLE_GRADIENT_DIRECTION,
								mxConstants.DIRECTION_EAST)
					}
				}, '-', {
					text : '无',
					handler : function() {
						graph.setCellStyles(mxConstants.STYLE_GRADIENTCOLOR,
								mxConstants.NONE)
					}
				}, '-'],
				handler : function(cm, color) {
					if (typeof(color) == "string") {
						graph.setCellStyles(mxConstants.STYLE_GRADIENTCOLOR,
								'#' + color)
					}
				}
			});
	var fontColorMenu = new Ext.menu.ColorMenu({
				items : [{
					text : '无',
					handler : function() {
						graph.setCellStyles(mxConstants.STYLE_FONTCOLOR,
								mxConstants.NONE)
					}
				}, '-'],
				handler : function(cm, color) {
					if (typeof(color) == "string") {
						graph.setCellStyles(mxConstants.STYLE_FONTCOLOR, '#'
										+ color)
					}
				}
			});
	var lineColorMenu = new Ext.menu.ColorMenu({
				items : [{
					text : '无',
					handler : function() {
						graph.setCellStyles(mxConstants.STYLE_STROKECOLOR,
								mxConstants.NONE)
					}
				}, '-'],
				handler : function(cm, color) {
					if (typeof(color) == "string") {
						graph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#'
										+ color)
					}
				}
			});
	var labelBackgroundMenu = new Ext.menu.ColorMenu({
				items : [{
					text : '无',
					handler : function() {
						graph.setCellStyles(
								mxConstants.STYLE_LABEL_BACKGROUNDCOLOR,
								mxConstants.NONE)
					}
				}, '-'],
				handler : function(cm, color) {
					if (typeof(color) == "string") {
						graph.setCellStyles(
								mxConstants.STYLE_LABEL_BACKGROUNDCOLOR, '#'
										+ color)
					}
				}
			});
	var labelBorderMenu = new Ext.menu.ColorMenu({
				items : [{
					text : '无',
					handler : function() {
						graph.setCellStyles(
								mxConstants.STYLE_LABEL_BORDERCOLOR,
								mxConstants.NONE)
					}
				}, '-'],
				handler : function(cm, color) {
					if (typeof(color) == "string") {
						graph.setCellStyles(
								mxConstants.STYLE_LABEL_BORDERCOLOR, '#'
										+ color)
					}
				}
			});
	var fonts = new Ext.data.SimpleStore({
				fields : ['label', 'font'],
				data : [['宋体', '宋体'], ['黑体', '黑体'], ['Helvetica', 'Helvetica'],
						['Verdana', 'Verdana'],
						['Times New Roman', 'Times New Roman'],
						['Garamond', 'Garamond'],
						['Courier New', 'Courier New']]
			});
	var fontCombo = new Ext.form.ComboBox({
				store : fonts,
				displayField : 'label',
				mode : 'local',
				width : 120,
				triggerAction : 'all',
				emptyText : '请选择字体',
				selectOnFocus : true,
				onSelect : function(entry) {
					if (entry != null) {
						graph.setCellStyles(mxConstants.STYLE_FONTFAMILY,
								entry.data.font);
						this.collapse()
					}
				}
			});
	fontCombo.on('specialkey', function(field, evt) {
				if (evt.keyCode == 10 || evt.keyCode == 13) {
					var family = field.getValue();
					if (family != null && family.length > 0) {
						graph.setCellStyles(mxConstants.STYLE_FONTFAMILY,
								family)
					}
				}
			});
	var sizes = new Ext.data.SimpleStore({
				fields : ['label', 'size'],
				data : [['6pt', 6], ['8pt', 8], ['9pt', 9], ['10pt', 10],
						['12pt', 12], ['14pt', 14], ['18pt', 18], ['24pt', 24],
						['30pt', 30], ['36pt', 36], ['48pt', 48], ['60pt', 60]]
			});
	var sizeCombo = new Ext.form.ComboBox({
				store : sizes,
				displayField : 'label',
				mode : 'local',
				width : 50,
				triggerAction : 'all',
				emptyText : '12pt',
				selectOnFocus : true,
				onSelect : function(entry) {
					if (entry != null) {
						graph.setCellStyles(mxConstants.STYLE_FONTSIZE,
								entry.data.size);
						this.collapse()
					}
				}
			});
	sizeCombo.on('specialkey', function(field, evt) {
				if (evt.keyCode == 10 || evt.keyCode == 13) {
					var size = parseInt(field.getValue());
					if (!isNaN(size) && size > 0) {
						graph.setCellStyles(mxConstants.STYLE_FONTSIZE, size)
					}
				}
			});
	this.graphPanel = new Ext.Panel({
		region : 'center',
		border : false,
		tbar : [{
					id : 'view',
					text : '',
					iconCls : 'preview-icon',
					tooltip : '预览',
					handler : function() {
						mxUtils.show(graph)
					},
					scope : this
				}, '-', {
					id : 'cut',
					text : '',
					iconCls : 'cut-icon',
					tooltip : '剪切',
					handler : function() {
						mxClipboard.cut(graph)
					},
					scope : this
				}, {
					id : 'copy',
					text : '',
					iconCls : 'copy-icon',
					tooltip : '复制',
					handler : function() {
						mxClipboard.copy(graph)
					},
					scope : this
				}, {
					text : '',
					iconCls : 'paste-icon',
					tooltip : '粘贴',
					handler : function() {
						mxClipboard.paste(graph)
					},
					scope : this
				}, '-', {
					id : 'delete',
					text : '',
					iconCls : 'delete-icon',
					tooltip : '删除',
					handler : function() {
						graph.removeCells()
					},
					scope : this
				}, '-', {
					id : 'undo',
					text : '',
					iconCls : 'undo-icon',
					tooltip : '撤销',
					handler : function() {
						history.undo()
					},
					scope : this
				}, {
					id : 'redo',
					text : '',
					iconCls : 'redo-icon',
					tooltip : '恢复',
					handler : function() {
						history.redo()
					},
					scope : this
				}, '-', fontCombo, ' ', sizeCombo, '-', {
					id : 'bold',
					text : '',
					iconCls : 'bold-icon',
					tooltip : '粗体',
					handler : function() {
						graph.toggleCellStyleFlags(mxConstants.STYLE_FONTSTYLE,
								mxConstants.FONT_BOLD)
					},
					scope : this
				}, {
					id : 'italic',
					text : '',
					tooltip : '斜体',
					iconCls : 'italic-icon',
					handler : function() {
						graph.toggleCellStyleFlags(mxConstants.STYLE_FONTSTYLE,
								mxConstants.FONT_ITALIC)
					},
					scope : this
				}, {
					id : 'underline',
					text : '',
					tooltip : '下滑线',
					iconCls : 'underline-icon',
					handler : function() {
						graph.toggleCellStyleFlags(mxConstants.STYLE_FONTSTYLE,
								mxConstants.FONT_UNDERLINE)
					},
					scope : this
				}, '-', {
					id : 'align',
					text : '',
					iconCls : 'left-icon',
					tooltip : '文字排版',
					handler : function() {
					},
					menu : {
						id : 'reading-menu',
						cls : 'reading-menu',
						items : [{
							text : '居左',
							checked : false,
							group : 'rp-group',
							scope : this,
							iconCls : 'left-icon',
							handler : function() {
								graph.setCellStyles(mxConstants.STYLE_ALIGN,
										mxConstants.ALIGN_LEFT)
							}
						}, {
							text : '居中',
							checked : true,
							group : 'rp-group',
							scope : this,
							iconCls : 'center-icon',
							handler : function() {
								graph.setCellStyles(mxConstants.STYLE_ALIGN,
										mxConstants.ALIGN_CENTER)
							}
						}, {
							text : '居右',
							checked : false,
							group : 'rp-group',
							scope : this,
							iconCls : 'right-icon',
							handler : function() {
								graph.setCellStyles(mxConstants.STYLE_ALIGN,
										mxConstants.ALIGN_RIGHT)
							}
						}, '-', {
							text : '置顶',
							checked : false,
							group : 'vrp-group',
							scope : this,
							iconCls : 'top-icon',
							handler : function() {
								graph.setCellStyles(
										mxConstants.STYLE_VERTICAL_ALIGN,
										mxConstants.ALIGN_TOP)
							}
						}, {
							text : '垂直居中',
							checked : true,
							group : 'vrp-group',
							scope : this,
							iconCls : 'middle-icon',
							handler : function() {
								graph.setCellStyles(
										mxConstants.STYLE_VERTICAL_ALIGN,
										mxConstants.ALIGN_MIDDLE)
							}
						}, {
							text : '置底',
							checked : false,
							group : 'vrp-group',
							scope : this,
							iconCls : 'bottom-icon',
							handler : function() {
								graph.setCellStyles(
										mxConstants.STYLE_VERTICAL_ALIGN,
										mxConstants.ALIGN_BOTTOM)
							}
						}]
					}
				}, '-', {
					id : 'fontcolor',
					text : '',
					tooltip : '字体颜色',
					iconCls : 'fontcolor-icon',
					menu : fontColorMenu
				}, {
					id : 'linecolor',
					text : '',
					tooltip : '线颜色',
					iconCls : 'linecolor-icon',
					menu : lineColorMenu
				}, {
					id : 'fillcolor',
					text : '',
					tooltip : '填充颜色',
					iconCls : 'fillcolor-icon',
					menu : fillColorMenu
				}, '->', {
					text : '大小',
					iconCls : 'zoom-icon',
					handler : function(menu) {
					},
					menu : {
						items : [{
							text : '自定义',
							scope : this,
							handler : function(item) {
								var value = mxUtils.prompt(
										'Enter Source Spacing (像素)',
										parseInt(graph.getView().getScale()
												* 100));
								if (value != null) {
									graph.getView().setScale(parseInt(value)
											/ 100)
								}
							}
						}, '-', {
							text : '400%',
							scope : this,
							handler : function(item) {
								graph.getView().setScale(4)
							}
						}, {
							text : '200%',
							scope : this,
							handler : function(item) {
								graph.getView().setScale(2)
							}
						}, {
							text : '150%',
							scope : this,
							handler : function(item) {
								graph.getView().setScale(1.5)
							}
						}, {
							text : '100%',
							scope : this,
							handler : function(item) {
								graph.getView().setScale(1)
							}
						}, {
							text : '75%',
							scope : this,
							handler : function(item) {
								graph.getView().setScale(0.75)
							}
						}, {
							text : '50%',
							scope : this,
							handler : function(item) {
								graph.getView().setScale(0.5)
							}
						}, {
							text : '25%',
							scope : this,
							handler : function(item) {
								graph.getView().setScale(0.25)
							}
						}, '-', {
							text : '放大',
							scope : this,
							handler : function(item) {
								graph.zoomIn()
							}
						}, {
							text : '缩小',
							scope : this,
							handler : function(item) {
								graph.zoomOut()
							}
						}, '-', {
							text : '实际大小',
							scope : this,
							handler : function(item) {
								graph.zoomActual()
							}
						}, {
							text : '自适应窗口',
							scope : this,
							handler : function(item) {
								graph.fit()
							}
						}]
					}
				}, '-', {
					text : '布局',
					iconCls : 'diagram-icon',
					handler : function(menu) {
					},
					menu : {
						items : [{
							text : '垂直层次布局',
							scope : this,
							handler : function(item) {
								executeLayout(new mxHierarchicalLayout(graph),
										true)
							}
						}, {
							text : '水平层次布局',
							scope : this,
							handler : function(item) {
								executeLayout(new mxHierarchicalLayout(graph,
												mxConstants.DIRECTION_WEST),
										true)
							}
						}, '-', {
							text : '平行排列连线',
							scope : this,
							handler : function(item) {
								executeLayout(new mxParallelEdgeLayout(graph))
							}
						}, '-', {
							text : '环形布局',
							scope : this,
							handler : function(item) {
								executeLayout(new mxCircleLayout(graph), true)
							}
						}, {
							text : '有机布局',
							scope : this,
							handler : function(item) {
								var layout = new mxFastOrganicLayout(graph);
								layout.forceConstant = 80;
								executeLayout(layout, true)
							}
						}]
					}
				}, '-', {
					text : '选项',
					iconCls : 'preferences-icon',
					handler : function(menu) {
					},
					menu : {
						items : [{
							text : '网格',
							handler : function(menu) {
							},
							menu : {
								items : [{
									text : '网格大小',
									scope : this,
									handler : function() {
										var value = mxUtils.prompt(
												'Enter Grid Size (像素)',
												graph.gridSize);
										if (value != null) {
											graph.gridSize = value
										}
									}
								}, {
									checked : true,
									text : '启动网格',
									scope : this,
									checkHandler : function(item, checked) {
										graph.setGridEnabled(checked)
										graph.container.style.backgroundImage = (graph
												.isGridEnabled())
												? 'url(images/body_bg.jpg)'
												: 'none';
									}
								}]
							}
						}, {
							text : '标签',
							handler : function(menu) {
							},
							menu : {
								items : [{
											checked : true,
											text : '显示标签',
											scope : this,
											checkHandler : function(item,
													checked) {
												graph.labelsVisible = checked;
												graph.refresh()
											}
										}, {
											checked : true,
											text : '允许移动连线标签',
											scope : this,
											checkHandler : function(item,
													checked) {
												graph.edgeLabelsMovable = checked
											}
										}, {
											checked : false,
											text : '允许移动图形标签',
											scope : this,
											checkHandler : function(item,
													checked) {
												graph.vertexLabelsMovable = checked
											}
										}]
							}
						}, '-', {
							text : '连接线',
							handler : function(menu) {
							},
							menu : {
								items : [{
											checked : true,
											text : '自动连接线',
											scope : this,
											checkHandler : function(item,
													checked) {
												graph.setConnectable(checked)
											}
										}, '-', {
											checked : true,
											text : '自动创建目标图形',
											scope : this,
											checkHandler : function(item,
													checked) {
												graph.connectionHandler
														.setCreateTarget(checked)
											}
										}]
							}
						}, {
							text : '图形规则',
							handler : function(menu) {
							},
							menu : {
								items : [{
											checked : true,
											text : '允许悬空连接',
											scope : this,
											checkHandler : function(item,
													checked) {
												graph
														.setAllowDanglingEdges(checked)
											}
										}, '-', {
											checked : false,
											text : '允许自连',
											scope : this,
											checkHandler : function(item,
													checked) {
												graph.setAllowLoops(checked)
											}
										}]
							}
						}, '-', {
							text : '显示 XML',
							scope : this,
							handler : function(item) {
								var enc = new mxCodec(mxUtils
										.createXmlDocument());
								var node = enc.encode(graph.getModel());
								mxUtils.popup(mxUtils.getPrettyXml(node))
							}
						}]
					}
				}],
		onContextMenu : function(node, e) {
			var selected = !graph.isSelectionEmpty();
			this.menu = new Ext.menu.Menu({
				id : 'feeds-ctx',
				items : [{
							text : '撤销',
							iconCls : 'undo-icon',
							disabled : !history.canUndo(),
							scope : this,
							handler : function() {
								history.undo()
							}
						}, '-', {
							text : '剪切',
							iconCls : 'cut-icon',
							disabled : !selected,
							scope : this,
							handler : function() {
								mxClipboard.cut(graph)
							}
						}, {
							text : '复制',
							iconCls : 'copy-icon',
							disabled : !selected,
							scope : this,
							handler : function() {
								mxClipboard.copy(graph)
							}
						}, {
							text : '粘贴',
							iconCls : 'paste-icon',
							disabled : mxClipboard.isEmpty(),
							scope : this,
							handler : function() {
								mxClipboard.paste(graph)
							}
						}, '-', {
							text : '删除',
							iconCls : 'delete-icon',
							disabled : !selected,
							scope : this,
							handler : function() {
								graph.removeCells()
							}
						}, '-', {
							text : '样式',
							disabled : !selected,
							handler : function() {
							},
							menu : {
								items : [{
									text : '背景',
									disabled : !selected,
									handler : function() {
									},
									menu : {
										items : [{
													text : '颜色填充',
													iconCls : 'fillcolor-icon',
													menu : fillColorMenu
												}, {
													text : '过渡',
													menu : gradientColorMenu
												}, '-', {
													text : '图片',
													handler : function() {
														var value = '';
														var state = graph
																.getView()
																.getState(graph
																		.getSelectionCell());
														if (state != null) {
															value = state.style[mxConstants.STYLE_IMAGE]
																	|| value
														}
														value = mxUtils
																.prompt(
																		'Enter Image URL',
																		value);
														if (value != null) {
															graph
																	.setCellStyles(
																			mxConstants.STYLE_IMAGE,
																			value)
														}
													}
												}, {
													text : '阴影',
													scope : this,
													handler : function() {
														graph
																.toggleCellStyles(mxConstants.STYLE_SHADOW)
													}
												}, '-', {
													text : '透明',
													scope : this,
													handler : function() {
														var value = mxUtils
																.prompt(
																		'Enter Opacity (0-100%)',
																		'100');
														if (value != null) {
															graph
																	.setCellStyles(
																			mxConstants.STYLE_OPACITY,
																			value)
														}
													}
												}]
									}
								}, {
									text : '标签',
									disabled : !selected,
									handler : function() {
									},
									menu : {
										items : [{
													text : '字体颜色',
													iconCls : 'fontcolor-icon',
													menu : fontColorMenu
												}, '-', {
													text : '填充颜色',
													menu : labelBackgroundMenu
												}, {
													text : '边颜色',
													menu : labelBorderMenu
												}, '-', {
													text : '旋转标签',
													scope : this,
													handler : function() {
														graph
																.toggleCellStyles(
																		mxConstants.STYLE_HORIZONTAL,
																		true)
													}
												}, {
													text : '字体透明度',
													scope : this,
													handler : function() {
														var value = mxUtils
																.prompt(
																		'Enter text opacity (0-100%)',
																		'100');
														if (value != null) {
															graph
																	.setCellStyles(
																			mxConstants.STYLE_TEXT_OPACITY,
																			value)
														}
													}
												}, '-', {
													text : '位置',
													disabled : !selected,
													handler : function() {
													},
													menu : {
														items : [{
															text : '顶部',
															scope : this,
															handler : function() {
																graph
																		.setCellStyles(
																				mxConstants.STYLE_VERTICAL_LABEL_POSITION,
																				mxConstants.ALIGN_TOP);
																graph
																		.setCellStyles(
																				mxConstants.STYLE_VERTICAL_ALIGN,
																				mxConstants.ALIGN_BOTTOM)
															}
														}, {
															text : '中部',
															scope : this,
															handler : function() {
																graph
																		.setCellStyles(
																				mxConstants.STYLE_VERTICAL_LABEL_POSITION,
																				mxConstants.ALIGN_MIDDLE);
																graph
																		.setCellStyles(
																				mxConstants.STYLE_VERTICAL_ALIGN,
																				mxConstants.ALIGN_MIDDLE)
															}
														}, {
															text : '底部',
															scope : this,
															handler : function() {
																graph
																		.setCellStyles(
																				mxConstants.STYLE_VERTICAL_LABEL_POSITION,
																				mxConstants.ALIGN_BOTTOM);
																graph
																		.setCellStyles(
																				mxConstants.STYLE_VERTICAL_ALIGN,
																				mxConstants.ALIGN_TOP)
															}
														}, '-', {
															text : '居右',
															scope : this,
															handler : function() {
																graph
																		.setCellStyles(
																				mxConstants.STYLE_LABEL_POSITION,
																				mxConstants.ALIGN_LEFT);
																graph
																		.setCellStyles(
																				mxConstants.STYLE_ALIGN,
																				mxConstants.ALIGN_RIGHT)
															}
														}, {
															text : '居中',
															scope : this,
															handler : function() {
																graph
																		.setCellStyles(
																				mxConstants.STYLE_LABEL_POSITION,
																				mxConstants.ALIGN_CENTER);
																graph
																		.setCellStyles(
																				mxConstants.STYLE_ALIGN,
																				mxConstants.ALIGN_CENTER)
															}
														}, {
															text : '居右',
															scope : this,
															handler : function() {
																graph
																		.setCellStyles(
																				mxConstants.STYLE_LABEL_POSITION,
																				mxConstants.ALIGN_RIGHT);
																graph
																		.setCellStyles(
																				mxConstants.STYLE_ALIGN,
																				mxConstants.ALIGN_LEFT)
															}
														}]
													}
												}, '-', {
													text : '隐藏',
													scope : this,
													handler : function() {
														graph
																.toggleCellStyles(
																		mxConstants.STYLE_NOLABEL,
																		false)
													}
												}]
									}
								}, '-', {
									text : '连线',
									disabled : !selected,
									handler : function() {
									},
									menu : {
										items : [{
													text : '颜色',
													iconCls : 'linecolor-icon',
													menu : lineColorMenu
												}, '-', {
													text : '虚线',
													scope : this,
													handler : function() {
														graph
																.toggleCellStyles(mxConstants.STYLE_DASHED)
													}
												}, {
													text : '宽度',
													handler : function() {
														var value = '0';
														var state = graph
																.getView()
																.getState(graph
																		.getSelectionCell());
														if (state != null) {
															value = state.style[mxConstants.STYLE_STROKEWIDTH]
																	|| 1
														}
														value = mxUtils.prompt(
																'请输入宽度 (像素)',
																value);
														if (value != null) {
															graph
																	.setCellStyles(
																			mxConstants.STYLE_STROKEWIDTH,
																			value)
														}
													}
												}]
									}
								}, {
									text : '连接器',
									menu : {
										items : [{
													text : '直线',
													icon : 'images/straight.gif',
													handler : function() {
														graph
																.setCellStyle('straight')
													}
												}, '-', {
													text : '水平线',
													icon : 'images/connect.gif',
													handler : function() {
														graph
																.setCellStyle(null)
													}
												}, {
													text : '垂直线',
													icon : 'images/vertical.gif',
													handler : function() {
														graph
																.setCellStyle('vertical')
													}
												}, '-', {
													text : '实体关系',
													icon : 'images/entity.gif',
													handler : function() {
														graph
																.setCellStyle('edgeStyle=mxEdgeStyle.EntityRelation')
													}
												}, {
													text : '箭头',
													icon : 'images/arrow.gif',
													handler : function() {
														graph
																.setCellStyle('arrow')
													}
												}, '-', {
													text : '面板',
													handler : function() {
														graph
																.toggleCellStyles(
																		mxConstants.STYLE_NOEDGESTYLE,
																		false)
													}
												}]
									}
								}, '-', {
									text : '开始点',
									menu : {
										items : [{
											text : '普通',
											icon : 'images/open_start.gif',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_STARTARROW,
																mxConstants.ARROW_OPEN)
											}
										}, {
											text : '经典',
											icon : 'images/classic_start.gif',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_STARTARROW,
																mxConstants.ARROW_CLASSIC)
											}
										}, {
											text : '加粗',
											icon : 'images/block_start.gif',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_STARTARROW,
																mxConstants.ARROW_BLOCK)
											}
										}, '-', {
											text : '菱形',
											icon : 'images/diamond_start.gif',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_STARTARROW,
																mxConstants.ARROW_DIAMOND)
											}
										}, {
											text : '圆形',
											icon : 'images/oval_start.gif',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_STARTARROW,
																mxConstants.ARROW_OVAL)
											}
										}, '-', {
											text : '无',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_STARTARROW,
																mxConstants.NONE)
											}
										}, {
											text : '大小',
											handler : function() {
												var size = mxUtils
														.prompt(
																'输入大小',
																mxConstants.DEFAULT_MARKERSIZE);
												if (size != null) {
													graph
															.setCellStyles(
																	mxConstants.STYLE_STARTSIZE,
																	size)
												}
											}
										}]
									}
								}, {
									text : '结束点',
									menu : {
										items : [{
											text : '普通',
											icon : 'images/open_end.gif',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_ENDARROW,
																mxConstants.ARROW_OPEN)
											}
										}, {
											text : '经典',
											icon : 'images/classic_end.gif',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_ENDARROW,
																mxConstants.ARROW_CLASSIC)
											}
										}, {
											text : '加粗',
											icon : 'images/block_end.gif',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_ENDARROW,
																mxConstants.ARROW_BLOCK)
											}
										}, '-', {
											text : '菱形',
											icon : 'images/diamond_end.gif',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_ENDARROW,
																mxConstants.ARROW_DIAMOND)
											}
										}, {
											text : '圆形',
											icon : 'images/oval_end.gif',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_ENDARROW,
																mxConstants.ARROW_OVAL)
											}
										}, '-', {
											text : '无',
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_ENDARROW,
																'none')
											}
										}, {
											text : '大小',
											handler : function() {
												var size = mxUtils
														.prompt(
																'请输入大小',
																mxConstants.DEFAULT_MARKERSIZE);
												if (size != null) {
													graph
															.setCellStyles(
																	mxConstants.STYLE_ENDSIZE,
																	size)
												}
											}
										}]
									}
								}, '-', {
									text : '间隔',
									menu : {
										items : [{
											text : '顶部',
											handler : function() {
												var value = '0';
												var state = graph
														.getView()
														.getState(graph
																.getSelectionCell());
												if (state != null) {
													value = state.style[mxConstants.STYLE_SPACING_TOP]
															|| value
												}
												value = mxUtils.prompt(
														'输入顶部间隔 (像素)', value);
												if (value != null) {
													graph
															.setCellStyles(
																	mxConstants.STYLE_SPACING_TOP,
																	value)
												}
											}
										}, {
											text : '右侧',
											handler : function() {
												var value = '0';
												var state = graph
														.getView()
														.getState(graph
																.getSelectionCell());
												if (state != null) {
													value = state.style[mxConstants.STYLE_SPACING_RIGHT]
															|| value
												}
												value = mxUtils.prompt(
														'输入右侧间隔 (像素)', value);
												if (value != null) {
													graph
															.setCellStyles(
																	mxConstants.STYLE_SPACING_RIGHT,
																	value)
												}
											}
										}, {
											text : '底部',
											handler : function() {
												var value = '0';
												var state = graph
														.getView()
														.getState(graph
																.getSelectionCell());
												if (state != null) {
													value = state.style[mxConstants.STYLE_SPACING_BOTTOM]
															|| value
												}
												value = mxUtils.prompt(
														'输入底部间隔 (像素)', value);
												if (value != null) {
													graph
															.setCellStyles(
																	mxConstants.STYLE_SPACING_BOTTOM,
																	value)
												}
											}
										}, {
											text : '左侧',
											handler : function() {
												var value = '0';
												var state = graph
														.getView()
														.getState(graph
																.getSelectionCell());
												if (state != null) {
													value = state.style[mxConstants.STYLE_SPACING_LEFT]
															|| value
												}
												value = mxUtils.prompt(
														'输入左侧间隔 (像素)', value);
												if (value != null) {
													graph
															.setCellStyles(
																	mxConstants.STYLE_SPACING_LEFT,
																	value)
												}
											}
										}, '-', {
											text : '整体',
											handler : function() {
												var value = '0';
												var state = graph
														.getView()
														.getState(graph
																.getSelectionCell());
												if (state != null) {
													value = state.style[mxConstants.STYLE_SPACING]
															|| value
												}
												value = mxUtils.prompt(
														'输入间隔 (像素)', value);
												if (value != null) {
													graph
															.setCellStyles(
																	mxConstants.STYLE_SPACING,
																	value)
												}
											}
										}, '-', {
											text : '源间隔',
											handler : function() {
												var value = '0';
												var state = graph
														.getView()
														.getState(graph
																.getSelectionCell());
												if (state != null) {
													value = state.style[mxConstants.STYLE_SOURCE_PERIMETER_SPACING]
															|| value
												}
												value = mxUtils.prompt(
														'输入源间隔 (像素)', value);
												if (value != null) {
													graph
															.setCellStyles(
																	mxConstants.STYLE_SOURCE_PERIMETER_SPACING,
																	value)
												}
											}
										}, {
											text : '目标间隔',
											handler : function() {
												var value = '0';
												var state = graph
														.getView()
														.getState(graph
																.getSelectionCell());
												if (state != null) {
													value = state.style[mxConstants.STYLE_TARGET_PERIMETER_SPACING]
															|| value
												}
												value = mxUtils.prompt(
														'输入目标间隔 (像素)', value);
												if (value != null) {
													graph
															.setCellStyles(
																	mxConstants.STYLE_TARGET_PERIMETER_SPACING,
																	value)
												}
											}
										}, '-', {
											text : '边缘间隔',
											handler : function() {
												var value = '0';
												var state = graph
														.getView()
														.getState(graph
																.getSelectionCell());
												if (state != null) {
													value = state.style[mxConstants.STYLE_PERIMETER_SPACING]
															|| value
												}
												value = mxUtils.prompt(
														'输入边缘间隔 (像素)', value);
												if (value != null) {
													graph
															.setCellStyles(
																	mxConstants.STYLE_PERIMETER_SPACING,
																	value)
												}
											}
										}]
									}
								}, {
									text : '方向',
									menu : {
										items : [{
											text : '上',
											scope : this,
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_DIRECTION,
																mxConstants.DIRECTION_NORTH)
											}
										}, {
											text : '下',
											scope : this,
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_DIRECTION,
																mxConstants.DIRECTION_SOUTH)
											}
										}, {
											text : '左',
											scope : this,
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_DIRECTION,
																mxConstants.DIRECTION_WEST)
											}
										}, {
											text : '右',
											scope : this,
											handler : function() {
												graph
														.setCellStyles(
																mxConstants.STYLE_DIRECTION,
																mxConstants.DIRECTION_EAST)
											}
										}, '-', {
											text : '转动角度',
											scope : this,
											handler : function() {
												var value = '0';
												var state = graph
														.getView()
														.getState(graph
																.getSelectionCell());
												if (state != null) {
													value = state.style[mxConstants.STYLE_ROTATION]
															|| value
												}
												value = mxUtils.prompt(
														'输入角度 (0-360)', value);
												if (value != null) {
													graph
															.setCellStyles(
																	mxConstants.STYLE_ROTATION,
																	value)
												}
											}
										}]
									}
								}, '-', {
									text : '平滑',
									scope : this,
									handler : function() {
										graph
												.toggleCellStyles(mxConstants.STYLE_ROUNDED)
									}
								}, {
									text : '样式',
									scope : this,
									handler : function() {
										var cells = graph.getSelectionCells();
										if (cells != null && cells.length > 0) {
											var model = graph.getModel();
											var style = mxUtils.prompt('输入样式',
													model.getStyle(cells[0])
															|| '');
											if (style != null) {
												graph
														.setCellStyle(style,
																cells)
											}
										}
									}
								}]
							}
						}, {
							split : true,
							text : '形状',
							handler : function() {
							},
							menu : {
								items : [{
											text : '根节点',
											iconCls : 'home-icon',
											disabled : graph.view.currentRoot == null,
											scope : this,
											handler : function() {
												graph.home()
											}
										}, '-', {
											text : '上一组层次',
											iconCls : 'up-icon',
											disabled : graph.view.currentRoot == null,
											scope : this,
											handler : function() {
												graph.exitGroup()
											}
										}, {
											text : '下一组层次',
											iconCls : 'down-icon',
											disabled : !selected,
											scope : this,
											handler : function() {
												graph.enterGroup()
											}
										}, '-', {
											text : '组合',
											icon : 'images/group.gif',
											disabled : graph
													.getSelectionCount() <= 1,
											scope : this,
											handler : function() {
												graph.setSelectionCell(graph
														.groupCells(null, 20))
											}
										}, {
											text : '拆分',
											icon : 'images/ungroup.gif',
											scope : this,
											handler : function() {
												graph.setSelectionCells(graph
														.ungroupCells())
											}
										}, '-', {
											text : '从组中移除',
											scope : this,
											handler : function() {
												graph.removeCellsFromParent()
											}
										}, '-', {
											text : '收起',
											iconCls : 'collapse-icon',
											disabled : !selected,
											scope : this,
											handler : function() {
												graph.foldCells(true)
											}
										}, {
											text : '展开',
											iconCls : 'expand-icon',
											disabled : !selected,
											scope : this,
											handler : function() {
												graph.foldCells(false)
											}
										}, '-', {
											text : '后退',
											icon : 'images/toback.gif',
											scope : this,
											handler : function() {
												graph.orderCells(true)
											}
										}, {
											text : '前进',
											icon : 'images/tofront.gif',
											scope : this,
											handler : function() {
												graph.orderCells(false)
											}
										}, '-', {
											text : '排版',
											menu : {
												items : [{
													text : '居左',
													icon : 'images/alignleft.gif',
													handler : function() {
														graph
																.alignCells(mxConstants.ALIGN_LEFT)
													}
												}, {
													text : '居中',
													icon : 'images/aligncenter.gif',
													handler : function() {
														graph
																.alignCells(mxConstants.ALIGN_CENTER)
													}
												}, {
													text : '居右',
													icon : 'images/alignright.gif',
													handler : function() {
														graph
																.alignCells(mxConstants.ALIGN_RIGHT)
													}
												}, '-', {
													text : '置顶',
													icon : 'images/aligntop.gif',
													handler : function() {
														graph
																.alignCells(mxConstants.ALIGN_TOP)
													}
												}, {
													text : '垂直居中',
													icon : 'images/alignmiddle.gif',
													handler : function() {
														graph
																.alignCells(mxConstants.ALIGN_MIDDLE)
													}
												}, {
													text : '置底',
													icon : 'images/alignbottom.gif',
													handler : function() {
														graph
																.alignCells(mxConstants.ALIGN_BOTTOM)
													}
												}]
											}
										}, '-', {
											text : '自适应大小',
											scope : this,
											handler : function() {
												if (!graph.isSelectionEmpty()) {
													graph
															.updateCellSize(graph
																	.getSelectionCell())
												}
											}
										}]
							}
						}, '-', {
							text : '编辑',
							scope : this,
							handler : function() {
								graph.startEditing()
							}
						}, '-', {
							text : '选择所有形状',
							scope : this,
							handler : function() {
								graph.selectVertices()
							}
						}, {
							text : '选择所有连线',
							scope : this,
							handler : function() {
								graph.selectEdges()
							}
						}, '-', {
							text : '全选',
							scope : this,
							handler : function() {
								graph.selectAll()
							}
						}, '-', {
							text : '属性',
							scope : this,
							handler : function() {
								showProps(graph, true);
							}
						}]
			});
			this.menu.on('hide', this.onContextHide, this);
			this.menu.showAt([e.clientX, e.clientY])
		},
		onContextHide : function() {
			if (this.ctxNode) {
				this.ctxNode.ui.removeClass('x-node-ctx');
				this.ctxNode = null
			}
		}
	});
	MainPanel.superclass.constructor.call(this, {
				region : 'center',
				layout : 'fit',
				items : this.graphPanel
			});
	var self = this;
	graph.panningHandler.popup = function(x, y, cell, evt) {
		self.graphPanel.onContextMenu(null, evt)
	};
	graph.panningHandler.hideMenu = function() {
		if (self.graphPanel.menuPanel != null) {
			self.graphPanel.menuPanel.hide()
		}
	};
	this.graphPanel.on('resize', function() {
				graph.sizeDidChange()
			});
};
Ext.extend(MainPanel, Ext.Panel);

showProps = function(graph, showPanel) {

	if (showPanel) {
		propertyPanel.expand();
	}
	var cell = graph.getSelectionCell();

	if (cell != null) {
		pgrid.setSource({
					"流程节点名称" : cell.getAttribute('label'),
					"终端操作码" : '1',
					"操作提示信息" : 'cc',
					"校验算法" : 'cc',
					"加密算法" : 'cc',
					"状态" : '正常'
				});
	}

	if (cell == null) {
		cell = graph.getCurrentRoot();
		if (cell == null) {
			cell = graph.getModel().getRoot();
		}
		pgrid.setSource({
					"画布名称" : cell.getAttribute('label')
				});
	}
}
LibraryPanel = function() {
	LibraryPanel.superclass.constructor.call(this, {
				region : 'center',
				split : true,
				rootVisible : false,
				lines : false,
				autoScroll : true,
				root : new Ext.tree.TreeNode('Graph Editor'),
				collapseFirst : false
			});
	this.templates = this.root.appendChild(new Ext.tree.TreeNode({
				text : '形状',
				cls : 'feeds-node',
				expanded : true
			}))
};
Ext.extend(LibraryPanel, Ext.tree.TreePanel, {
			addTemplate : function(name, icon, parentNode, cells) {
				var exists = this.getNodeById(name);
				if (exists) {
					if (!inactive) {
						exists.select();
						exists.ui.highlight()
					}
					return
				}
				var node = new Ext.tree.TreeNode({
							text : name,
							icon : icon,
							leaf : true,
							cls : 'feed',
							cells : cells,
							id : name
						});
				if (parentNode == null) {
					parentNode = this.templates
				}
				parentNode.appendChild(node);
				return node
			},
			afterRender : function() {
				LibraryPanel.superclass.afterRender.call(this);
				this.el.on('contextmenu', function(e) {
							e.preventDefault()
						})
			}
		});
GraphEditor = {};
var editor = null;

var pgrid = new Ext.grid.PropertyGrid({
			autoSort : false,
			source : {
				"(name)" : "Properties Grid",
				"grouping" : false,
				"created" : new Date(Date.parse('10/15/2006')),
				"version" : .01,
				"borderWidth" : 1
			},
			listeners : {
				'afteredit' : function(e) {

				},
				beforepropertychange : function(source, recordId, value,
						oldValue) {
					if (recordId == '终端操作码') {
						var record = this.getStore().getById(recordId);
						this.suspendEvents();
						record.set("value", storea.getAt(storea.find(
										'cust_type', value))
										.get('cust_type_name'));
						record.commit();
						this.resumeEvents();
						return false;
					}
				}
			}
		});
custtype = [['1', '个人'], ['0', '机构'], ['2', 'ccc']];
var storea = new Ext.data.SimpleStore({
			fields : ['cust_type', 'cust_type_name'],
			data : custtype
		})
pgrid.customEditors = {
	'终端操作码' : new Ext.grid.GridEditor(new Ext.form.ComboBox({
				typeAhead : true,
				triggerAction : 'all',
				store : storea,
				displayField : 'cust_type_name',
				forceSelection : true,
				name : 'cust_type',
				valueField : 'cust_type',
				mode : 'local'
			}))
};

var propertyPanel = new Ext.Panel({
			region : "east",
			title : "属性栏",
			width : 200,
			layout : 'fit',
			split : true,
			collapsible : true,
			items : [pgrid]
		});
function mxApplication(config)
	{ 
		try
		{
			if (!mxClient.isBrowserSupported())
			{
				mxUtils.error('Browser is not supported!', 200, false);
			}
			else
			{
				var node = mxUtils.load(config).getDocumentElement();
				var editor = new mxEditor(node); 
				// Displays version in statusbar
				editor.setStatus('mxGraph '+mxClient.VERSION); 
			}
		}
		catch (e)
		{ 
			// Shows an error message if the editor cannot start
			mxUtils.alert('Cannot start application: '+e.message);
			throw e; // for debugging
		} 				
		return editor;
	} 
		
function main() {
	editor = new mxApplication('config/diagrameditor.xml');
	Ext.QuickTips.init();
	mxEvent.disableContextMenu(document.body);
	mxConstants.DEFAULT_HOTSPOT = 0.3;
	var graph = editor.graph;
	var history = new mxUndoManager();
	var node = mxUtils.load('resources/default-style.xml').getDocumentElement();
	var dec = new mxCodec(node.ownerDocument);
	dec.decode(node, graph.getStylesheet());
	graph.alternateEdgeStyle = 'vertical';

	var mainPanel = new MainPanel(graph, history);
	var library = new LibraryPanel();
	var outlinePanel = new Ext.Panel({
				id : 'outlinePanel',
				layout : 'fit',
				split : true,
				height : 200,
				region : 'south'
			});

	var viewport = new Ext.Viewport({
				layout : 'border',
				items : [{
							xtype : 'panel',
							margins : '5 5 5 5',
							region : 'center',
							layout : 'border',
							border : false,
							items : [new Ext.Panel({
												title : '图形库',
												region : 'west',
												layout : 'border',
												split : true,
												width : 180,
												collapsible : true,
												border : false,
												items : [library, outlinePanel]
											}), mainPanel, propertyPanel]
						}]
			});
	mainPanel.graphPanel.body.dom.style.overflow = 'auto';
	if (mxClient.IS_MAC && mxClient.IS_SF) {
		graph.addListener(mxEvent.SIZE, function(graph) {
					graph.container.style.overflow = 'auto'
				})
	}
	graph.init(mainPanel.graphPanel.body.dom);
	graph.setConnectable(true);
	graph.setDropEnabled(true);
	graph.setPanning(true);
	graph.setTooltips(true);
	graph.connectionHandler.setCreateTarget(true);
	var rubberband = new mxRubberband(graph);
	var parent = graph.getDefaultParent();
	graph.getModel().beginUpdate();
	try {
		loadXML(graph)
	} finally {
		graph.getModel().endUpdate()
	}
	var listener = function(sender, evt) {
		history.undoableEditHappened(evt.getArgAt(0))
	};
	graph.getModel().addListener(mxEvent.UNDO, listener);
	graph.getView().addListener(mxEvent.UNDO, listener);
	var toolbarItems = mainPanel.graphPanel.getTopToolbar().items;
	var selectionListener = function() {
		showProps(graph);
		var selected = !graph.isSelectionEmpty();
		toolbarItems.get('cut').setDisabled(!selected);
		toolbarItems.get('copy').setDisabled(!selected);
		toolbarItems.get('delete').setDisabled(!selected);
		toolbarItems.get('italic').setDisabled(!selected);
		toolbarItems.get('bold').setDisabled(!selected);
		toolbarItems.get('underline').setDisabled(!selected);
		toolbarItems.get('fillcolor').setDisabled(!selected);
		toolbarItems.get('fontcolor').setDisabled(!selected);
		toolbarItems.get('linecolor').setDisabled(!selected);
		toolbarItems.get('align').setDisabled(!selected)
	};
	graph.getSelectionModel().addListener(mxEvent.CHANGE, selectionListener);
	var historyListener = function() {
		toolbarItems.get('undo').setDisabled(!history.canUndo());
		toolbarItems.get('redo').setDisabled(!history.canRedo())
	};
	history.addListener(mxEvent.ADD, historyListener);
	history.addListener(mxEvent.UNDO, historyListener);
	history.addListener(mxEvent.REDO, historyListener);
	selectionListener();
	historyListener();
	var outline = new mxOutline(graph, outlinePanel.body.dom);
	insertVertexTemplate(library, graph, '文本', 'images/text.gif',
			'text;rounded=1', 80, 20, 'text');
	insertVertexTemplate(library, graph, '容器', 'images/swimlane.gif',
			'swimlane', 200, 200, 'container');
	insertVertexTemplate(library, graph, '矩形', 'images/rectangle.gif', null,
			100, 40, "rectangle");
	insertVertexTemplate(library, graph, '平滑矩形', 'images/rounded.gif',
			'rounded=1', 100, 40, "rounded");
	insertVertexTemplate(library, graph, '椭圆', 'images/ellipse.gif', 'ellipse',
			60, 60, "ellipse");
	insertVertexTemplate(library, graph, '双环椭圆', 'images/doubleellipse.gif',
			'ellipse;shape=doubleEllipse', 60, 60, "doubleellipse");
	insertVertexTemplate(library, graph, '三角形', 'images/triangle.gif',
			'triangle', 40, 60, "triangle");
	insertVertexTemplate(library, graph, '菱形', 'images/rhombus.gif', 'rhombus',
			60, 60, "rhombus");
	insertVertexTemplate(library, graph, '水平线', 'images/hline.gif', 'line',
			120, 10, "hline");
	insertVertexTemplate(library, graph, '六边形', 'images/hexagon.gif',
			'shape=hexagon', 80, 60, "hexagon");
	insertVertexTemplate(library, graph, '圆柱体', 'images/cylinder.gif',
			'shape=cylinder', 60, 80, "cylinder");
	insertVertexTemplate(library, graph, '角色', 'images/actor.gif',
			'shape=actor', 40, 60, "actor");
	insertVertexTemplate(library, graph, '对话', 'images/cloud.gif',
			'ellipse;shape=cloud', 80, 60, "cloud");
	insertEdgeTemplate(library, graph, '直线', 'images/straight.gif', 'straight',
			100, 100, "connector");
	insertEdgeTemplate(library, graph, '水平连接线', 'images/connect.gif', null,
			100, 100, "connector");
	insertEdgeTemplate(library, graph, '垂直连接线', 'images/vertical.gif',
			'vertical', 100, 100, "connector");
	insertEdgeTemplate(library, graph, '实体关系', 'images/entity.gif', 'entity',
			100, 100, "connector");
	insertEdgeTemplate(library, graph, '箭头', 'images/arrow.gif', 'arrow', 100,
			100, "connector");
	var previousCreateGroupCell = graph.createGroupCell;
	graph.createGroupCell = function() {
		var group = previousCreateGroupCell.apply(this, arguments);
		group.setStyle('group');
		return group
	};
	graph.connectionHandler.factoryMethod = function() {
		if (GraphEditor.edgeTemplate != null) {
			return graph.cloneCells([GraphEditor.edgeTemplate])[0]
		}
		return null
	};
	library.getSelectionModel().on('selectionchange', function(sm, node) {
				if (node != null && node.attributes.cells != null) {
					var cell = node.attributes.cells[0];
					if (cell != null && graph.getModel().isEdge(cell)) {
						GraphEditor.edgeTemplate = cell
					}
				}
			});
	var tooltip = new Ext.ToolTip({
				target : graph.container,
				html : ''
			});
	tooltip.disabled = true;
	graph.tooltipHandler.show = function(tip, x, y) {
		if (tip != null && tip.length > 0) {
			if (tooltip.body != null) {
				tooltip.body.dom.firstChild.nodeValue = tip
			} else {
				tooltip.html = tip
			}
			tooltip.showAt([x, y + mxConstants.TOOLTIP_VERTICAL_OFFSET])
		}
	};
	graph.tooltipHandler.hide = function() {
		tooltip.hide()
	};
	var drillHandler = function(sender) {
		var model = graph.getModel();
		var cell = graph.getCurrentRoot();
		var title = '';
		while (cell != null && model.getParent(model.getParent(cell)) != null) {
			if (graph.isValidRoot(cell)) {
				title = ' > ' + graph.convertValueToString(cell) + title
			}
			cell = graph.getModel().getParent(cell)
		}
		document.title = 'KSOA图形编辑器' + title
	};
	graph.getView().addListener(mxEvent.DOWN, drillHandler);
	graph.getView().addListener(mxEvent.UP, drillHandler);
	var undoHandler = function(sender, evt) {
		var changes = evt.getArgAt(0).changes;
		graph.setSelectionCells(graph.getSelectionCellsForChanges(changes))
	};
	history.addListener(mxEvent.UNDO, undoHandler);
	history.addListener(mxEvent.REDO, undoHandler);
	graph.container.focus();
	graph.container.style.backgroundImage = 'url(images/body_bg.jpg)';

	mxConnectionHandler.prototype.connectImage = new mxImage(
			'images/connector.gif', 16, 16);
	var img = new Image();
	img.src = mxConnectionHandler.prototype.connectImage.src;

	var keyHandler = new mxKeyHandler(graph);
	keyHandler.enter = function() {
	};
	keyHandler.bindKey(8, function() {
				graph.foldCells(true)
			});
	keyHandler.bindKey(13, function() {
				graph.foldCells(false)
			});
	keyHandler.bindKey(33, function() {
				graph.exitGroup()
			});
	keyHandler.bindKey(34, function() {
				graph.enterGroup()
			});
	keyHandler.bindKey(36, function() {
				graph.home()
			});
	keyHandler.bindKey(35, function() {
				graph.refresh()
			});
	keyHandler.bindKey(37, function() {
				graph.selectPreviousCell()
			});
	keyHandler.bindKey(38, function() {
				graph.selectParentCell()
			});
	keyHandler.bindKey(39, function() {
				graph.selectNextCell()
			});
	keyHandler.bindKey(40, function() {
				graph.selectChildCell()
			});
	keyHandler.bindKey(46, function() {
				graph.removeCells()
			});
	keyHandler.bindKey(107, function() {
				graph.zoomIn()
			});
	keyHandler.bindKey(109, function() {
				graph.zoomOut()
			});
	keyHandler.bindKey(113, function() {
				graph.startEditingAtCell()
			});
	keyHandler.bindControlKey(65, function() {
				graph.selectAll()
			});
	keyHandler.bindControlKey(89, function() {
				history.redo()
			});
	keyHandler.bindControlKey(90, function() {
				history.undo()
			});
	keyHandler.bindControlKey(88, function() {
				mxClipboard.cut(graph)
			});
	keyHandler.bindControlKey(67, function() {
				mxClipboard.copy(graph)
			});
	keyHandler.bindControlKey(86, function() {
				mxClipboard.paste(graph)
			});
	keyHandler.bindControlKey(71, function() {
				graph.setSelectionCell(graph.groupCells(null, 20))
			});
	keyHandler.bindControlKey(85, function() {
				graph.setSelectionCells(graph.ungroupCells())
			})
};
function insertSymbolTemplate(panel, graph, name, icon, rhombus) {
	var imagesNode = panel.symbols;
	var style = (rhombus) ? 'rhombusImage' : 'roundImage';
	return insertVertexTemplate(panel, graph, name, icon, style + ';image='
					+ icon, 50, 50, '', imagesNode)
};
function insertImageTemplate(panel, graph, name, icon, round) {
	var imagesNode = panel.images;
	var style = (round) ? 'roundImage' : 'image';
	return insertVertexTemplate(panel, graph, name, icon, style + ';image='
					+ icon, 50, 50, name, imagesNode)
};
function insertVertexTemplate(panel, graph, name, icon, style, width, height,
		value, parentNode) {

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
	var funct = function(graph, evt, target) {
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
	var node = panel.addTemplate(name, icon, parentNode, cells);
	var installDrag = function(expandedNode) {
		if (node.ui.elNode != null) {
			var dragPreview = document.createElement('div');
			dragPreview.style.border = 'dashed black 1px';
			dragPreview.style.width = width + 'px';
			dragPreview.style.height = height + 'px';
			mxUtils.makeDraggable(node.ui.elNode, graph, funct, dragPreview, 0,
					0, graph.autoscroll, true)
		}
	};
	if (!node.parentNode.isExpanded()) {
		panel.on('expandnode', installDrag)
	} else {
		installDrag(node.parentNode)
	}
	return node
};
function insertEdgeTemplate(panel, graph, name, icon, style, width, height,
		value, parentNode) {
	/*
	 * var cell=null; if(value!=null){ cell=editor.templates[value];
	 * if(cell==null){ cell=new mxCell(value,width,height,style); }
	 * cell.setStyle(style); }else{ cell=new mxCell(new mxGeometry(0, 0,width,
	 * height), style); } var cells=[cell];
	 */
	var cells = [new mxCell((value != null) ? value : '', new mxGeometry(0, 0,
					width, height), style)];
	cells[0].geometry.setTerminalPoint(new mxPoint(0, height), true);
	cells[0].geometry.setTerminalPoint(new mxPoint(width, 0), false);
	cells[0].edge = true;
	var funct = function(graph, evt, target) {
		cells = graph.getImportableCells(cells);
		if (cells.length > 0) {
			var validDropTarget = (target != null) ? graph.isValidDropTarget(
					target, cells, evt) : false;
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
	var node = panel.addTemplate(name, icon, parentNode, cells);
	var installDrag = function(expandedNode) {
		if (node.ui.elNode != null) {
			var dragPreview = document.createElement('div');
			dragPreview.style.border = 'dashed black 1px';
			dragPreview.style.width = width + 'px';
			dragPreview.style.height = height + 'px';
			mxUtils.makeDraggable(node.ui.elNode, graph, funct, dragPreview,
					-width / 2, -height / 2, graph.autoscroll, true)
		}
	};
	if (!node.parentNode.isExpanded()) {
		panel.on('expandnode', installDrag)
	} else {
		installDrag(node.parentNode)
	}
	return node
};
Ext.example = function() {
	var msgCt;
	function createBox(t, s) {
		return [
				'<div class="msg">',
				'<div class="x-box-tl"><div class="x-box-tr"><div class="x-box-tc"></div></div></div>',
				'<div class="x-box-ml"><div class="x-box-mr"><div class="x-box-mc"><h3>',
				t,
				'</h3>',
				s,
				'</div></div></div>',
				'<div class="x-box-bl"><div class="x-box-br"><div class="x-box-bc"></div></div></div>',
				'</div>'].join('')
	}
	return {
		msg : function(title, format) {
			if (!msgCt) {
				msgCt = Ext.DomHelper.append(document.body, {
							id : 'msg-div'
						}, true)
			}
			msgCt.alignTo(document, 't-t');
			var s = String.format.apply(String, Array.prototype.slice.call(
							arguments, 1));
			var m = Ext.DomHelper.append(msgCt, {
						html : createBox(title, s)
					}, true);
			m.slideIn('t').pause(1).ghost("t", {
						remove : true
					})
		}
	}
}();
mxUtils.alert = function(message) {
	Ext.example.msg(message, '', '')
};
function loadXML(graph) {
	var textareas = document.getElementsByTagName('textarea');
	var xml = textareas[0].value;
	var xmlDocument = mxUtils.parseXml(xml);
	var decoder = new mxCodec(xmlDocument);
	var node = xmlDocument.documentElement;
	decoder.decode(node, graph.getModel())
};