<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="mxgraphDemo.aspx.cs" Inherits="SvgWeb.mxgraphDemo" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Hello, World! example for mxGraph</title>


    </head>
<body onload="main(document.getElementById('graphContainer'))">
    <form id="form1" runat="server">

    <ext:ResourceManager ID="ResourceManager1" runat="server" />

    <script type="text/javascript" src="mxgraph/src/js/mxClient.js"></script>

    <ext:XScript ID="XScript1" runat="server">
        <script type="text/javascript">

            mxBasePath = 'mxgraph/src';

            // Program starts here. Creates a sample graph in the
            // DOM node with the specified ID. This function is invoked
            // from the onLoad event handler of the document (see below).
            var graph;

            function main(container) {
                // Checks if the browser is supported
                if (!mxClient.isBrowserSupported()) {
                    // Displays an error message if the browser is not supported.
                    mxUtils.error('Browser is not supported!', 200, false);
                }
                else {
                    // Creates the graph inside the given container
                    graph = new mxGraph(container);

                    // Enables rubberband selection
                    new mxRubberband(graph);
                    graph.setPanning(true);
                    graph.setTooltips(true);

                    // Gets the default parent for inserting new cells. This
                    // is normally the first child of the root (ie. layer 0).
                    var parent = graph.getDefaultParent();

                    // Adds cells to the model in a single step
                    graph.getModel().beginUpdate();
                    try {
                        var v1 = graph.insertVertex(parent, null, 'Hello,', 20, 20, 80, 30);
                        var v2 = graph.insertVertex(parent, null, 'World!', 200, 150, 80, 30);
                        var e1 = graph.insertEdge(parent, null, '', v1, v2);
                    }
                    finally {
                        // Updates the display
                        graph.getModel().endUpdate();
                    }
                }
            };

            Ext.onReady(function(){

                main(document.getElementById('graphContainer'));

                graph.container.style.backgroundImage = 'url(mxgraph/examples/editors/images/grid.gif)';
                
            });

            var showGraph = function (el, e) {

                graph.sizeDidChange();
                #{winGraph}.show();
            }

            var ExtMxGraphReSize = function(){
                if(graph){
                    graph.container.style.height = #{winGraph}.getHeight() + 'px';
                    graph.container.style.width = #{winGraph}.getWidth() + 'px'; 
                    graph.sizeDidChange();
                }
            }

        </script>
    </ext:XScript>

    <ext:Button runat="server" ID="btnshow" Text="Hello World" >
        <Listeners>
            <Click Fn="showGraph" />
        </Listeners>
    </ext:Button>

    <ext:Window runat="server" ID="winGraph" Title="Hello World" Width="640" Height="480">
        <Listeners>
            <Resize Handler="ExtMxGraphReSize" />
        </Listeners>
        <Content>
            <div id="graphContainer" class="x-tab" title="Hello World 1" />
        </Content>
        <Buttons>
            <ext:Button runat="server" Text="Close" >
                <Listeners>
                    <Click Handler="#{winGraph}.hide()" />
                </Listeners>
            </ext:Button>
        </Buttons>
    </ext:Window>

    </form>
</body>
</html>
