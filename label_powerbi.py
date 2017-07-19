from __future__ import print_function
import json, sys
from PIL import Image, ImageFont, ImageDraw, ImageEnhance
from pprint import pprint

# UTILS TO LOAD IGNORING UNICODE
def json_load_byteified(file_handle):
    return _byteify(
        json.load(file_handle, object_hook=_byteify),
        ignore_dicts=True
    )

def json_loads_byteified(json_text):
    return _byteify(
        json.loads(json_text, object_hook=_byteify),
        ignore_dicts=True
    )

def _byteify(data, ignore_dicts = False):
    # if this is a unicode string, return its string representation
    if isinstance(data, unicode):
        return data.encode('utf-8')
    # if this is a list of values, return list of byteified values
    if isinstance(data, list):
        return [ _byteify(item, ignore_dicts=True) for item in data ]
    # if this is a dictionary, return dictionary of byteified keys and values
    # but only if we haven't already byteified it
    if isinstance(data, dict) and not ignore_dicts:
        return {
            _byteify(key, ignore_dicts=True): _byteify(value, ignore_dicts=True)
            for key, value in data.iteritems()
        }
    # if it's anything else, return it in its original form
    return data


# PART 1: CONSTANT
OFFSET = 22
Y_EXTRA_OFFSET = 15
FONT_OFFSET = 3
FONT_SIZE = 14
FONT_PATH = 'C:\\Windows\\Fonts\\arialbi.ttf'



# PART 2: I/O
INPUT_JSON      = sys.argv[1]
SCREENSHOT_PATH = sys.argv[2]
VISUAL_NAME     = sys.argv[3]

# EXAMPLE FILE I/O
#INPUT_JSON = 'Layout_TranBank-2_DigitalBehavior.json'
#SCREENSHOT_PATH = './TranBank-2/Layout_TranBank-2_DigitalBehavior/TranBank-2_02.png'
#VISUAL_NAME = '2.Digital_Non-Digital Behavior2'

OUT_FILE = SCREENSHOT_PATH.replace('.png','.out.png')


# PART 3: MAIN
METADATA = json_load_byteified(open(INPUT_JSON))
source_img = Image.open(SCREENSHOT_PATH).convert("RGBA")
source_img = source_img.resize((1280,720), Image.ANTIALIAS)
draw = ImageDraw.Draw(source_img)

#pprint(METADATA)
visual_names = set()
is_found = False

for section in METADATA:
    for i, visual in enumerate(section):
        visual_names.add(visual['name'])
        if visual['name'] == VISUAL_NAME:
            is_found = True
            human_i = i + 1 # human count from 1
            _SINGLE_NUM_OFFSET = 4 if i < 10 else 0
            c = (visual['x'], visual['y']) # coordinate
            #print('working on', c)

            draw.ellipse(
                ((c[0], c[1] + Y_EXTRA_OFFSET ), 
                    (c[0] + OFFSET, c[1] + OFFSET +  Y_EXTRA_OFFSET)), 
                fill='red'
            )

            draw.text(
                (c[0] + FONT_OFFSET + _SINGLE_NUM_OFFSET, 
                c[1] + FONT_OFFSET +  Y_EXTRA_OFFSET), 
                str(human_i), 
                font=ImageFont.truetype(FONT_PATH, FONT_SIZE)
            )

if not is_found:
    print('\n\n[ERROR] visual not found, avialable visual in this JSON are:\n\n', '\n'.join(visual_names))
    print('\n\n[ERROR] But supplied VISUAL_NAME are \n\n', VISUAL_NAME)
    raise ValueError('Visual not avilable in JSON')

source_img.save(OUT_FILE, 'PNG')
print('FINISH test_pil.py OUTPUT TO: ', OUT_FILE)
