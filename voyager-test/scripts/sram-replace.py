import json
import re
import sys
import os
import argparse

def parse_seq_mems(json_file):
    with open(json_file, 'r') as f:
        return json.load(f)

def parse_modules(verilog_file):
    with open(verilog_file, 'r') as f:
        content = f.read()
    
    # Find all module definitions
    modules = {}
    pattern = r'module\s+(\w+)\s*\(([\s\S]*?)\);([\s\S]*?)endmodule'
    matches = re.finditer(pattern, content)
    
    for match in matches:
        module_name = match.group(1)
        port_list = match.group(2)
        module_body = match.group(3)
        
        # Skip "split_" modules
        if module_name.startswith("split_"):
            continue
            
        # Parse port list
        ports = {}
        port_pattern = r'input|output'
        if re.search(port_pattern, port_list):
            # Parse modern-style port list
            port_entries = re.finditer(r'\s*(input|output)\s+(\[\d+:\d+\])?\s*(\w+)', port_list)
            for port in port_entries:
                direction = port.group(1)
                width = port.group(2) if port.group(2) else ""
                name = port.group(3)
                ports[name] = {"direction": direction, "width": width}
        
        modules[module_name] = {
            "ports": ports,
            "body": module_body
        }
    
    return modules

def determine_module_type(module_name, ports):
    """Determine the type of memory module based on ports and name."""
    port_names = ports.keys()
    
    if "RW0_addr" in port_names and "RW0_wdata" in port_names and "RW0_rdata" in port_names:
        return "RW"  # Read-Write port
    elif "R0_addr" in port_names and "W0_addr" in port_names:
        return "RW_split"  # Separate Read-Write ports
    
    return "unknown"

def find_best_sram_size(width, depth, available_srams):
    """Find the best SRAM size match from available SRAMs."""
    best_sram = None
    min_waste = float('inf')
    
    for sram in available_srams:
        # Extract width and depth from SRAM name (e.g., 256x32)
        match = re.search(r'(\d+)x(\d+)', sram)
        if match:
            sram_depth = int(match.group(1))
            sram_width = int(match.group(2))
            
            # Skip SRAMs that are too small
            if sram_width < width or sram_depth < depth:
                continue
                
            # Calculate resource waste
            width_waste = sram_width - width
            depth_waste = sram_depth - depth
            total_waste = width_waste * sram_depth + depth_waste * width
            
            if total_waste < min_waste:
                min_waste = total_waste
                best_sram = {"depth": sram_depth, "width": sram_width, "name": sram}
    
    return best_sram

