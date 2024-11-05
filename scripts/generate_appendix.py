import os
import sys
import json
import zipfile
import subprocess
from pybtex.database.input import bibtex

def html2pdf(html_path:str, pdf_path:str):
    #print(f"cutycapt --url=\"file:{os.getcwd()}/{html_path}\" --out=\"{os.getcwd()}/{pdf_path}\"")
    subprocess.run(f"cutycapt --url=\"file:{os.getcwd()}/{html_path}\" --out=\"{os.getcwd()}/{pdf_path}\"", shell=True, executable="/bin/bash")
    #print(f"htmldoc \"{html_path}\" -t pdf > \"{pdf_path}\" || true")
    #subprocess.run(f"htmldoc \"{html_path}\" -t pdf > \"{pdf_path}\" || true", shell=True, executable="/bin/bash")

def pdf2png(pdf_path: str, pages_path: str):
    if not os.path.exists(pages_path):
        os.mkdir(pages_path)
    subprocess.run(f"pdftoppm \"{pdf_path}\" {pages_path + "/page"} -png", shell=True, executable="/bin/bash")

def parse_bib(bib_file:str) -> dict:
    parser = bibtex.Parser()
    bib_data = parser.parse_file(bib_file)

    res = {}

    for entry in bib_data.entries.keys():
        if "title" in list(bib_data.entries[entry].fields.keys()) and "file" in list(bib_data.entries[entry].fields.keys()):
            title = bib_data.entries[entry].fields["title"].replace("{", "").replace("}", "").replace("\\textbar", "")
            file_field = bib_data.entries[entry].fields["file"].split(":")
            files_dir = file_field[len(file_field)-2]

            res[entry] = {"title": title, "html": files_dir}

    return res

def get_directory_structure(dir_path:str, dir_name:str):
    #print(f"tree --metafirst --dirsfirst {dir_path}")
    cmd = ["tree", "--metafirst", "--dirsfirst", "-Q", dir_path]
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    #print(res.returncode, res.stdout, res.stderr)
    txt = res.stdout.split("\n")[1:]
    txt = txt[:len(txt)-3]
    max_len = 0
    for l in txt:
        if len(l) > max_len:
            max_len = len(l)
    h = f"- \"{dir_name}\" -"
    while len(h) < max_len:
        h = f"-{h}-"
    txt.insert(0, h)
    return "\n".join(txt)

def zipdir(path, ziph):
    for root, dirs, files in os.walk(path):
        for f in files:
            if f == "code_data.json" or f == "code.zip" or not os.path.exists(os.path.join(root, f)):
                continue
            ziph.write(os.path.join(root, f), 
                       os.path.relpath(os.path.join(root, f), 
                                       os.path.join(path, '..')))

def generate_bib_appendix(root_dir: str, bib_file_name: str, bib_generate_pages: bool):
    bib_file = os.path.join(root_dir, bib_file_name)
    res = parse_bib(bib_file)

    html_files = []

    files_dir = os.path.join(root_dir, "files")
    for bib_dir_name in os.listdir(files_dir):
        bib_dir = os.path.join(files_dir, bib_dir_name)

        # Generate PDF and PNG
        bib_dir_pages = os.path.join(bib_dir, "pages")
        html_path = ""
        for f in os.listdir(bib_dir):
            if f.endswith(".html"):
                html_path = os.path.join(bib_dir, f)
                if bib_generate_pages:
                    pdf_path = os.path.join(bib_dir, 'website.pdf')
                    html2pdf(html_path, pdf_path)
                    pdf2png(pdf_path, bib_dir_pages)

        # Add to html file list
        html_files.append(html_path)

        # Search Pages
        if not os.path.exists(bib_dir_pages) and len(html_path) > 0:
            continue

        # Search bib match 
        key = None
        for k, v in res.items():
            v_path = os.path.join(root_dir, v["html"])
            if v_path == html_path:
                key = k
                break
        
        if key is None:
            continue

        res[key]["pages"] = []

        if bib_generate_pages:
            # Get generated pages
            for page_name in os.listdir(bib_dir_pages):
                page = os.path.join(bib_dir_pages, page_name)
                res[key]["pages"].append(page)

            res[key]["pages"].sort()

    # Create json
    json_file = os.path.join(root_dir, "bib_data.json")
    with open(json_file, "w") as data_file:
        json.dump(res, data_file, indent=4, sort_keys=True, ensure_ascii=False)

    # Create zip
    with zipfile.ZipFile(os.path.join(root_dir, 'websites.zip'), 'w') as myzip:
        for f in html_files:
            if os.path.exists(f):
                myzip.write(f, arcname=os.path.basename(f))
    print("Generated bib appendix!")

def generate_code_appendix(root_dir: str):
    res = {}
    for code_dir_name in os.listdir(root_dir):
        code_dir = os.path.join(root_dir, code_dir_name)
        if not os.path.isdir(code_dir):
            continue
        res[code_dir_name] = {}
        # Generate Directory Tree
        tree = get_directory_structure(code_dir, code_dir_name)
        res[code_dir_name]["tree"] = tree

        # Get README path
        res[code_dir_name]["readme"] = ""
        for f in os.listdir(code_dir):
            if os.path.isfile(f) and f.lower() == "readme.md":
                res[code_dir_name]["readme"] = f"../../../{root_dir.replace(os.getcwd(), '')}/{code_dir_name}/{f}"
                break

    # Create json
    json_file = os.path.join(root_dir, "code_data.json")
    with open(json_file, "w") as data_file:
        json.dump(res, data_file, indent=4, sort_keys=True, ensure_ascii=False)

    # Create zip
    with zipfile.ZipFile(os.path.join(root_dir, 'code.zip'), 'w', zipfile.ZIP_DEFLATED) as zipf:
        zipdir(root_dir, zipf)
    print("Generated code appendix!")

def generate_appendix_archive(bib_dir, code_dir):
    with zipfile.ZipFile('Anhang.zip', 'w') as myzip:
        myzip.write(os.path.join(bib_dir, "websites.zip"), arcname="websites.zip")
        myzip.write(os.path.join(code_dir, "code.zip"), arcname="code.zip")
    print("Generated Anhang.zip")


if __name__ == "__main__":
    bib_dir = "assets/bib/"
    bib_file_name = "Bib.bib"
    bib_generate_pages = False
    code_dir = "assets/code/"
    generate_bib_appendix(bib_dir, bib_file_name, bib_generate_pages)
    generate_code_appendix(code_dir)
    generate_appendix_archive(bib_dir, code_dir)
