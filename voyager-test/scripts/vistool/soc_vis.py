#!/usr/bin/env python3
"""
Verilog SoC 架构可视化脚本
支持命令行参数输入filelist.f路径和输出HTML路径
"""

import re
import os
import sys
import argparse

def parse_verilog_file(file_path):
    """解析Verilog文件，提取模块信息"""
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except:
        return None
    
    # 提取模块名
    module_match = re.search(r'module\s+(\w+)', content, re.IGNORECASE)
    if not module_match:
        return None
    
    module_name = module_match.group(1)
    
    # 提取端口
    ports = []
    port_pattern = r'(?:input|output|inout)\s+(?:\[.*?\]\s+)?(\w+)'
    port_matches = re.findall(port_pattern, content, re.IGNORECASE)
    ports.extend(port_matches)
    
    # 提取实例化
    instances = []
    instance_pattern = r'(\w+)\s+(\w+)\s*\('
    for match in re.finditer(instance_pattern, content):
        module_type = match.group(1)
        instance_name = match.group(2)
        
        # 排除关键字
        keywords = ['if', 'else', 'begin', 'end', 'case', 'default', 'for', 'while', 'always', 'initial']
        if module_type.lower() not in keywords and instance_name.lower() not in keywords:
            instances.append({
                'type': module_type,
                'name': instance_name
            })
    
    return {
        'name': module_name,
        'file': file_path,
        'ports': ports,
        'instances': instances
    }