def generate_ext_module(module_name, ports, mem_info, available_srams):
    """Generate the ext module implementation based on the module type and parameters."""
    port_names = list(ports.keys())
    port_list = []
    
    # Build port list for module definition
    for name, info in ports.items():
        direction = info["direction"]
        width = info["width"]
        port_list.append(f"  {direction} {width} {name}")
    
    port_str = ",\n".join(port_list)
    
    module_type = determine_module_type(module_name, ports)
    depth = mem_info.get("depth", 0)
    width = mem_info.get("width", 0)
    
    # Calculate address width and bits needed for macro selection
    addr_width = 0
    for port_name, port_info in ports.items():
        if port_name.endswith("_addr"):
            if port_info["width"]:
                match = re.search(r'\[(\d+):(\d+)\]', port_info["width"])
                if match:
                    addr_width = int(match.group(1)) + 1
                    break
    
    # Find best SRAM from available sizes
    best_sram = find_best_sram_size(width, depth, available_srams)
    
    if best_sram is None:
        # Fallback to default logic if no suitable SRAM is found
        if width <= 4:
            sram_width = 4
        elif width <= 8:
            sram_width = 8
        elif width <= 32:
            sram_width = 32
        elif width <= 64:
            sram_width = 64
        else:
            sram_width = 128
        
        if depth <= 64:
            sram_depth = 64
        elif depth <= 128:
            sram_depth = 128
        elif depth <= 256:
            sram_depth = 256
        elif depth <= 512:
            sram_depth = 512
        else:
            sram_depth = 1024
        
        sram_type = f"TEM5N28HPCPLVTA{sram_depth}x{sram_width}M4SWBSO"
    else:
        sram_depth = best_sram["depth"]
        sram_width = best_sram["width"]
        sram_type = f"TEM5N28HPCPLVTA{sram_depth}x{sram_width}M4SWBSO"
    
    # Calculate macro selection
    num_macros = max(1, (depth + sram_depth - 1) // sram_depth)
    macro_sel_bits = 0
    while (1 << macro_sel_bits) < num_macros:
        macro_sel_bits += 1
    
    # Generate module implementation based on type
    if module_type == "RW":
        # For RW modules
        module_code = f"module {module_name}(\n{port_str}\n);\n\n"
        
        if num_macros > 1:
            # Multiple macros
            module_code += f"    wire [{addr_width-1}:0] addr = RW0_addr;\n"
            module_code += f"    wire [{macro_sel_bits-1}:0] macro_sel = addr[{addr_width-1}:{addr_width-macro_sel_bits}];\n"
            module_code += f"    wire [{addr_width-macro_sel_bits-1}:0] macro_addr = addr[{addr_width-macro_sel_bits-1}:0];\n\n"
        else:
            # Single macro
            module_code += f"    wire [{addr_width-1}:0] addr = RW0_addr;\n\n"
        
        module_code += "    wire CE = ~RW0_en;\n"
        module_code += "    wire WEB = ~RW0_wmode;\n"
        module_code += "    wire OEB = RW0_wmode;\n\n"
        
        if num_macros > 1:
            # Generate arrays for multiple macros
            module_code += f"    wire [{sram_width-1}:0] O [{num_macros-1}:0];\n"
            module_code += f"    wire [{sram_width-1}:0] I [{num_macros-1}:0];\n\n"
            
            if width < sram_width:
                # If width is less than SRAM width, zero-extend
                for i in range(num_macros):
                    module_code += f"    assign I[{i}] = {{'{sram_width-width}'b0, RW0_wdata}};\n"
                module_code += "\n"
            else:
                # If width matches SRAM width
                for i in range(num_macros):
                    module_code += f"    assign I[{i}] = RW0_wdata;\n"
                module_code += "\n"
            
            # Generate instantiations for each macro
            module_code += "    genvar i;\n"
            module_code += "    generate\n"
            module_code += f"        for (i = 0; i < {num_macros}; i = i + 1) begin: SRAM_INST\n"
            module_code += f"            {sram_type} sram_inst (\n"
            module_code += "                .A((i == macro_sel) ? macro_addr : {" + str(addr_width-macro_sel_bits) + "'h0}),\n"
            module_code += "                .CE(CE),\n"
            module_code += "                .WEB((i == macro_sel) ? WEB : 1'b1),\n"
            module_code += "                .OEB((i == macro_sel) ? OEB : 1'b1),\n"
            module_code += "                .CSB(1'b0),\n"
            module_code += "                .I(I[i]),\n"
            module_code += "                .O(O[i])\n"
            module_code += "            );\n"
            module_code += "        end\n"
            module_code += "    endgenerate\n\n"
            
            # Create rdata mux
            if num_macros > 1:
                module_code += f"    wire [{width-1}:0] rdata [{num_macros-1}:0];\n"
                
                # OR all outputs together (only one will be active due to OEB/CSB settings)
                or_expr = []
                for i in range(num_macros):
                    or_expr.append(f"rdata[{i}]")
                module_code += f"    assign RW0_rdata = {' | '.join(or_expr)};\n\n"
                
                # Add rdata assignments
                module_code += "    genvar j;\n"
                module_code += "    generate\n"
                module_code += f"        for (j = 0; j < {num_macros}; j = j + 1) begin: RDATA_SEL\n"
                if width < sram_width:
                    module_code += f"            assign rdata[j] = O[j][{width-1}:0];\n"
                else:
                    module_code += f"            assign rdata[j] = O[j];\n"
                module_code += "        end\n"
                module_code += "    endgenerate\n\n"
            else:
                if width < sram_width:
                    module_code += f"    assign RW0_rdata = O[0][{width-1}:0];\n\n"
                else:
                    module_code += "    assign RW0_rdata = O[0];\n\n"
        else:
            # Single macro, simpler implementation
            module_code += f"    wire [{sram_width-1}:0] O;\n"
            module_code += f"    wire [{sram_width-1}:0] I;\n\n"
            
            if width < sram_width:
                module_code += f"    assign I = {{'{sram_width-width}'b0, RW0_wdata}};\n\n"
            else:
                module_code += "    assign I = RW0_wdata;\n\n"
                
            module_code += f"    {sram_type} sram_inst (\n"
            module_code += "        .A(addr),\n"
            module_code += "        .CE(CE),\n"
            module_code += "        .WEB(WEB),\n"
            module_code += "        .OEB(OEB),\n"
            module_code += "        .CSB(1'b0),\n"
            module_code += "        .I(I),\n"
            module_code += "        .O(O)\n"
            module_code += "    );\n\n"
            
            if width < sram_width:
                module_code += f"    assign RW0_rdata = O[{width-1}:0];\n\n"
            else:
                module_code += "    assign RW0_rdata = O;\n\n"
                
        module_code += "endmodule\n"
        
    elif module_type == "RW_split":
        # For separate R/W port modules
        module_code = f"module {module_name}(\n{port_str}\n);\n\n"
        
        if "W0_addr" in ports and "R0_addr" in ports:
            # Determine address width
            w_addr_width = 0
            r_addr_width = 0
            
            for port_name, port_info in ports.items():
                if port_name == "W0_addr" and port_info["width"]:
                    match = re.search(r'\[(\d+):(\d+)\]', port_info["width"])
                    if match:
                        w_addr_width = int(match.group(1)) + 1
                if port_name == "R0_addr" and port_info["width"]:
                    match = re.search(r'\[(\d+):(\d+)\]', port_info["width"])
                    if match:
                        r_addr_width = int(match.group(1)) + 1
            
            module_code += f"    wire [{w_addr_width-1}:0] addr_w = W0_addr;\n"
            module_code += f"    wire [{r_addr_width-1}:0] addr_r = R0_addr;\n\n"
            
            # For multi-macro designs
            if num_macros > 1:
                module_code += f"    wire [{macro_sel_bits-1}:0] macro_sel_w = addr_w[{w_addr_width-1}:{w_addr_width-macro_sel_bits}];\n"
                module_code += f"    wire [{macro_sel_bits-1}:0] macro_sel_r = addr_r[{r_addr_width-1}:{r_addr_width-macro_sel_bits}];\n"
                module_code += f"    wire [{w_addr_width-macro_sel_bits-1}:0] macro_addr_w = addr_w[{w_addr_width-macro_sel_bits-1}:0];\n"
                module_code += f"    wire [{r_addr_width-macro_sel_bits-1}:0] macro_addr_r = addr_r[{r_addr_width-macro_sel_bits-1}:0];\n\n"
            
            module_code += "    wire CE = ~(|(W0_en & R0_en));\n"
            module_code += "    wire WEB = ~(W0_en);\n"
            module_code += "    wire OEB = R0_en;\n\n"
            
            if num_macros > 1:
                # Arrays for multi-macro
                module_code += f"    wire [{sram_width-1}:0] O [{num_macros-1}:0];\n"
                module_code += f"    wire [{sram_width-1}:0] I [{num_macros-1}:0];\n\n"
                
                if width < sram_width:
                    for i in range(num_macros):
                        module_code += f"    assign I[{i}] = {{'{sram_width-width}'b0, W0_data}};\n"
                else:
                    for i in range(num_macros):
                        module_code += f"    assign I[{i}] = W0_data;\n"
                module_code += "\n"
                
                # Generate instances
                module_code += "    genvar i;\n"
                module_code += "    generate\n"
                module_code += f"        for (i = 0; i < {num_macros}; i = i + 1) begin: SRAM_INST\n"
                module_code += f"            {sram_type} sram_inst (\n"
                if num_macros == 2:  # Special case for 2 macros
                    module_code += "                .A(addr_w|addr_r),\n"
                else:
                    module_code += "                .A((i == macro_sel_w) ? macro_addr_w : macro_addr_r),\n"
                module_code += "                .CE(CE),\n"
                if num_macros == 2:
                    module_code += f"                .WEB((i == macro_sel_w) ? WEB : 1'b1),\n"
                    module_code += f"                .OEB((i == macro_sel_r) ? OEB : 1'b1),\n"
                    module_code += f"                .CSB(1'b0),\n"
                else:
                    module_code += f"                .WEB((i == macro_sel_w) ? WEB : 1'b1),\n"
                    module_code += f"                .OEB((i == macro_sel_r) ? OEB : 1'b1),\n"
                    module_code += f"                .CSB((i == macro_sel_w) || (i == macro_sel_r) ? 1'b0 : 1'b1),\n"
                module_code += "                .I(I[i]),\n"
                module_code += "                .O(O[i])\n"
                module_code += "            );\n"
                module_code += "        end\n"
                module_code += "    endgenerate\n\n"
                
                # Create rdata mux
                module_code += f"    wire [{width-1}:0] rdata [{num_macros-1}:0];\n"
                
                # OR all outputs together
                or_expr = []
                for i in range(num_macros):
                    or_expr.append(f"rdata[{i}]")
                module_code += f"    assign R0_data = {' | '.join(or_expr)};\n\n"
                
                # rdata assignments
                module_code += "    genvar j;\n"
                module_code += "    generate\n"
                module_code += f"        for (j = 0; j < {num_macros}; j = j + 1) begin: RDATA_SEL\n"
                if width < sram_width:
                    module_code += f"            assign rdata[j] = O[j][{width-1}:0];\n"
                else:
                    module_code += f"            assign rdata[j] = O[j];\n"
                module_code += "        end\n"
                module_code += "    endgenerate\n\n"
                
            else:
                # Single macro implementation
                module_code += f"    wire [{sram_width-1}:0] O;\n"
                module_code += f"    wire [{sram_width-1}:0] I;\n\n"
                
                if width < sram_width:
                    module_code += f"    assign I = {{'{sram_width-width}'b0, W0_data}};\n\n"
                else:
                    module_code += "    assign I = W0_data;\n\n"
                    
                module_code += f"    {sram_type} sram_inst (\n"
                module_code += "        .A(addr_w|addr_r),\n"
                module_code += "        .CE(CE),\n"
                module_code += "        .WEB(WEB),\n"
                module_code += "        .OEB(OEB),\n"
                module_code += "        .CSB(1'b0),\n"
                module_code += "        .I(I),\n"
                module_code += "        .O(O)\n"
                module_code += "    );\n\n"
                
                if width < sram_width:
                    module_code += f"    assign R0_data = O[{width-1}:0];\n\n"
                else:
                    module_code += "    assign R0_data = O;\n\n"
        
        module_code += "endmodule\n"
    
    else:
        module_code = f"// Error: Unknown module type for {module_name}\n"
    
    return module_code

def extract_available_srams(dc_script_path):
    """Extract available SRAM sizes from DC script."""
    available_srams = []
    
    try:
        with open(dc_script_path, 'r') as f:
            script_content = f.read()
            
        # Find SRAM library paths
        sram_libs = re.finditer(r'tem5n28hpcplvta(\d+)x(\d+)m4swbso', script_content, re.IGNORECASE)
        
        for match in sram_libs:
            depth = match.group(1)
            width = match.group(2)
            sram_name = f"{depth}x{width}"
            if sram_name not in available_srams:
                available_srams.append(sram_name)
    except:
        # Default SRAM sizes if DC script not found
        default_sizes = [
            "64x32", "64x64", "128x32", "128x64",
            "256x32", "256x64", "512x32", "512x64",
            "1024x32", "1024x64", "64x32", "128x32"
        ]
        available_srams.extend(default_sizes)
    
    return available_srams

def main():
    parser = argparse.ArgumentParser(description='Convert memory modules to SRAM macro format.')
    parser.add_argument('json_file', help='Path to seq_mems.json file')
    parser.add_argument('verilog_file', help='Path to input Verilog file')
    parser.add_argument('-o', '--output', help='Output Verilog file path (default: converted_mems.v)', default='converted_mems.v')
    parser.add_argument('-d', '--dc_script', help='Path to DC script with SRAM libraries', default='')
    
    args = parser.parse_args()
    
    json_file = args.json_file
    verilog_file = args.verilog_file
    output_file = args.output
    dc_script = args.dc_script
    
    # Find DC script if not specified
    if not dc_script:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        possible_scripts = [
            os.path.join(current_dir, 'dc_script.tcl'),
            os.path.join(current_dir, '..', 'voyager-test', 'scripts', 'dc_script.tcl'),
            os.path.join(current_dir, '..', 'scripts', 'dc_script.tcl')
        ]
        
        for script in possible_scripts:
            if os.path.exists(script):
                dc_script = script
                break
    
    # Get available SRAM sizes
    available_srams = extract_available_srams(dc_script)
    
    # Parse input files
    mem_info_list = parse_seq_mems(json_file)
    modules = parse_modules(verilog_file)
    
    # Create dictionary of memory info by module name
    mem_info_dict = {mem["module_name"]: mem for mem in mem_info_list}
    
    # Generate code for each module
    output_code = "// Auto-generated SRAM macro file\n"
    output_code += "// Generated from: " + os.path.basename(verilog_file) + "\n"
    output_code += "// Using memory specs from: " + os.path.basename(json_file) + "\n\n"
    
    for module_name, module_info in modules.items():
        if module_name in mem_info_dict:
            mem_info = mem_info_dict[module_name]
            ports = module_info["ports"]
            
            # Generate new module code
            ext_module = generate_ext_module(module_name, ports, mem_info, available_srams)
            output_code += ext_module + "\n"
    
    # Write output to file
    with open(output_file, 'w') as f:
        f.write(output_code)
    
    print(f"生成 {output_file}")
    print(f"处理了 {len(mem_info_dict)} 个内存模块")

if __name__ == "__main__":
    main() 