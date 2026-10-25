#!/usr/bin/env python3
"""
BT Tools Event এর .rbxmx ফাইল বানায়।

    python3 BTToolsEvents/build/build_rbxmx.py

- src/ এর .lua ফাইলগুলো Script / LocalScript / ModuleScript হয়ে যায়:
    *.server.lua -> Script, *.client.lua -> LocalScript, *.lua -> ModuleScript
- Original/ এর পুরনো ফাইল থেকে পুরস্কারের টুলগুলো আর গিফট বক্সের মেশ কপি হয়।
- ফলাফল: Release/BTToolsEvents.rbxmx
- --sourcemap PATH দিলে luau-lsp এর জন্য sourcemap.json ও লেখে।
"""

import argparse
import json
import os
import uuid
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SRC = os.path.join(ROOT, "src")
ORIGINAL = os.path.join(ROOT, "Original", "BT_Tools_Events_original.rbxmx")
OUTPUT = os.path.join(ROOT, "Release", "BTToolsEvents.rbxmx")

# rbxmx এর ভেতরের ফোল্ডার -> আসল Roblox সার্ভিস (sourcemap এর জন্য)
SERVICE_CLASSES = {
    "ReplicatedStorage": "ReplicatedStorage",
    "ServerScriptService": "ServerScriptService",
    "ServerStorage": "ServerStorage",
    "StarterPlayerScripts": "StarterPlayerScripts",
    "Workspace": "Workspace",
}

REMOTES = [
    ("AdminRequest", "RemoteFunction"),
    ("OpenBox", "RemoteEvent"),
    ("Notify", "RemoteEvent"),
    ("Announce", "RemoteEvent"),
]

README_SOURCE = """--[[
	🎁 BT Tools Event: কোথায় কী রাখবেন

	এই ফোল্ডারের ভেতরের প্রতিটা ফোল্ডারের নাম হল Roblox এর যে সার্ভিসে রাখতে হবে।
	ভেতরের জিনিসগুলো টেনে সেই সার্ভিসে রাখুন:

	1. ReplicatedStorage/BTToolsEvents      ->  ReplicatedStorage
	2. ServerScriptService/BTToolsEvents    ->  ServerScriptService
	3. ServerStorage/BTToolsEvents          ->  ServerStorage
	   ServerStorage/Tools                  ->  ServerStorage  (পুরস্কারের টুল, নিজের টুলও এখানে রাখুন)
	4. StarterPlayerScripts/BTToolsEvents   ->  StarterPlayer > StarterPlayerScripts
	5. Workspace/HuntSpawnZones             ->  Workspace  (ভেতরের পার্টগুলো ম্যাপে যেখানে বক্স চান সেখানে বসান)
	   Workspace/WinnerShowcase             ->  Workspace  (বিজয়ীর অবতার যেখানে নাচবে, সামনের দিক = মুখের দিক)

	তারপর এই খালি ফোল্ডারটা মুছে দিন।

	সব সেটিং (অ্যাডমিন ID, সাউন্ড ID, নাচের ID, টাকা) পাবেন:
	ReplicatedStorage > BTToolsEvents > Config

	Studio তে টেস্ট করতে: Game Settings > Security > "Enable Studio Access to API Services" চালু করুন,
	না হলে টুল সেভ হবে না।
]]
return nil
"""


def new_ref():
    return "RBXBT" + uuid.uuid4().hex.upper()


def item(class_name, name, props=None):
    el = ET.Element("Item", {"class": class_name, "referent": new_ref()})
    p = ET.SubElement(el, "Properties")
    s = ET.SubElement(p, "string", {"name": "Name"})
    s.text = name
    for tag, pname, value in props or []:
        child = ET.SubElement(p, tag, {"name": pname})
        if isinstance(value, dict):
            for k, v in value.items():
                sub = ET.SubElement(child, k)
                sub.text = str(v)
        else:
            child.text = value
    return el


def script_item(path):
    filename = os.path.basename(path)
    if filename.endswith(".server.lua"):
        class_name, name = "Script", filename[: -len(".server.lua")]
    elif filename.endswith(".client.lua"):
        class_name, name = "LocalScript", filename[: -len(".client.lua")]
    else:
        class_name, name = "ModuleScript", filename[: -len(".lua")]
    with open(path, encoding="utf-8") as f:
        source = f.read()
    props = [("ProtectedString", "Source", source)]
    if class_name != "ModuleScript":
        props.append(("bool", "Disabled", "false"))
    return item(class_name, name, props), class_name, name


def cframe(x, y, z):
    values = {"X": x, "Y": y, "Z": z}
    for i, key in enumerate(["R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22"]):
        values[key] = 1 if i in (0, 4, 8) else 0
    return values


def color(r, g, b):
    return str(0xFF000000 | (r << 16) | (g << 8) | b)


def helper_part(name, position, size, rgb, transparency):
    return item(
        "Part",
        name,
        [
            ("CoordinateFrame", "CFrame", cframe(*position)),
            ("Vector3", "size", {"X": size[0], "Y": size[1], "Z": size[2]}),
            ("Color3uint8", "Color3uint8", color(*rgb)),
            ("float", "Transparency", str(transparency)),
            ("bool", "Anchored", "true"),
            ("bool", "CanCollide", "false"),
            ("bool", "CanTouch", "false"),
            ("bool", "CastShadow", "false"),
            ("token", "Material", "288"),  # Neon, যাতে Studio তে সহজে দেখা যায়
        ],
    )


def item_name(el):
    props = el.find("Properties")
    name = props.find("string[@name='Name']") if props is not None else None
    return name.text if name is not None else None


def find_child(parent, name):
    for child in parent.findall("Item"):
        if item_name(child) == name:
            return child
    raise SystemExit(f"Original ফাইলে '{name}' পাওয়া যায়নি")


