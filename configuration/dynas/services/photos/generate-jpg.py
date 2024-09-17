import os
import sys
import sqlite3
import json
import re
import datetime
from typing import Set
import xml.etree.ElementTree as ET

import subprocess
import logging

# Create logger
logger = logging.getLogger(__name__)

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s', filename="log.log")


handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

jpg_re = re.compile(r".*\.jpg")
dry_run = True

# xml namespaces
namespaces = {
    'x': 'adobe:ns:meta/',
    'rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    'exif': 'http://ns.adobe.com/exif/1.0/',
    'xmp': 'http://ns.adobe.com/xap/1.0/',
    'xmpMM': 'http://ns.adobe.com/xap/1.0/mm/',
    'darktable': 'http://darktable.sf.net/',
    'dc': 'http://purl.org/dc/elements/1.1/',
    'lr': 'http://ns.adobe.com/lightroom/1.0/'
}

def cmd(cmd:list, stop_on_error=True):
    global dry_run
    logger.debug(" ".join(cmd))
    if not dry_run:
        ret = subprocess.run(cmd)
        if ret.returncode != 0:
            if stop_on_error:
                exit(ret)
            else:
                logger.error("Failed")

def setup_db() -> sqlite3.Connection:
    global config
    connection = sqlite3.connect(
        config["library"]
    )
    return connection

def find_files() -> Set[str]:
    global config
    jpg_dir = config["jpgs"]
    return set(map(
        lambda f: os.path.join(jpg_dir, f),
        filter(
            lambda f: jpg_re.match(f), 
            os.listdir(jpg_dir))))

def main():
    global config
    global dry_run
    if len(sys.argv) >= 2:
        config_path = sys.argv[1]
    else:
        config_path = os.path.join(
            os.path.dirname(__file__), 'config.json')
    with open(config_path, 'r') as f:
        config = json.load(f)
    
    s ="\n"
    for k, v in config.items():
        s += f"\t'{k}':\t '{v}'\n"
    logger.info("running the exporter with configuration:"+s)

    dry_run = config["dry_run"]
    
    jpg_dir = config["jpgs"]
    quality = int(config["quality"])
    
    logging.info("fetching jpgs...")
    files = find_files()

    logging.info("fetching images")
    db = setup_db()
    q = get_from_db(db)
    
    logging.info("exporting")
    todo = []
    for f in q:
        file, date, xmp, jpg = extract_data(f, jpg_dir)

        if not os.path.exists(file):
            logger.debug("original not found :" + file)
            continue

        try:

            # Load and parse the XML file
            tree = ET.parse(xmp)
            root = tree.getroot()

            # Find the xmp:Rating attribute
            description = root.find('.//rdf:Description', namespaces)
            rating = description.get(f'{{{namespaces['xmp']}}}Rating')
            if rating == "-1":
                logger.debug(f"rejected '{file}'")
                continue

            mtime = datetime.datetime.fromtimestamp(os.path.getmtime(jpg))
            files.remove(jpg)
            if (not date) or mtime > date:
                logger.debug(f"skiping '{file}', already exported as '{jpg}'")
                continue
        except OSError:
            if jpg in files:
                logger.error(f"!!!!!!!!!!!!!!!!!!!!!!!!1\nerror on {jpg}, {xmp}")
                exit(1)

        todo.append(run_dt(quality, file, xmp, jpg))

        
        # print("{id}\n\t{file}\n\t{xmp}".format(
        #     id=id,
        #     file=file,
        #     xmp=xmp
        # ))
    
    for f in files:
        todo.append([ "rm", f])
    db.close()
    
    for c in todo:
        cmd(c, stop_on_error=False)

def run_dt(quality, file, xmp, jpg):
    global config
    if config["use_flatpack"]:
        dtcli = ["flatpak", "run", "--command=darktable-cli", "org.darktable.Darktable"]
    else:
        dtcli = ["darktable-cli"]
    dtargs = [file, xmp, jpg,
    # '--style', 'signature',
    '--apply-custom-presets', 'false',
    '--core',
        '--conf', f'plugins/imageio/format/jpeg/quality={quality}',
        '--conf', 'plugins/imageio/storage/disk/overwrite=1',
        "--library", config["library"]]
    
    return dtcli + dtargs

def get_from_db(db):
    query = '''SELECT
        images.id, images.filename,
            images.change_timestamp, images.version, film_rolls.folder
    FROM
        images
    INNER JOIN
        film_rolls
    ON
        film_rolls.id = images.film_id
    WHERE
        images.id = images.group_id
    AND
        images.id 
      NOT IN (
        SELECT tagged_images.imgid 
        FROM tagged_images 
        WHERE tagged_images.tagid = 55
      )'''
    q = db.execute(query, {})
    return q

def extract_data(f, jpg_dir):
    id = f[0]
    file = os.path.join(f[4], f[1])
    date = f[2]
    if date:
        date = \
                datetime.datetime.utcfromtimestamp(
                    date/1000000 - 62135596800)
    version = f[3]
    if version == 0:
        xmp = file + ".xmp"
    else:
        tmp = f[1].split('.')
        ext = tmp[-1]
        nfile = os.path.join(f[4], '.'.join(tmp[:-1]))
        xmp = "{f}_{v:02d}.{ext}.xmp".format(
                f=nfile,
                v=version,
                ext=ext
            )
    jpg = os.path.join(jpg_dir, str(id) + ".jpg")
    return file,date,xmp,jpg

if __name__ == "__main__":
    main()