def generate_html_visualization(modules, connections):
    """生成HTML可视化页面"""
    
    # 准备节点数据
    nodes_js = []
    for i, module in enumerate(modules):
        node = {
            'id': module['name'],
            'label': module['name'],
            'color': '#4CAF50',
            'borderColor': '#2E7D32',
            'font': {'color': 'black'},
            'shape': 'box'
        }
        nodes_js.append(str(node).replace("'", '"'))
    
    # 准备连接数据
    edges_js = []
    for connection in connections:
        parent_module = connection['parent_module']
        child_module = connection['child_module']
        instance_name = connection['instance_name']
        
        # 确保父模块和子模块都存在
        module_names = [m['name'] for m in modules]
        if parent_module in module_names and child_module in module_names:
            edge = {
                'from': parent_module,
                'to': child_module,
                'label': instance_name,
                'color': {'color': '#4CAF50', 'highlight': '#FF4444'},
                'width': 2,
                'smooth': {'type': 'continuous', 'roundness': 0.5}
            }
            edges_js.append(str(edge).replace("'", '"'))

    html_content = f"""<!DOCTYPE html>
<html>
<head>
    <title>Verilog SoC 架构可视化</title>
    <script type="text/javascript" src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
    <style>
        body {{
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }}
        
        .container {{
            display: flex;
            flex-direction: column;
            height: 100vh;
        }}
        
        .header {{
            background: white;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        
        .controls {{
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }}
        
        .control-group {{
            display: flex;
            flex-direction: column;
            gap: 5px;
        }}
        
        .control-group label {{
            font-weight: bold;
            font-size: 12px;
            color: #333;
        }}
        
        .search-group {{
            display: flex;
            gap: 5px;
            align-items: center;
        }}
        
        .network-container {{
            flex: 1;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow: hidden;
        }}
        
        #visualization {{
            width: 100%;
            height: 100%;
            border: none;
        }}
        
        .stats {{
            background: white;
            padding: 10px 15px;
            border-radius: 8px;
            margin-top: 10px;
            font-size: 12px;
            color: #666;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        
        select, input, button {{
            padding: 5px 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 12px;
        }}
        
        button {{
            background: #2196F3;
            color: white;
            border: none;
            cursor: pointer;
            transition: background 0.3s;
        }}
        
        button:hover {{
            background: #1976D2;
        }}
        
        input[type="range"] {{
            width: 100px;
        }}
        
        .range-value {{
            min-width: 30px;
            text-align: center;
            font-weight: bold;
            color: #2196F3;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 style="margin: 0 0 15px 0; color: #333;">Verilog SoC 架构可视化</h1>
            
            <div class="controls">
                <div class="search-group">
                    <input type="text" id="search" placeholder="搜索模块..." onkeypress="if(event.key==='Enter') searchModule()">
                    <button onclick="searchModule()">搜索</button>
                </div>
                
                <div class="control-group">
                    <label>布局算法:</label>
                    <select id="layout" onchange="changeLayout()">
                        <option value="forceAtlas2Based">Force Atlas 2</option>
                        <option value="barnesHut">Barnes Hut</option>
                        <option value="repulsion">Repulsion</option>
                        <option value="hierarchical">层次布局</option>
                    </select>
                </div>
                
                <div class="control-group">
                    <label>
                        <input type="checkbox" id="showLabels" checked onchange="toggleLabels()">
                        显示标签
                    </label>
                </div>
                
                <div class="control-group">
                    <label>
                        <input type="checkbox" id="showEdges" checked onchange="toggleEdges()">
                        显示连线
                    </label>
                </div>
                
                <button onclick="fitNetwork()">适应画面</button>
                <button onclick="resetView()">重置视图</button>
                <button onclick="togglePhysics()">切换物理引擎</button>
            </div>
            
            <div class="control-group" id="hierarchical-controls" style="display: none; margin-top: 15px;">
                <label>
                    层次方向:
                    <select id="direction">
                        <option value="UD">上→下</option>
                        <option value="DU">下→上</option>
                        <option value="LR">左→右</option>
                        <option value="RL">右→左</option>
                    </select>
                </label>
                <label>
                    层级间距 (垂直距离):
                    <input type="range" id="level-separation" min="50" max="500" value="120">
                    <span id="level-separation-value">120</span>
                </label>
                <label>
                    节点间距 (水平距离):
                    <input type="range" id="layer-spacing" min="50" max="300" value="100">
                    <span id="layer-spacing-value">100</span>
                </label>
                <label>
                    树间距:
                    <input type="range" id="spring-length" min="50" max="400" value="200">
                    <span id="spring-length-value">200</span>
                </label>
            </div>
        </div>
        
        <div class="network-container">
            <div id="visualization"></div>
        </div>
        
        <div class="stats">
            模块数量: {len(modules)} | 连接数量: {len(connections)} | 操作提示: Ctrl+F搜索，Ctrl+R重置视图，双击节点聚焦
        </div>
    </div>

    <script type="text/javascript">
        // 数据准备
        const nodes = new vis.DataSet([
            {', '.join(nodes_js)}
        ]);
        
        const edges = new vis.DataSet([
            {', '.join(edges_js)}
        ]);
        
        // 保存原始颜色用于重置
        const originalNodes = nodes.get();
        const originalEdges = edges.get();
        
        let selectedNodeId = null;
        
        // 容器
        const container = document.getElementById('visualization');
        
        // 层次布局控制元素
        const hierarchicalControls = document.getElementById('hierarchical-controls');
        const directionSelect = document.getElementById('direction');
        const layerSpacingSlider = document.getElementById('layer-spacing');
        const layerSpacingValue = document.getElementById('layer-spacing-value');
        const springLengthSlider = document.getElementById('spring-length');
        const springLengthValue = document.getElementById('spring-length-value');
        const levelSeparationSlider = document.getElementById('level-separation');
        const levelSeparationValue = document.getElementById('level-separation-value');

        // 层次布局设置
        const hierarchicalOptions = {{
            enabled: true,
            direction: 'UD',
            sortMethod: 'directed',
            levelSeparation: 120,  // 层级间距（垂直距离）
            nodeSpacing: 100,      // 节点间距（水平距离）
            blockShifting: true,
            edgeMinimization: true,
            parentCentralization: true,
            treeSpacing: 200
        }};

        // vis.js 配置选项
        const options = {{
            nodes: {{
                shape: 'box',
                margin: 10,
                font: {{
                    size: 14,
                    color: 'black'
                }},
                borderWidth: 2,
                shadow: true
            }},
            edges: {{
                width: 2,
                color: {{
                    color: '#848484',
                    highlight: '#FF0000',
                    hover: '#FF0000'
                }},
                arrows: {{
                    to: {{enabled: true, scaleFactor:1, type:'arrow'}}
                }},
                smooth: true,
                font: {{
                    size: 12,
                    color: '#333333',
                    background: 'rgba(255,255,255,0.7)',
                    strokeWidth: 1,
                    strokeColor: '#ffffff'
                }}
            }},
            layout: {{
                improvedLayout: true
            }},
            physics: {{
                enabled: true,
                stabilization: {{
                    enabled: true,
                    iterations: 100
                }}
            }},
            interaction: {{
                selectConnectedEdges: false,
                hover: true
            }}
        }};
        
        // 创建网络
        const network = new vis.Network(container, {{nodes: nodes, edges: edges}}, options);
        
        // 事件监听器设置
        
        // 方向选择处理
        directionSelect.addEventListener('change', function() {{
            if (document.getElementById('layout').value === 'hierarchical') {{
                hierarchicalOptions.direction = this.value;
                updateHierarchicalLayout();
            }}
        }});

        // 层级间距控制 - 这是垂直方向上层与层之间的距离
        levelSeparationSlider.addEventListener('input', function() {{
            const value = parseInt(this.value);
            levelSeparationValue.textContent = value;
            if (document.getElementById('layout').value === 'hierarchical') {{
                hierarchicalOptions.levelSeparation = value;
                updateHierarchicalLayout();
            }}
        }});

        // 节点间距控制 - 这是水平方向上节点间的距离
        layerSpacingSlider.addEventListener('input', function() {{
            const value = parseInt(this.value);
            layerSpacingValue.textContent = value;
            if (document.getElementById('layout').value === 'hierarchical') {{
                hierarchicalOptions.nodeSpacing = value;
                updateHierarchicalLayout();
            }}
        }});

        // 边长度控制
        springLengthSlider.addEventListener('input', function() {{
            const value = parseInt(this.value);
            springLengthValue.textContent = value;
            if (document.getElementById('layout').value === 'hierarchical') {{
                hierarchicalOptions.treeSpacing = value;
                updateHierarchicalLayout();
            }}
        }});
        
        // 高亮显示选中节点及其连接
        function highlightNode(nodeId) {{
            // 先重置之前的高亮
            if (selectedNodeId !== null) {{
                resetHighlight();
            }}
            
            selectedNodeId = nodeId;
            
            const connectedNodes = network.getConnectedNodes(nodeId);
            const connectedEdges = network.getConnectedEdges(nodeId);
            
            // 更新选中节点的颜色
            const updateNodes = [{{
                id: nodeId,
                color: '#FF0000',
                borderColor: '#CC0000'
            }}];
            
            // 更新连接的节点颜色
            connectedNodes.forEach(connectedNodeId => {{
                updateNodes.push({{
                    id: connectedNodeId,
                    color: '#FF0000',
                    borderColor: '#CC0000'
                }});
            }});
            
            // 更新边的颜色
            const updateEdges = connectedEdges.map(edgeId => ({{
                id: edgeId,
                color: '#FF0000'
            }}));
            
            nodes.update(updateNodes);
            edges.update(updateEdges);
        }}
        
        // 重置高亮状态
        function resetHighlight() {{
            if (selectedNodeId === null) return;
            
            const connectedNodes = network.getConnectedNodes(selectedNodeId);
            const connectedEdges = network.getConnectedEdges(selectedNodeId);
            
            // 恢复选中节点的颜色
            const updateNodes = [{{
                id: selectedNodeId,
                color: '#4CAF50',
                borderColor: '#2E7D32'
            }}];
            
            // 恢复连接节点的颜色
            connectedNodes.forEach(connectedNodeId => {{
                updateNodes.push({{
                    id: connectedNodeId,
                    color: '#4CAF50',
                    borderColor: '#2E7D32'
                }});
            }});
            
            // 恢复边的颜色
            const updateEdges = connectedEdges.map(edgeId => ({{
                id: edgeId,
                color: '#4CAF50'
            }}));
            
            nodes.update(updateNodes);
            edges.update(updateEdges);
        }}
        
        // 事件处理
        network.on("click", function(params) {{
            if (params.nodes.length > 0) {{
                const nodeId = params.nodes[0];
                highlightNode(nodeId);
            }} else {{
                // 点击空白区域，重置高亮
                if (selectedNodeId !== null) {{
                    resetHighlight();
                    selectedNodeId = null;
                }}
            }}
        }});
        
        network.on("doubleClick", function(params) {{
            if (params.nodes.length > 0) {{
                const nodeId = params.nodes[0];
                network.focus(nodeId, {{
                    scale: 1.5,
                    animation: true
                }});
            }}
        }});
        
        // 控制函数
        function searchModule() {{
            const searchTerm = document.getElementById('search').value.toLowerCase();
            if (!searchTerm) return;
            
            const foundNodes = nodes.get({{
                filter: function(item) {{
                    return item.label.toLowerCase().includes(searchTerm);
                }}
            }});
            
            if (foundNodes.length > 0) {{
                const nodeId = foundNodes[0].id;
                highlightNode(nodeId);
                network.focus(nodeId, {{
                    scale: 1.5,
                    animation: true
                }});
            }} else {{
                alert('未找到模块: ' + searchTerm);
            }}
        }}
        
        function changeLayout() {{
            const layoutType = document.getElementById('layout').value;
            
            if (layoutType === 'hierarchical') {{
                hierarchicalControls.style.display = 'block';
                updateHierarchicalLayout();
            }} else {{
                hierarchicalControls.style.display = 'none';
                const newOptions = {{
                    layout: {{
                        hierarchical: {{
                            enabled: false
                        }}
                    }},
                    physics: {{
                        enabled: true,
                        solver: layoutType,
                        stabilization: {{ iterations: 200 }}
                    }}
                }};
                network.setOptions(newOptions);
            }}
        }}
        
        function updateHierarchicalLayout() {{
            const newOptions = {{
                layout: {{
                    hierarchical: {{
                        enabled: true,
                        direction: hierarchicalOptions.direction,
                        sortMethod: 'directed',
                        nodeSpacing: hierarchicalOptions.nodeSpacing,
                        levelSeparation: hierarchicalOptions.levelSeparation,
                        blockShifting: true,
                        edgeMinimization: true,
                        parentCentralization: true,
                        treeSpacing: hierarchicalOptions.treeSpacing
                    }}
                }},
                physics: {{
                    enabled: true,
                    hierarchicalRepulsion: {{
                        centralGravity: 0.0,
                        springLength: hierarchicalOptions.levelSeparation,
                        springConstant: 0.01,
                        nodeDistance: hierarchicalOptions.nodeSpacing,
                        damping: 0.09
                    }}
                }}
            }};
            
            network.setOptions(newOptions);
        }}
        
        function fitNetwork() {{
            network.fit({{
                animation: true
            }});
        }}
        
        function resetView() {{
            network.moveTo({{
                position: {{x: 0, y: 0}},
                scale: 1.0,
                animation: true
            }});
        }}
        
        let physicsEnabled = true;
        function togglePhysics() {{
            physicsEnabled = !physicsEnabled;
            network.setOptions({{
                physics: {{ enabled: physicsEnabled }}
            }});
        }}
        
        function toggleLabels() {{
            const showLabels = document.getElementById('showLabels').checked;
            network.setOptions({{
                nodes: {{
                    font: {{ size: showLabels ? 12 : 0 }}
                }}
            }});
        }}
        
        function toggleEdges() {{
            const showEdges = document.getElementById('showEdges').checked;
            if (showEdges) {{
                network.setData({{ nodes: nodes, edges: edges }});
            }} else {{
                network.setData({{ nodes: nodes, edges: new vis.DataSet() }});
            }}
        }}
        
        // 键盘快捷键
        document.addEventListener('keydown', function(event) {{
            if (event.key === 'f' && event.ctrlKey) {{
                event.preventDefault();
                document.getElementById('search').focus();
            }} else if (event.key === 'r' && event.ctrlKey) {{
                event.preventDefault();
                resetView();
            }}
        }});
        
        // 初始化
        setTimeout(() => {{
            fitNetwork();
        }}, 1000);
        
        console.log('SoC Visualization loaded successfully');
        console.log('Modules:', {len(modules)});
        console.log('Connections:', {len(connections)});
    </script>
</body>
</html>"""
    
    return html_content