class SourceTree:
    """rbxmx আর sourcemap একসাথে বানায়।"""

    def __init__(self):
        self.sourcemap_children = []

    def add_lua_dir(self, xml_parent, sm_parent, directory):
        for entry in sorted(os.listdir(directory)):
            path = os.path.join(directory, entry)
            if os.path.isdir(path):
                folder = item("Folder", entry)
                xml_parent.append(folder)
                sm = {"name": entry, "className": "Folder", "children": []}
                sm_parent.append(sm)
                self.add_lua_dir(folder, sm["children"], path)
            elif entry.endswith(".lua"):
                el, class_name, name = script_item(path)
                xml_parent.append(el)
                sm_parent.append(
                    {"name": name, "className": class_name, "filePaths": [os.path.relpath(path, os.getcwd())]}
                )


def build(sourcemap_path):
    original = ET.parse(ORIGINAL).getroot()
    orig_root = original.find("Item")
    orig_ss = find_child(orig_root, "SS")
    orig_reward_tools = find_child(orig_ss, "GiftBoxTools")
    orig_box_tool = find_child(orig_ss, "GiftBoxTool")

    out = ET.Element(
        "roblox",
        {
            "xmlns:xmime": "http://www.w3.org/2005/05/xmlmime",
            "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
            "xsi:noNamespaceSchemaLocation": "http://www.roblox.com/roblox.xsd",
            "version": "4",
        },
    )
    ET.SubElement(out, "Meta", {"name": "ExplicitAutoJoints"}).text = "true"
    ET.SubElement(out, "External").text = "null"
    ET.SubElement(out, "External").text = "nil"

    root = item("Folder", "BTToolsEvents")
    out.append(root)
    root.append(item("ModuleScript", "README", [("ProtectedString", "Source", README_SOURCE)]))

    tree = SourceTree()
    sourcemap = {"name": "Game", "className": "DataModel", "children": []}
    services = {}

    def service(name):
        if name not in services:
            folder = item("Folder", name)
            root.append(folder)
            sm = {"name": name, "className": SERVICE_CLASSES[name], "children": []}
            if name == "StarterPlayerScripts":
                sourcemap["children"].append(
                    {"name": "StarterPlayer", "className": "StarterPlayer", "children": [sm]}
                )
            else:
                sourcemap["children"].append(sm)
            services[name] = (folder, sm)
        return services[name]

    # src/<Service>/... থেকে স্ক্রিপ্ট
    for service_name in sorted(os.listdir(SRC)):
        folder, sm = service(service_name)
        tree.add_lua_dir(folder, sm["children"], os.path.join(SRC, service_name))

    # ReplicatedStorage/BTToolsEvents/Remotes
    rs_folder, rs_sm = service("ReplicatedStorage")
    shared = find_child(rs_folder, "BTToolsEvents")
    shared_sm = next(c for c in rs_sm["children"] if c["name"] == "BTToolsEvents")
    remotes = item("Folder", "Remotes")
    shared.append(remotes)
    remotes_sm = {"name": "Remotes", "className": "Folder", "children": []}
    shared_sm["children"].append(remotes_sm)
    for name, class_name in REMOTES:
        remotes.append(item(class_name, name))
        remotes_sm["children"].append({"name": name, "className": class_name})

    # ServerStorage: গিফট বক্স টুল (পুরনো স্ক্রিপ্ট ছাড়া) আর পুরস্কারের টুল
    ss_folder, ss_sm = service("ServerStorage")
    ss_bt = item("Folder", "BTToolsEvents")
    ss_folder.append(ss_bt)
    for child in list(orig_box_tool.findall("Item")):
        if child.get("class") in ("Script", "LocalScript", "ModuleScript"):
            orig_box_tool.remove(child)
    orig_box_tool.find("Properties").find("string[@name='Name']").text = "GiftBoxTool"
    ss_bt.append(orig_box_tool)
    tools_folder = item("Folder", "Tools")
    ss_folder.append(tools_folder)
    for tool in orig_reward_tools.findall("Item"):
        tools_folder.append(tool)
    ss_sm["children"].append(
        {
            "name": "BTToolsEvents",
            "className": "Folder",
            "children": [{"name": "GiftBoxTool", "className": "Tool"}],
        }
    )
    ss_sm["children"].append({"name": "Tools", "className": "Folder"})

    # Workspace: উদাহরণ স্পন জোন আর শোকেস পার্ট
    ws_folder, ws_sm = service("Workspace")
    zones = item("Folder", "HuntSpawnZones")
    zones.append(helper_part("Zone1", (0, 5, 0), (120, 12, 120), (80, 200, 255), 0.75))
    ws_folder.append(zones)
    ws_folder.append(helper_part("WinnerShowcase", (0, 1, -40), (36, 2, 10), (255, 205, 60), 0.4))
    ws_sm["children"].append({"name": "HuntSpawnZones", "className": "Folder"})
    ws_sm["children"].append({"name": "WinnerShowcase", "className": "Part"})

    shared_strings = original.find("SharedStrings")
    if shared_strings is not None:
        out.append(shared_strings)

    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    ET.ElementTree(out).write(OUTPUT, encoding="utf-8", xml_declaration=False)
    print(f"✓ {os.path.relpath(OUTPUT, os.getcwd())}")

    if sourcemap_path:
        with open(sourcemap_path, "w", encoding="utf-8") as f:
            json.dump(sourcemap, f, ensure_ascii=False, indent=1)
        print(f"✓ {sourcemap_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--sourcemap", help="luau-lsp এর জন্য sourcemap.json কোথায় লিখবে")
    args = parser.parse_args()
    build(args.sourcemap)