def main():
    """主函数"""
    # 设置命令行参数
    parser = argparse.ArgumentParser(
        description='生成 Verilog SoC 架构可视化',
        epilog='示例: python %(prog)s path/to/filelist.f output.html'
    )
    parser.add_argument('filelist', help='filelist.f 文件路径')
    parser.add_argument('output', help='输出 HTML 文件路径')
    parser.add_argument('--verbose', '-v', action='store_true', help='显示详细信息')
    
    args = parser.parse_args()
    
    # 验证输入文件
    if not os.path.exists(args.filelist):
        print(f"错误：找不到文件 {args.filelist}")
        return 1
    
    if not args.filelist.endswith('.f'):
        print(f"警告：输入文件 {args.filelist} 不是 .f 文件")
    
    # 验证输出路径
    output_dir = os.path.dirname(args.output)
    if output_dir and not os.path.exists(output_dir):
        print(f"错误：输出目录 {output_dir} 不存在")
        return 1
    
    if not args.output.endswith('.html'):
        print(f"警告：输出文件 {args.output} 不是 .html 文件")
    
    if args.verbose:
        print(f"开始解析 Verilog SoC 项目...")
        print(f"输入文件: {args.filelist}")
        print(f"输出文件: {args.output}")
    
    # 读取文件列表
    try:
        with open(args.filelist, 'r') as f:
            file_list = [line.strip() for line in f.readlines() if line.strip() and not line.startswith('#')]
    except Exception as e:
        print(f"错误：无法读取文件列表 {args.filelist}: {e}")
        return 1
    
    if args.verbose:
        print(f"找到 {len(file_list)} 个文件")
    
    # 解析所有模块
    modules = []
    module_map = {}
    base_dir = os.path.dirname(args.filelist)
    
    for file_name in file_list:
        file_path = os.path.join(base_dir, file_name)
        if os.path.exists(file_path):
            module_info = parse_verilog_file(file_path)
            if module_info:
                modules.append(module_info)
                module_map[module_info['name']] = module_info
                if args.verbose:
                    print(f"解析模块: {module_info['name']}")
        elif args.verbose:
            print(f"警告：找不到文件 {file_path}")
    
    if len(modules) == 0:
        print("错误：没有找到任何有效的模块")
        return 1
    
    print(f"共解析 {len(modules)} 个模块")
    
    # 构建连接关系
    connections = []
    for module in modules:
        for instance in module['instances']:
            if instance['type'] in module_map:
                connections.append({
                    'parent_module': module['name'],
                    'child_module': instance['type'],
                    'instance_name': instance['name']
                })
    
    print(f"共找到 {len(connections)} 个连接")
    
    # 生成HTML可视化
    try:
        html_content = generate_html_visualization(modules, connections)
    except Exception as e:
        print(f"错误：生成HTML内容失败: {e}")
        return 1
    
    # 保存HTML文件
    try:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(html_content)
    except Exception as e:
        print(f"错误：保存HTML文件失败: {e}")
        return 1
    
    print(f"可视化文件已生成: {args.output}")
    print("请在浏览器中打开此文件查看SoC架构可视化")
    
    return 0

if __name__ == "__main__":
    sys.exit(main()) 
    